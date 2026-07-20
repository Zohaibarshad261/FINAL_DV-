import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/report.dart';
import '../models/doctor.dart';

/// All HTTP calls to the Flask backend.
class ApiService {
  static final String _base = AppConfig.backendBaseUrl;

  // ---------------------------------------------------------------------------
  // POST /predict
  // ---------------------------------------------------------------------------
  static Future<Map<String, dynamic>> predict({
    required File imageFile,
    required String userId,
  }) async {
    final uri = Uri.parse('$_base/predict');
    final request = http.MultipartRequest('POST', uri)
      ..fields['user_id'] = userId
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    final err = jsonDecode(response.body);
    throw Exception(err['error'] ?? 'Prediction failed (${response.statusCode})');
  }

  // ---------------------------------------------------------------------------
  // GET /reports?user_id=xxx
  // ---------------------------------------------------------------------------
  static Future<List<Report>> getReports(String userId) async {
    final uri = Uri.parse('$_base/reports?user_id=$userId');
    final response = await http.get(uri).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['reports'] as List<dynamic>;
      return list.map((e) => Report.fromJson(e as Map<String, dynamic>)).toList();
    }
    final err = jsonDecode(response.body);
    throw Exception(err['error'] ?? 'Failed to load reports');
  }

  // ---------------------------------------------------------------------------
  // POST /doctors
  // ---------------------------------------------------------------------------
  static Future<List<Doctor>> findDoctors({
    required String disease,
    required double lat,
    required double lng,
  }) async {
    final uri = Uri.parse('$_base/doctors');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'disease': disease, 'lat': lat, 'lng': lng}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final list = data['doctors'] as List<dynamic>;
      return list.map((e) => Doctor.fromJson(e as Map<String, dynamic>)).toList();
    }
    final err = jsonDecode(response.body);
    throw Exception(err['detail'] ?? err['error'] ?? 'Failed to find doctors (${response.statusCode})');
  }

  // ---------------------------------------------------------------------------
  // POST /chat
  // ---------------------------------------------------------------------------
  static Future<String> chat({
    required String message,
    required String diseaseContext,
    String language = 'en',
    List<Map<String, String>> history = const [],
  }) async {
    final uri = Uri.parse('$_base/chat');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': message,
            'disease_context': diseaseContext,
            'language': language,
            'history': history,
          }),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['reply'] as String;
    }
    final err = jsonDecode(response.body);
    throw Exception(err['detail'] ?? err['error'] ?? 'Chat request failed (${response.statusCode})');
  }

  // ---------------------------------------------------------------------------
  // POST /translate
  // ---------------------------------------------------------------------------
  static Future<String> translate({
    required String text,
    required String targetLanguage,
  }) async {
    final uri = Uri.parse('$_base/translate');
    final response = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'text': text, 'target_language': targetLanguage}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['translated_text'] as String;
    }
    final err = jsonDecode(response.body);
    throw Exception(err['error'] ?? 'Translation failed');
  }
}
