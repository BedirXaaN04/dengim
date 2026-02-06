import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../utils/log_service.dart';
import 'package:flutter/foundation.dart';

class CloudinaryService {
  // Demo amaçlı kamuya açık bir preset kullanıyoruz
  static const String _cloudName = "dl0sbmno0";
  static const String _uploadPreset = "dengim_preset";


  static Future<String?> uploadImage(XFile file) async {
    try {
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/upload");
      
      // Web ve mobil için farklı yükleme stratejisi
      http.MultipartRequest request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = _uploadPreset;
      
      if (kIsWeb) {
        // Web için bytes kullan
        final bytes = await file.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        ));
      } else {
        // Mobil için path kullan
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = jsonDecode(responseString);

      if (response.statusCode == 200) {
        LogService.i("Cloudinary upload success: ${jsonResponse['secure_url']}");
        return jsonResponse['secure_url'];
      } else {
        LogService.e("Cloudinary Upload Failed (Status: ${response.statusCode})");
        LogService.e("Response: $responseString");
        LogService.e("URL: $url");
        return null;
      }

    } catch (e) {
      LogService.e("Cloudinary Catch Error", e);
      return null;
    }
  }

  static Future<String?> uploadImageBytes(Uint8List bytes, {String filename = 'image.jpg'}) async {
    try {
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/upload");
      final request = http.MultipartRequest("POST", url);

      request.fields['upload_preset'] = _uploadPreset;
      
      // Upload raw bytes
      request.files.add(http.MultipartFile.fromBytes(
        'file', 
        bytes, 
        filename: filename
      ));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = jsonDecode(responseString);

      if (response.statusCode == 200) {
        LogService.i("Cloudinary bytes upload success: ${jsonResponse['secure_url']}");
        return jsonResponse['secure_url'];
      } else {
        LogService.e("Cloudinary Bytes Upload Failed (Status: ${response.statusCode})");
        LogService.e("Response: $responseString");
        return null;
      }
    } catch (e) {
      LogService.e("Cloudinary Bytes Catch Error", e);
      return null;
    }
  }
}


