import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class AppConfig {
  static const String appName = 'VibeChat';
  
  // Dynamically load the URL from the .env file.
  // If the .env file is missing or BASE_URL is not set, it safely falls back to your local emulator IP.
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://10.0.2.2:3000';
}