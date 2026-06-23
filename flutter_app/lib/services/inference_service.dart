import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config.dart';

/// Sends an image to the FastAPI backend and returns the prediction result.
///
/// Response shape matches what UploadScreen and ResultScreen expect:
///   { disease, confidence (0–100), symptoms, precautions, topPredictions }
class InferenceService {
  static Future<Map<String, dynamic>> predict(File imageFile) async {
    final uri = Uri.parse('${AppConfig.backendBaseUrl}/predict');

    final ext = imageFile.path.split('.').last.toLowerCase();
    final mime = ext == 'png' ? 'png' : 'jpeg';

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', mime),
      ));

    final http.StreamedResponse streamed;
    try {
      streamed = await request.send().timeout(const Duration(seconds: 60));
    } on SocketException {
      throw Exception(
        'Cannot reach the server. '
        'Make sure the backend is running and the IP in config.dart is correct.',
      );
    }

    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    // Try to extract a human-readable error from the FastAPI response
    String errorMsg = 'Prediction failed (HTTP ${response.statusCode})';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      errorMsg = (body['detail'] ?? body['error'] ?? errorMsg).toString();
    } catch (_) {}

    throw Exception(errorMsg);
  }
}
