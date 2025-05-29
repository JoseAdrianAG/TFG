import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuReservas extends StatefulWidget {
  final Map<String, dynamic> restaurante;

  const MenuReservas({super.key, required this.restaurante});

  @override
  State<MenuReservas> createState() => _MenuReservasState();
}

class _MenuReservasState extends State<MenuReservas> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _fecha;
  TimeOfDay? _hora;
  int _personas = 1;

  Future<void> _guardarReserva() async {
    if (_fecha == null || _hora == null) return;

    final String url = 'https://10.0.2.2:3000/reservas';

    final DateTime dateTime = DateTime.now();

    final DateTime horaFormateada =
        dateTime.copyWith(hour: _hora!.hour, minute: _hora!.minute, second: 0);

    final reservaData = {
      'usuario_id': '1', //Cambiar por ID del usuario
      'restaurante_id': widget.restaurante['id'].toString(),
      'nombre_restaurante': widget.restaurante['nombre'],
      'fecha': _fecha!.toIso8601String().split('T')[0],
      'hora': horaFormateada.toIso8601String().split('T')[1].split('.')[0],
      'personas': _personas.toString(),
    };

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final request = await client.postUrl(Uri.parse(url));
      request.headers
          .set('Authorization', 'Bearer $token'); //Para utilizar el token

      request.headers.set('content-type', 'application/json'); //Para pasar JSON

      final body = jsonEncode(reservaData);
      request.write(body);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Reserva guardada en servidor!')),
        );
        Navigator.pop(context);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Token expirado o inválido
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear(); // Limpiar el token
        throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo');
      } else {
        print('Error al guardar la reserva: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar la reserva')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fallo de conexión al servidor')),
      );
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text('Reservar en ${widget.restaurante['nombre']}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Fecha
              ListTile(
                title: Text(_fecha == null
                    ? 'Selecciona una fecha'
                    : 'Fecha: ${_fecha!.toLocal().toString().split(' ')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (fecha != null) setState(() => _fecha = fecha);
                },
              ),

              // Hora
              ListTile(
                title: Text(_hora == null
                    ? 'Selecciona una hora'
                    : 'Hora: ${_hora!.format(context)}'),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final hora = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (hora != null) setState(() => _hora = hora);
                },
              ),

              // Personas
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Personas'),
                value: _personas,
                items: List.generate(10, (i) => i + 1)
                    .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                    .toList(),
                onChanged: (value) {
                  if (value != null) setState(() => _personas = value);
                },
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarReserva,
                child: const Text('Confirmar reserva'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
