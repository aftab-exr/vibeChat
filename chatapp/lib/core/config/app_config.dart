abstract final class AppConfig {
  static const String appName = 'VibeChat';

  // Dynamically load the URL from the .env file.
  // If the .env file is missing or BASE_URL is not set, it safely falls back to your local emulator IP.
  static String get baseUrl => 'https://vibechat-zd5y.onrender.com';
}
