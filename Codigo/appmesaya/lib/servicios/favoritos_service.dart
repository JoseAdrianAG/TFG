import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

class FavoritosService {
  static const String _baseUrl = 'https://10.0.2.2:3000';

  /// Comprueba si el restaurante es favorito para el usuario actual
  static Future<bool> esFavorito(int restauranteId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('No autenticado');

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final request = await client.getUrl(
        Uri.parse('https://10.0.2.2:3000/favoritos/es-favorito/$restauranteId'),
      );
      request.headers.set('Authorization', 'Bearer $token');

      final response = await request.close();
      return response.statusCode == 200;
    } catch (e) {
      print('Error verificando favorito: $e');
      return false;
    } finally {
      client.close();
    }
  }

  /// Alterna el estado de favorito (añade o elimina)
  static Future<void> toggleFavorite(
      int restauranteId, String nombreRestaurante, bool agregar) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final usuarioId = prefs.getInt('usuario_id');

    if (token == null || usuarioId == null) {
      throw Exception('No autenticado');
    }

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final url = agregar
          ? Uri.parse('https://10.0.2.2:3000/favoritos')
          : Uri.parse(
              'https://10.0.2.2:3000/favoritos?usuario_id=$usuarioId&restaurante_id=$restauranteId');

      final request =
          agregar ? await client.postUrl(url) : await client.deleteUrl(url);

      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');

      if (agregar) {
        request.write(json.encode({
          'usuario_id': usuarioId,
          'restaurante_id': restauranteId,
          'nombre_restaurante': nombreRestaurante,
        }));
      }

      final response = await request.close();

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Error al actualizar favorito: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    } finally {
      client.close();
    }
  }

  /// Obtiene todos los restaurantes favoritos del usuario
  static Future<List<Map<String, dynamic>>> obtenerFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final usuarioId = prefs.getInt('usuario_id');
    if (usuarioId == null) {
      throw Exception('No se ha encontrado el ID del usuario');
    }
    if (token == null) {
      throw Exception('No autenticado');
    }

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    try {
      final url = Uri.parse('$_baseUrl/favoritos/usuario/$usuarioId');
      final request = await client.getUrl(url);
      request.headers.set('Authorization', 'Bearer $token');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception('Error al obtener favoritos: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al obtener favoritos: $e');
      return [];
    } finally {
      client.close();
    }
  }

  /// Obtiene los datos completos de un restaurante por su ID
  static Future<Map<String, dynamic>> obtenerDetallesRestaurante(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('No autenticado');

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final url = Uri.parse('$_baseUrl/restaurantes/$id');
      final request = await client.getUrl(url);
      request.headers.set('Authorization', 'Bearer $token');

      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        return jsonDecode(body);
      } else {
        throw Exception('Restaurante no encontrado');
      }
    } catch (e) {
      print('Error obteniendo detalles del restaurante: $e');
      rethrow;
    } finally {
      client.close();
    }
  }
}
