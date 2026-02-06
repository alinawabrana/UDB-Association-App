import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import '../../../../utils/network/retry.dart';
import '../../../../src/common/storage/token_storage.dart';

class NativeDownloadsService {
  static const MethodChannel _channel = MethodChannel('native_downloads');
  final TokenStorage _tokenStorage = const TokenStorage();

  Future<Map<String, String>> downloadDocumentToPublicDownloads(
    String downloadUrl,
    String fileName,
  ) async {
    final token = await _tokenStorage.readToken();

    if (token == null) {
      throw Exception("No authentication token found");
    }

    // Request storage permission
    if (Platform.isAndroid) {
      final storagePermission = await Permission.storage.request();
      if (!storagePermission.isGranted) {
        throw Exception("Storage permission denied");
      }
    }

    final response = await retry(() async {
      return await http
          .get(
            Uri.parse(downloadUrl),
            headers: {"Accept": "*/*", "Authorization": "Bearer $token"},
          )
          .timeout(const Duration(seconds: 30));
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception("Failed to download document: ${response.body}");
    }

    try {
      // Use native Android method to save file to public Downloads
      final result = await _channel.invokeMethod('saveToDownloads', {
        'fileName': fileName,
        'fileBytes': response.bodyBytes,
      });

      debugPrint('📁 File downloaded successfully via native method:');
      debugPrint('   File: $fileName');
      debugPrint('   Location: Public Downloads (via MediaStore)');
      debugPrint('   Result: $result');

      return {
        'filePath': result['filePath'] ?? 'Unknown',
        'fileName': fileName,
        'directory': 'Public Downloads',
        'fileSize': response.bodyBytes.length.toString(),
        'storageLocation': 'Public Downloads (MediaStore)',
        'accessibleForSharing': 'true',
      };
    } catch (e) {
      debugPrint('⚠️ Native method failed: $e');
      throw Exception("Failed to save file using native method: $e");
    }
  }
}
