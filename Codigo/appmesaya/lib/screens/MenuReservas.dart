import 'dart:convert';
import 'dart:io';

import 'package:appmesaya/servicios/reservas_service.dart';
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

    try {
      await ReservasService.crearReserva(
        restauranteId: widget.restaurante['id'],
        nombreRestaurante: widget.restaurante['nombre'],
        fecha: _fecha!,
        hora: _hora!,
        personas: _personas,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Reserva creada con éxito!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear reserva: ${e.toString()}')),
      );
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
