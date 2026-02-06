import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'native_downloads_service.dart';
import '../models/document_model.dart';
import '../../../../utils/network/retry.dart';
import '../../../../src/common/storage/token_storage.dart';

class DocumentsService {
  static const baseUrl = "https://udbconnect.com/api";
  final TokenStorage _tokenStorage = const TokenStorage();

  Future<DocumentsResponse> fetchDocuments() async {
    final token = await _tokenStorage.readToken();

    if (token == null) {
      throw Exception("No authentication token found");
    }

    final response = await retry(() async {
      return await http
          .get(
            Uri.parse("$baseUrl/documents"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 15));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return DocumentsResponse.fromJson(data);
    } else {
      throw Exception("Failed to fetch documents: ${response.body}");
    }
  }

  Future<Map<String, String>> downloadDocument(
    String downloadUrl,
    String fileName,
  ) async {
    // Use native Android implementation for better Downloads folder access
    if (Platform.isAndroid) {
      final nativeService = NativeDownloadsService();
      return await nativeService.downloadDocumentToPublicDownloads(
        downloadUrl,
        fileName,
      );
    }

    final token = await _tokenStorage.readToken();

    if (token == null) {
      throw Exception("No authentication token found");
    }

    // Request storage permission
    if (Platform.isAndroid) {
      // Request storage permission for file access
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

    // Get the downloads directory - try multiple locations for best accessibility
    Directory? directory;
    String? storageLocation;

    if (Platform.isAndroid) {
      try {
        // Use external_path package to get the Downloads directory
        final downloadsPath =
            await ExternalPath.getExternalStoragePublicDirectory(
              ExternalPath.DIRECTORY_DOWNLOAD,
            );
        directory = Directory(downloadsPath);
        storageLocation = 'System Downloads';

        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } catch (e) {
        // Final fallback to app Documents folder
        final externalStorage = await getExternalStorageDirectory();
        if (externalStorage != null) {
          directory = Directory('${externalStorage.path}/Documents');
          storageLocation = 'App Documents';
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        }
      }
    } else if (Platform.isIOS) {
      // For iOS, save to Documents directory which is accessible via Files app
      directory = await getApplicationDocumentsDirectory();
      directory = Directory('${directory.path}/Downloads');
      storageLocation = 'App Documents';
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
    }

    if (directory == null) {
      throw Exception("Could not access storage directory");
    }

    // Create file path
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    // Write the file
    await file.writeAsBytes(response.bodyBytes);

    // Verify the file was actually written and exists
    if (!await file.exists()) {
      throw Exception('File was not saved successfully');
    }

    // Get file size for verification
    final fileSize = await file.length();

    // Files saved to Downloads directory via external_path should be visible in Downloads app
    debugPrint(
      '📱 File saved to Downloads directory - should be visible in Downloads app',
    );

    debugPrint('📁 File downloaded successfully:');
    debugPrint('   File: $fileName');
    debugPrint('   Location: $storageLocation');
    debugPrint('   Path: $filePath');
    debugPrint('   Size: $fileSize bytes');
    debugPrint('   Directory: ${directory.path}');
    debugPrint('   File exists: ${await file.exists()}');

    // Schedule a check to see if the file still exists after a delay
    Future.delayed(const Duration(seconds: 5), () async {
      final stillExists = await file.exists();
      debugPrint('🔍 File check after 5 seconds:');
      debugPrint('   File: $fileName');
      debugPrint('   Still exists: $stillExists');
      if (stillExists) {
        final currentSize = await file.length();
        debugPrint('   Current size: $currentSize bytes');
      }
    });

    return {
      'filePath': filePath,
      'fileName': fileName,
      'directory': directory.path,
      'fileSize': fileSize.toString(),
      'storageLocation': storageLocation ?? 'Unknown',
      'accessibleForSharing': (storageLocation == 'System Downloads')
          .toString(),
    };
  }
}
