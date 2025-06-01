import 'package:appmesaya/screens/BuscadorScreen.dart';
import 'package:appmesaya/screens/DetalleRestauranteScreen.dart';
import 'package:appmesaya/screens/FavoritosScreen.dart';
import 'package:appmesaya/screens/HomeScreen.dart';
import 'package:appmesaya/screens/LoginScreen.dart';
import 'package:appmesaya/screens/PerfilScreen.dart';
import 'package:appmesaya/servicios/auth_service.dart';
import 'package:appmesaya/servicios/reservas_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:intl/intl.dart'; // <--- AÑADIDO

import 'package:shared_preferences/shared_preferences.dart';

class ReservasScreen extends StatefulWidget {
  const ReservasScreen({super.key});

  @override
  _ReservasScreenState createState() => _ReservasScreenState();
}

class _ReservasScreenState extends State<ReservasScreen> {
  int _currentIndex = 2;
  List<Map<String, dynamic>> reservas = [];

  @override
  void initState() {
    super.initState();
    _cargarReservasDesdeServidor();
  }

  Future<void> _cargarReservasDesdeServidor() async {
    try {
      final data = await ReservasService.obtenerReservasUsuario();
      setState(() {
        reservas = data;
      });
    } catch (e) {
      if (e.toString().contains('Sesión expirada')) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        }
      }
      print('Error al cargar reservas: $e');
    }
  }

  Future<void> _eliminarReserva(int id) async {
    try {
      await ReservasService.eliminarReserva(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva eliminada correctamente')),
      );
      await _cargarReservasDesdeServidor();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar reserva: ${e.toString()}')),
      );
    }
  }

  void _mostrarOpcionesReserva(Map<String, dynamic> reserva) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Cancelar reserva'),
                onTap: () {
                  Navigator.pop(context);
                  _eliminarReserva(reserva['id']);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        return;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BuscadorScreen()),
        );
        return;
      case 2:
        // Ya estamos en Reservas, no necesitamos hacer nada
        return;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FavoritosScreen()),
        );
        return;
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PerfilScreen()),
        );
        return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reservas',
          style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: reservas.isEmpty
          ? const Center(child: Text('No tienes ninguna reserva.'))
          : ListView.builder(
              itemCount: reservas.length,
              itemBuilder: (context, index) {
                final reserva = reservas[index];
                final fecha = DateTime.parse(reserva['fecha'])
                    .toLocal(); // Convertir a zona horaria local
                final fechaFormateada = DateFormat('dd/MM').format(fecha);
                final hora = reserva['hora'].toString().substring(0, 5);

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(reserva['nombre_restaurante'] ?? 'Restaurante'),
                    subtitle: Text(
                      'Personas: ${reserva['personas']}\n$fechaFormateada a las $hora',
                    ),
                    onTap: () {
                      _mostrarOpcionesReserva(reserva);
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Buscador',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Reservas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
