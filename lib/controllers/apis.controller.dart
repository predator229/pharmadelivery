import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiController {
  String get baseUrl {
    final base = dotenv.env['API_BASE_URL'];
    final namespace = dotenv.env['API_NAMESPACE'];
    final prefix = dotenv.env['API_PREFIX'];

    if (base != null && base.isNotEmpty &&
        namespace != null && namespace.isNotEmpty &&
        prefix != null && prefix.isNotEmpty) {
      return "$base$namespace$prefix";
    } else {
      print('⚠️ Variables .env manquantes ou vides. Utilisation de l\'URL locale par défaut. apis.controller.dart');
      return 'http://192.168.1.215:5050/deliver/api/';
    }
  }
  ApiController();

  Future<dynamic> get(String endpoint) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(baseUrl + endpoint), headers: headers);
      return _processResponse(response);
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> get2(String url) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };

      final response = await http.get(Uri.parse(url), headers: headers);
      return _processResponse(response);
    } catch (e) {
      return null;
    }
  }


  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print('Headers: $headers');
      print('datas: $data');
      // return null;
      final response = await http.post(
        Uri.parse(baseUrl + endpoint),
        headers: headers,
        body: jsonEncode(data),
      );

      print('response: ${jsonEncode(response.body)}');

      return _processResponse(response);
    } catch (e) {
      return null;
    }

  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.put(
        Uri.parse(baseUrl + endpoint),
        headers: headers,
        body: jsonEncode(data),
      );
      return _processResponse(response);
    } catch (e) {
      return null;
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken(true);
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.delete(
        Uri.parse(baseUrl + endpoint),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      return null;
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }
}