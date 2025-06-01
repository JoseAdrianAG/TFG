import 'dart:convert';
import 'dart:io';

import 'package:appmesaya/servicios/reservas_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class MenuReservas extends StatefulWidget {
  final Map<String, dynamic> restaurante;

  const MenuReservas({super.key, required this.restaurante});

  @override
  State<MenuReservas> createState() => _MenuReservasState();
}

class _MenuReservasState extends State<MenuReservas> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _fecha;
  String? _horaSeleccionada;
  int _personas = 1;
  List<String> _horasDisponibles = [];
  bool _cargandoHoras = false;

  Future<void> _guardarReserva() async {
    if (_fecha == null || _horaSeleccionada == null) return;

    final partesHora = _horaSeleccionada!.split(':');
    final hora = TimeOfDay(
      hour: int.parse(partesHora[0]),
      minute: int.parse(partesHora[1]),
    );

    try {
      await ReservasService.crearReserva(
        restauranteId: widget.restaurante['id'],
        nombreRestaurante: widget.restaurante['nombre'],
        fecha: _fecha!,
        hora: hora,
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

  Future<void> _cargarHorasDisponibles(DateTime fecha) async {
    setState(() {
      _cargandoHoras = true;
      _horaSeleccionada = null;
      _horasDisponibles = [];
    });

    try {
      final horas = await ReservasService.obtenerHorasDisponibles(
        widget.restaurante['id'],
        fecha,
      );
      setState(() {
        _horasDisponibles = horas;
      });
    } catch (e) {
      print('Error al cargar horas disponibles: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar las horas')),
      );
    } finally {
      setState(() {
        _cargandoHoras = false;
      });
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
                    : 'Fecha: ${DateFormat('dd/MM/yyyy').format(_fecha!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (fecha != null) {
                    setState(() => _fecha = fecha.toLocal());
                    await _cargarHorasDisponibles(fecha);
                  }
                },
              ),
              _cargandoHoras
                  ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    )
                  : DropdownButtonFormField<String>(
                      decoration:
                          const InputDecoration(labelText: 'Hora disponible'),
                      items: _horasDisponibles
                          .map((hora) =>
                              DropdownMenuItem(value: hora, child: Text(hora)))
                          .toList(),
                      value: _horaSeleccionada,
                      onChanged: (value) {
                        setState(() => _horaSeleccionada = value);
                      },
                      validator: (value) =>
                          value == null ? 'Selecciona una hora' : null,
                    ),

              const SizedBox(height: 16),

              // Personas
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Personas'),
                value: _personas,
                items: List.generate(12, (i) => i + 1)
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
