import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class EncryptionService {
  /// 1. Generate a random AES key for this specific file
  static String generateBase64Key() {
    final key = enc.Key.fromSecureRandom(32); // 256-bit AES key
    return key.base64;
  }

  /// 2. Encrypt a file before uploading to Cloudinary
  static Future<File> encryptFile(File originalFile, String base64Key) async {
    final key = enc.Key.fromBase64(base64Key);
    final iv = enc.IV.fromSecureRandom(16); // Initialization Vector
    final encrypter = enc.Encrypter(enc.AES(key));

    // Read and encrypt
    final fileBytes = await originalFile.readAsBytes();
    final encrypted = encrypter.encryptBytes(fileBytes, iv: iv);

    // Combine IV and Encrypted Data (we need the IV later to decrypt)
    final encryptedBytesWithIV = [...iv.bytes, ...encrypted.bytes];

    // Save to temporary file for upload
    final tempDir = await getTemporaryDirectory();
    final encryptedFile = File('${tempDir.path}/temp_encrypted.enc');
    await encryptedFile.writeAsBytes(encryptedBytesWithIV);

    return encryptedFile;
  }

  /// 3. Download from Cloudinary and Decrypt back to memory
  static Future<Uint8List?> downloadAndDecrypt(String url, String? base64Key) async {
    if (base64Key == null) return null; // Can't decrypt without a key

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return null;

      final encryptedBytesWithIV = response.bodyBytes;

      // Extract IV (first 16 bytes) and the encrypted payload
      final iv = enc.IV(Uint8List.fromList(encryptedBytesWithIV.sublist(0, 16)));
      final encryptedBytes = encryptedBytesWithIV.sublist(16);

      // Decrypt
      final key = enc.Key.fromBase64(base64Key);
      final encrypter = enc.Encrypter(enc.AES(key));

      final decryptedBytes = encrypter.decryptBytes(
        enc.Encrypted(Uint8List.fromList(encryptedBytes)),
        iv: iv,
      );

      return Uint8List.fromList(decryptedBytes);
    } catch (e) {
      // ERROR HANDLING: In a real app, you might want to log this error or show a user-friendly message
      // print("Decryption error: $e");
      return null;
    }
  }
}