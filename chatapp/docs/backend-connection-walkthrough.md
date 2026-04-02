# VibeChat Backend Connection Walkthrough

## Current setup

The Flutter app reads its backend URL from:

`lib/core/config/app_config.dart`

Current value:

```dart
static const String baseUrl = 'https://vibechat-po7i.onrender.com';
```

This single value is reused for:

- Login: `POST /login`
- Signup: `POST /register`
- Uploads: `POST /upload`
- Socket.io connection for chat and call signaling

## How the app connects

### Auth

Files:

- `lib/features/auth/data/auth_repository.dart`
- `lib/core/config/app_config.dart`

The app sends HTTP requests to:

- `${AppConfig.baseUrl}/login`
- `${AppConfig.baseUrl}/register`

### Chat and calls

Files:

- `lib/chat_screen.dart`
- `lib/core/config/app_config.dart`

The app opens a Socket.io connection using:

```dart
socket = io.io(
  AppConfig.baseUrl,
  io.OptionBuilder().setTransports(['websocket']).setAuth({
    'token': token,
  }).build(),
);
```

### Media uploads

File:

- `lib/chat_screen.dart`

Uploads go to:

```dart
Uri.parse('${AppConfig.baseUrl}/upload')
```

## How to switch to another server

### Option 1: Another hosted backend

1. Open `lib/core/config/app_config.dart`
2. Replace `baseUrl` with your new backend URL
3. Run:

```bash
flutter clean
flutter pub get
flutter run
```

Example:

```dart
static const String baseUrl = 'https://your-server.onrender.com';
```

### Option 2: Local backend on your machine

If your backend runs on your computer, do not use `localhost` on a physical Android device.

Use your machine LAN IP instead:

```dart
static const String baseUrl = 'http://192.168.1.10:4000';
```

Then:

1. Start backend
2. Make sure phone and computer are on the same Wi‑Fi
3. Allow port `4000` through firewall if needed
4. Run the Flutter app again

### Option 3: Android emulator

For an Android emulator, use:

```dart
static const String baseUrl = 'http://10.0.2.2:4000';
```

## Backend requirements

Your backend must support these routes/events:

### HTTP routes

- `GET /` optional health check
- `POST /register`
- `POST /login`
- `POST /upload`

### Socket.io events

- `load_messages`
- `receive_message`
- `send_message`
- `typing`
- `stop_typing`
- `incoming-call`
- `call-user`
- `answer-call`
- `call-answered`
- `ice-candidate`

## Current backend in this workspace

Backend file:

- `../chatapp_server/server.js`

Current backend behavior:

- Express server
- Socket.io for real-time chat/calls
- SQLite via `better-sqlite3`
- JWT auth
- Cloudinary upload storage

## Notes

- The app is not currently connected to `https://vibechat-zd5y.onrender.com` anywhere in source.
- The current source points to `https://vibechat-po7i.onrender.com`.
- If you still see the old server in a running app, it is likely from an older installed APK/build.
