import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Cloudinary image upload service using unsigned upload preset.
class CloudinaryService {
  CloudinaryService._();
  static final CloudinaryService instance = CloudinaryService._();

  static const String _cloudName = 'ddbj9gzsr';
  static const String _uploadPreset = 'equippro_unsigned';

  static const String _uploadUrl =
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload';

  /// Upload a single [XFile] to Cloudinary and return the secure URL.
  Future<String> uploadImage(XFile file, {String? folder}) async {
    final bytes = await file.readAsBytes();
    return uploadBytes(bytes, fileName: file.name, folder: folder);
  }

  /// Upload raw bytes to Cloudinary and return the secure URL.
  Future<String> uploadBytes(
    Uint8List bytes, {
    String? fileName,
    String? folder,
  }) async {
    final uri = Uri.parse(_uploadUrl);
    final request = http.MultipartRequest('POST', uri);

    request.fields['upload_preset'] = _uploadPreset;
    if (folder != null) {
      request.fields['folder'] = folder;
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName ?? 'image.jpg',
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      debugPrint('Cloudinary upload failed: ${response.body}');
      throw Exception(
        'Cloudinary upload failed (${response.statusCode}): ${response.body}',
      );
    }

    final data = json.decode(response.body) as Map<String, dynamic>;
    final secureUrl = data['secure_url'] as String?;
    if (secureUrl == null) {
      throw Exception('No secure_url in Cloudinary response');
    }
    return secureUrl;
  }

  /// Upload multiple [XFile]s in parallel and return list of URLs.
  Future<List<String>> uploadMultiple(
    List<XFile> files, {
    String? folder,
  }) async {
    final futures = files.map((f) => uploadImage(f, folder: folder));
    return Future.wait(futures);
  }
}
