import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../utils/log_service.dart';

class CloudinaryService {
  // Demo amaçlı kamuya açık bir preset kullanıyoruz, 
  // ancak kendi hesabımı bağlayarak kalıcı hale getirebilirim.
  static const String _cloudName = "dmx9yvgvx"; // Geçici Cloudinary hesabı
  static const String _uploadPreset = "dengim_preset";

  static Future<String?> uploadImage(XFile file) async {
    try {
      final url = Uri.parse("https://api.cloudinary.com/v1_1/$_cloudName/image/upload");
      
      final request = http.MultipartRequest("POST", url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonResponse = jsonDecode(responseString);

      if (response.statusCode == 200) {
        return jsonResponse['secure_url'];
      } else {
        LogService.e("Cloudinary Upload Error: ${jsonResponse['error']['message']}");
        return null;
      }
    } catch (e) {
      LogService.e("Cloudinary Catch Error", e);
      return null;
    }
  }
}
