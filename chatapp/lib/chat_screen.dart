import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'package:chatapp/core/config/app_config.dart';
import 'package:chatapp/core/design/app_colors.dart';
import 'package:chatapp/core/design/app_spacing.dart';
import 'package:chatapp/app/settings_scope.dart';
import 'package:chatapp/features/auth/domain/models/auth_session.dart';
import 'package:chatapp/features/chat/domain/models/chat_message_item.dart';
import 'package:chatapp/features/chat/presentation/models/chat_screen_args.dart';
import 'package:chatapp/features/chat/presentation/screens/chat_image_preview_screen.dart';
import 'package:chatapp/features/chat/presentation/utils/chat_background_resolver.dart';
import 'package:chatapp/features/chat/presentation/widgets/chat_call_preview.dart';
import 'package:chatapp/features/chat/presentation/widgets/chat_composer.dart';
import 'package:chatapp/features/chat/presentation/widgets/chat_header.dart';
import 'package:chatapp/features/chat/presentation/widgets/chat_image_send_preview_sheet.dart';
import 'package:chatapp/features/chat/presentation/widgets/chat_message_list.dart';
import 'package:chatapp/features/chat/presentation/widgets/chat_typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, this.session, this.args});

  final AuthSession? session;
  final ChatScreenArgs? args;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final AudioRecorder recorder = AudioRecorder();
  final AudioPlayer player = AudioPlayer();
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer remoteRenderer = RTCVideoRenderer();

  io.Socket? socket;
  String? token;
  int? userId;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  String? targetSocketId;
  Timer? _typingDebounce;
  StreamSubscription<void>? _playerCompleteSubscription;

  bool isLoading = true;
  bool isRecording = false;
  bool _isSendingMedia = false;
  bool _isPeerTyping = false;
  String? _activeAudioUrl;

  @override
  void initState() {
    super.initState();
    controller.addListener(_handleComposerChanged);
    localRenderer.initialize();
    remoteRenderer.initialize();
    _playerCompleteSubscription = player.onPlayerComplete.listen((_) {
      if (!mounted) {
        return;
      }
      setState(() => _activeAudioUrl = null);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => scrollToBottom());
    initApp();
  }

  Future<void> initApp() async {
    try {
      final session = widget.session;
      if (session == null || session.token.isEmpty) {
        if (!mounted) {
          return;
        }
        setState(() => isLoading = false);
        return;
      }

      token = session.token;
      userId = session.user.id;
      connectSocket();
      setupListeners();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => isLoading = false);
    }
  }

  void connectSocket() {
    socket = io.io(
      AppConfig.baseUrl,
      io.OptionBuilder().setTransports(['websocket']).setAuth({
        'token': token,
      }).build(),
    );

    socket!.onConnect((_) {
      if (!mounted) {
        return;
      }
      setState(() => isLoading = false);
    });

    socket!.onConnectError((_) {
      if (!mounted) {
        return;
      }
      setState(() => isLoading = false);
    });
  }

  void setupListeners() {
    socket!.on('load_messages', (data) {
      if (!mounted) {
        return;
      }
      setState(() {
        messages
          ..clear()
          ..addAll(List<Map<String, dynamic>>.from(data));
        isLoading = false;
        _isPeerTyping = false;
      });
      scrollToBottom();
    });

    socket!.on('receive_message', (data) {
      if (!mounted) {
        return;
      }
      setState(() {
        messages.add(Map<String, dynamic>.from(data));
        _isPeerTyping = false;
      });
      scrollToBottom();
    });

    socket!.on('typing', (_) => _setPeerTyping(true));
    socket!.on('user_typing', (_) => _setPeerTyping(true));
    socket!.on('typing-started', (_) => _setPeerTyping(true));
    socket!.on('stop_typing', (_) => _setPeerTyping(false));
    socket!.on('user_stop_typing', (_) => _setPeerTyping(false));
    socket!.on('typing-stopped', (_) => _setPeerTyping(false));

    socket!.on('incoming-call', (data) async {
      targetSocketId = data['from'] as String?;
      await initCall();

      await peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['offer']['sdp'], data['offer']['type']),
      );

      final answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);

      socket!.emit('answer-call', {
        'to': targetSocketId,
        'answer': answer.toMap(),
      });
    });

    socket!.on('call-answered', (data) async {
      await peerConnection!.setRemoteDescription(
        RTCSessionDescription(data['answer']['sdp'], data['answer']['type']),
      );
    });

    socket!.on('ice-candidate', (data) async {
      await peerConnection!.addCandidate(
        RTCIceCandidate(
          data['candidate']['candidate'],
          data['candidate']['sdpMid'],
          data['candidate']['sdpMLineIndex'],
        ),
      );
    });
  }

  void _handleComposerChanged() {
    if (!mounted) {
      return;
    }

    setState(() {});
    _emitTypingState(controller.text.trim().isNotEmpty);
  }

  void _emitTypingState(bool isTyping) {
    _typingDebounce?.cancel();
    if (socket?.connected != true) {
      return;
    }

    final payload = {'conversation': widget.args?.title ?? 'default'};
    if (!isTyping) {
      socket!.emit('stop_typing', payload);
      return;
    }

    socket!.emit('typing', payload);
    _typingDebounce = Timer(const Duration(milliseconds: 1200), () {
      if (socket?.connected == true) {
        socket!.emit('stop_typing', payload);
      }
    });
  }

  void _setPeerTyping(bool isTyping) {
    if (!mounted) {
      return;
    }
    setState(() => _isPeerTyping = isTyping);
  }

  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) {
      return;
    }
    if (socket?.connected != true) {
      _showSnackBar('Chat is not connected yet.');
      return;
    }

    socket!.emit('send_message', {'text': text});
    _emitTypingState(false);
    controller.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }

    await _showImageSendPreview(File(picked.path));
  }

  Future<void> _showImageSendPreview(File file) async {
    final shouldSend = await showChatImageSendPreviewSheet(context, file: file);

    if (shouldSend == true) {
      await uploadFile(file, 'image');
    }
  }

  Future<void> startRecording() async {
    if (!await recorder.hasPermission()) {
      _showSnackBar('Microphone permission is required.');
      return;
    }

    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}\\${DateTime.now().millisecondsSinceEpoch}.m4a';
    await recorder.start(const RecordConfig(), path: path);

    if (!mounted) {
      return;
    }
    setState(() => isRecording = true);
  }

  Future<void> stopRecording() async {
    final path = await recorder.stop();
    _emitTypingState(false);
    if (!mounted) {
      return;
    }

    setState(() => isRecording = false);
    if (path != null) {
      await uploadFile(File(path), 'audio');
    }
  }

  Future<void> uploadFile(File file, String type) async {
    if (socket?.connected != true) {
      _showSnackBar('Chat is not connected yet.');
      return;
    }

    setState(() => _isSendingMedia = true);

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/upload'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', file.path));
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody) as Map<String, dynamic>;

      socket!.emit('send_message', {type: data['url']});
      _emitTypingState(false);
    } catch (_) {
      _showSnackBar('Unable to upload media right now.');
    } finally {
      if (mounted) {
        setState(() => _isSendingMedia = false);
      }
    }
  }

  Future<void> playAudio(String url) async {
    try {
      if (_activeAudioUrl == url) {
        await player.stop();
        if (!mounted) {
          return;
        }
        setState(() => _activeAudioUrl = null);
        return;
      }

      await player.stop();
      if (mounted) {
        setState(() => _activeAudioUrl = url);
      }
      await player.play(UrlSource(url));
    } catch (_) {
      _showSnackBar('Unable to play this voice message.');
      if (mounted) {
        setState(() => _activeAudioUrl = null);
      }
    }
  }

  Future<void> initCall() async {
    peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    localRenderer.srcObject = localStream;
    if (mounted) {
      setState(() {});
    }

    for (final track in localStream!.getTracks()) {
      peerConnection!.addTrack(track, localStream!);
    }

    peerConnection!.onTrack = (event) {
      if (event.streams.isEmpty || !mounted) {
        return;
      }
      setState(() => remoteRenderer.srcObject = event.streams.first);
    };

    peerConnection!.onIceCandidate = (candidate) {
      socket!.emit('ice-candidate', {
        'to': targetSocketId,
        'candidate': candidate.toMap(),
      });
    };
  }

  Future<void> callUser() async {
    if (socket?.connected != true || socket?.id == null) {
      _showSnackBar('Call is not available until chat connects.');
      return;
    }

    targetSocketId = socket!.id;
    await initCall();

    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    socket!.emit('call-user', {'to': targetSocketId, 'offer': offer.toMap()});
  }

  void endCall() {
    peerConnection?.close();
    localStream?.dispose();
    peerConnection = null;
    localStream = null;
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
    if (mounted) {
      setState(() {});
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!scrollController.hasClients) {
        return;
      }

      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _openImagePreview(String imageUrl) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatImagePreviewScreen(imageUrl: imageUrl),
      ),
    );
  }

  List<ChatMessageItem> get _displayMessages {
    final fallbackMessages = _buildFallbackMessages();
    final messageMaps = messages.isNotEmpty ? messages : fallbackMessages;

    return messageMaps
        .map((message) => ChatMessageItem.fromMap(message))
        .toList(growable: false);
  }

  List<Map<String, dynamic>> _buildFallbackMessages() {
    final now = DateTime.now();

    return [
      {
        'text': 'Hey! I reworked the chat UI so it feels more like Telegram.',
        'user_id': -1,
        'created_at': now
            .subtract(const Duration(minutes: 28))
            .toIso8601String(),
      },
      {
        'text':
            'Nice. I wanted an actual chat environment, not a static image.',
        'user_id': userId ?? 1,
        'created_at': now
            .subtract(const Duration(minutes: 25))
            .toIso8601String(),
      },
      {
        'audio': 'https://example.com/sample-audio.m4a',
        'user_id': -1,
        'created_at': now
            .subtract(const Duration(minutes: 22))
            .toIso8601String(),
      },
      {
        'image':
            'https://images.unsplash.com/photo-1516321497487-e288fb19713f?auto=format&fit=crop&w=1200&q=80',
        'user_id': userId ?? 1,
        'created_at': now
            .subtract(const Duration(minutes: 20))
            .toIso8601String(),
      },
      {
        'text':
            'Perfect. This layout supports text, photos, voice notes, and calls.',
        'user_id': -1,
        'created_at': now
            .subtract(const Duration(minutes: 18))
            .toIso8601String(),
      },
    ];
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _typingDebounce?.cancel();
    _playerCompleteSubscription?.cancel();
    socket?.dispose();
    recorder.dispose();
    player.dispose();
    controller.dispose();
    scrollController.dispose();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appSettings = SettingsScope.of(context).value;
    final displayMessages = _displayMessages;
    final hasCallPreview =
        remoteRenderer.srcObject != null || localRenderer.srcObject != null;
    final chatArgs = widget.args;
    final title = chatArgs?.title ?? 'Saad Jones';
    final subtitle = _isPeerTyping
        ? 'typing...'
        : (chatArgs?.subtitle ?? 'online');
    final avatarLabel = chatArgs?.avatarLabel ?? 'SJ';
    final canSendText = controller.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: buildChatBackgroundDecoration(
                appSettings.chatBackgroundStyle,
              ),
            ),
          ),
          Positioned(
            top: 110,
            left: -30,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(52),
              ),
            ),
          ),
          Positioned(
            bottom: 170,
            right: -20,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFF111827).withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(60),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                children: [
                  ChatHeader(
                    title: title,
                    subtitle: subtitle,
                    avatarLabel: avatarLabel,
                    onBack: () {
                      FocusScope.of(context).unfocus();
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    onVideoCall: callUser,
                    onVoiceCall: callUser,
                  ),
                  if (_isPeerTyping)
                    Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: ChatTypingIndicator(label: '$title is typing...'),
                    ),
                  if (hasCallPreview)
                    ChatCallPreview(
                      localRenderer: localRenderer,
                      remoteRenderer: remoteRenderer,
                      onEndCall: endCall,
                    ),
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                            ),
                          )
                        : token == null
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.xxl),
                              child: Text(
                                'Your session is missing. Please sign in again to load chat.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        : ChatMessageList(
                            scrollController: scrollController,
                            messages: displayMessages,
                            currentUserId: userId,
                            activeAudioUrl: _activeAudioUrl,
                            onAudioPressed: playAudio,
                            onImagePressed: _openImagePreview,
                          ),
                  ),
                  ChatComposer(
                    controller: controller,
                    title: title,
                    canSendText: canSendText,
                    isRecording: isRecording,
                    isSendingMedia: _isSendingMedia,
                    onSubmitted: (_) => sendMessage(),
                    onAttachmentPressed: pickImage,
                    onCameraPressed: pickImage,
                    onPrimaryActionPressed: canSendText
                        ? sendMessage
                        : (isRecording ? stopRecording : startRecording),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
