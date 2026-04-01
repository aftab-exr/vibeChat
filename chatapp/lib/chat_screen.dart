import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_webrtc/flutter_webrtc.dart';

void main() {
  runApp(const MyApp());
}

const String baseUrl = "http://192.168.1.3:4000"; // 🔥 CHANGE THIS

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Map<String, dynamic>> messages = [];

  final controller = TextEditingController();
  final scrollController = ScrollController();

  IO.Socket? socket;
  String? token;
  int? userId;

  final recorder = AudioRecorder();
  final player = AudioPlayer();

  bool isRecording = false;

  // WebRTC
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  final localRenderer = RTCVideoRenderer();
  final remoteRenderer = RTCVideoRenderer();
  String? targetSocketId;

  @override
  void initState() {
    super.initState();
    controller.addListener(() => setState(() {}));
    localRenderer.initialize();
    remoteRenderer.initialize();
    initApp();
  }

  Future<void> initApp() async {
    await login();
    connectSocket();
    setupListeners();
  }

  Future<void> login() async {
    final res = await http.post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": "Aaftab",
        "password": "123456"
      }),
    );

    final data = jsonDecode(res.body);
    token = data['token'];
    userId = data['user']['id'];
  }

  void connectSocket() {
    socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .build(),
    );

    socket!.onConnect((_) {
      print("✅ Connected: ${socket!.id}");
    });
  }

  void setupListeners() {
    socket!.on("load_messages", (data) {
      setState(() {
        messages = List<Map<String, dynamic>>.from(data);
      });
    });

    socket!.on("receive_message", (data) {
      setState(() {
        messages.add(data);
      });
      scrollToBottom();
    });

    // CALL EVENTS
    socket!.on("incoming-call", (data) async {
      targetSocketId = data['from'];
      await initCall();

      await peerConnection!.setRemoteDescription(
        RTCSessionDescription(
          data['offer']['sdp'],
          data['offer']['type'],
        ),
      );

      var answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);

      socket!.emit("answer-call", {
        "to": targetSocketId,
        "answer": answer.toMap(),
      });
    });

    socket!.on("call-answered", (data) async {
      await peerConnection!.setRemoteDescription(
        RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        ),
      );
    });

    socket!.on("ice-candidate", (data) async {
      await peerConnection!.addCandidate(
        RTCIceCandidate(
          data['candidate']['candidate'],
          data['candidate']['sdpMid'],
          data['candidate']['sdpMLineIndex'],
        ),
      );
    });
  }

  // CHAT
  void sendMessage() {
    if (controller.text.trim().isEmpty) return;

    socket!.emit("send_message", {"text": controller.text});
    controller.clear();
  }

  // IMAGE
  Future<void> pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    uploadFile(File(picked.path), "image");
  }

  // AUDIO
  Future<void> startRecording() async {
    if (await recorder.hasPermission()) {
      await recorder.start(const RecordConfig());
      setState(() => isRecording = true);
    }
  }

  Future<void> stopRecording() async {
    final path = await recorder.stop();
    setState(() => isRecording = false);

    if (path != null) uploadFile(File(path), "audio");
  }

  // UPLOAD
  Future<void> uploadFile(File file, String type) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/upload"),
    );

    request.files.add(await http.MultipartFile.fromPath('file', file.path));

    var res = await request.send();
    var response = await res.stream.bytesToString();
    var data = jsonDecode(response);

    socket!.emit("send_message", {type: data['url']});
  }

  // PLAY AUDIO
  Future<void> playAudio(String url) async {
    await player.play(UrlSource(url));
  }

  // WEBRTC
  Future<void> initCall() async {
    peerConnection = await createPeerConnection({
      "iceServers": [
        {"urls": "stun:stun.l.google.com:19302"}
      ]
    });

    localStream = await navigator.mediaDevices.getUserMedia({
      "audio": true,
      "video": true,
    });

    localRenderer.srcObject = localStream;

    for (var track in localStream!.getTracks()) {
      peerConnection!.addTrack(track, localStream!);
    }

    peerConnection!.onTrack = (event) {
      remoteRenderer.srcObject = event.streams[0];
    };

    peerConnection!.onIceCandidate = (candidate) {
      socket!.emit("ice-candidate", {
        "to": targetSocketId,
        "candidate": candidate.toMap(),
      });
    };
  }

  Future<void> callUser() async {
    targetSocketId = socket!.id; // ⚠️ replace with other user id

    await initCall();

    var offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    socket!.emit("call-user", {
      "to": targetSocketId,
      "offer": offer.toMap(),
    });
  }

  void endCall() {
    peerConnection?.close();
    localStream?.dispose();
    localRenderer.srcObject = null;
    remoteRenderer.srcObject = null;
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    socket?.dispose();
    recorder.dispose();
    player.dispose();
    localRenderer.dispose();
    remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Vibe Chat"),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: callUser,
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: messages.length,
              itemBuilder: (context, i) {
                final msg = messages[i];
                final isMe = msg['user_id'] == userId;

                Widget content;

                if (msg['image'] != null) {
                  content = Image.network(msg['image'], width: 200);
                } else if (msg['audio'] != null) {
                  content = GestureDetector(
                    onTap: () => playAudio(msg['audio']),
                    child: const Icon(Icons.play_arrow, color: Colors.white),
                  );
                } else {
                  content = Text(msg['text'] ?? "",
                      style: const TextStyle(color: Colors.white));
                }

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: content,
                  ),
                );
              },
            ),
          ),

          // VIDEO VIEW
          SizedBox(
            height: 200,
            child: RTCVideoView(remoteRenderer),
          ),

          // INPUT BAR
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.image),
                onPressed: pickImage,
              ),
              IconButton(
                icon: Icon(isRecording ? Icons.stop : Icons.mic),
                onPressed:
                    isRecording ? stopRecording : startRecording,
              ),
              Expanded(child: TextField(controller: controller)),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: sendMessage,
              ),
            ],
          )
        ],
      ),
    );
  }
}