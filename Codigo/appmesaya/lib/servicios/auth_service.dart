import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://10.0.2.2:3000';

  static Future<void> saveAuthData(String token, String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('username', username);
  }

  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, dynamic>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final username = prefs.getString('username');

    if (token == null) throw Exception('No hay token');

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final request = await client.getUrl(Uri.parse('$baseUrl/auth/protected'));
      request.headers.set('Authorization', 'Bearer $token');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        return {'username': username, 'data': json.decode(responseBody)};
      } else {
        throw Exception('Error al obtener datos del usuario');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  static Future<void> actualizarPerfil({
    required String username,
    String? password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) throw Exception('No autenticado');

    final client = HttpClient()
      ..badCertificateCallback = ((cert, host, port) => true);

    final request = await client.putUrl(
      Uri.parse('https://10.0.2.2:3000/auth/update'),
    );
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Content-Type', 'application/json');

    final body = {
      'nombre': username,
      if (password != null && password.isNotEmpty) 'contraseña': password,
    };

    request.write(jsonEncode(body));
    final response = await request.close();

    if (response.statusCode != 200) {
      final resp = await response.transform(utf8.decoder).join();
      throw Exception('Error al actualizar perfil: $resp');
    }

    // Actualiza el nombre en SharedPreferences
    await prefs.setString(
        'username', username); // Cambia 'nombre' por 'username'
  }
}
