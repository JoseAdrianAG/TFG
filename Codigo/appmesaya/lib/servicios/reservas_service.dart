import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservasService {
  static const String _baseUrl = 'https://10.0.2.2:3000';

  /// Obtiene todas las reservas del usuario actual
  static Future<List<Map<String, dynamic>>> obtenerReservasUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final usuarioId = prefs.getInt('usuario_id');

    if (token == null || usuarioId == null) {
      throw Exception('Usuario no autenticado');
    }

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final url = Uri.parse('$_baseUrl/reservas?usuario_id=$usuarioId');
      final request = await client.getUrl(url);
      request.headers.set('Authorization', 'Bearer $token');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(responseBody);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await prefs.clear();
        throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo');
      } else {
        throw Exception('Error al cargar reservas: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al conectar al servidor: $e');
    } finally {
      client.close();
    }
  }

  /// Crea una nueva reserva
  static Future<Map<String, dynamic>> crearReserva({
    required int restauranteId,
    required String nombreRestaurante,
    required DateTime fecha,
    required TimeOfDay hora,
    required int personas,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final usuarioId = prefs.getInt('usuario_id');

    if (token == null || usuarioId == null) {
      throw Exception('Usuario no autenticado');
    }

    // Primero verificamos disponibilidad
    final disponible = await _verificarDisponibilidad(
      restauranteId: restauranteId,
      fecha: fecha,
      hora: hora,
    );

    if (!disponible) {
      throw Exception('El restaurante ya tiene una reserva en ese horario');
    }

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final url = Uri.parse('$_baseUrl/reservas');
      final request = await client.postUrl(url);
      request.headers.set('Authorization', 'Bearer $token');
      request.headers.set('Content-Type', 'application/json');

      final horaFormateada =
          '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
      final fechaFormateada = DateFormat('yyyy-MM-dd').format(fecha);

      final reservaData = {
        'usuario_id': usuarioId,
        'restaurante_id': restauranteId,
        'nombre_restaurante': nombreRestaurante,
        'fecha': fechaFormateada,
        'hora': horaFormateada,
        'personas': personas,
      };

      request.write(jsonEncode(reservaData));
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        throw Exception('Error al crear reserva: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    } finally {
      client.close();
    }
  }

  /// Verifica si hay disponibilidad en un restaurante para una fecha y hora específicas
  static Future<bool> _verificarDisponibilidad({
    required int restauranteId,
    required DateTime fecha,
    required TimeOfDay hora,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Usuario no autenticado');
    }

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final fechaFormateada = DateFormat('yyyy-MM-dd').format(fecha);
      final horaFormateada =
          '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';

      final url = Uri.parse(
          '$_baseUrl/reservas/disponibilidad?restaurante_id=$restauranteId&fecha=$fechaFormateada&hora=$horaFormateada');
      final request = await client.getUrl(url);
      request.headers.set('Authorization', 'Bearer $token');

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        return data['disponible'] ?? false;
      } else {
        throw Exception(
            'Error al verificar disponibilidad: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    } finally {
      client.close();
    }
  }

  /// Elimina una reserva existente
  static Future<void> eliminarReserva(int reservaId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Usuario no autenticado');
    }

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final url = Uri.parse('$_baseUrl/reservas/$reservaId');
      final request = await client.deleteUrl(url);
      request.headers.set('Authorization', 'Bearer $token');

      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar reserva: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    } finally {
      client.close();
    }
  }

  // Obtine las horas disponibles para un restaurante en una fecha específica
  static Future<List<String>> obtenerHorasDisponibles(
      int restauranteId, DateTime fecha) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final formattedDate = DateFormat('yyyy-MM-dd').format(fecha);

    final url = Uri.parse(
        'https://10.0.2.2:3000/restaurantes/$restauranteId/horarios?fecha=$formattedDate');

    final client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    final request = await client.getUrl(url);
    request.headers.set('Authorization', 'Bearer $token');

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    client.close();

    if (response.statusCode == 200) {
      return List<String>.from(jsonDecode(body));
    } else {
      throw Exception('Error al obtener horas disponibles');
    }
  }
}
