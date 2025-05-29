import 'package:appmesaya/screens/BuscadorScreen.dart';
import 'package:appmesaya/screens/DetalleRestauranteScreen.dart';
import 'package:appmesaya/screens/FavoritosScreen.dart';
import 'package:appmesaya/screens/HomeScreen.dart';
import 'package:appmesaya/screens/PerfilScreen.dart';
import 'package:appmesaya/servicios/auth_service.dart';
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
    HttpClient client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;

    try {
      final url = Uri.parse('https://10.0.2.2:3000/reservas?usuario_id=1');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final request = await client.getUrl(url);
      request.headers.set('Authorization', 'Bearer $token');
      final response = await request.close();

      if (response.statusCode == 200) {
        final jsonString = await response.transform(utf8.decoder).join();
        final List<dynamic> data = json.decode(jsonString);

        setState(() {
          reservas = data.cast<Map<String, dynamic>>();
        });
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        throw Exception('Sesión expirada. Por favor, inicia sesión de nuevo');
      } else {
        print('Error al cargar reservas: ${response.statusCode}');
      }
    } catch (e) {
      print('Fallo al conectar al servidor: $e');
    } finally {
      client.close();
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
                leading: const Icon(Icons.edit),
                title: const Text('Editar reserva'),
                onTap: () {
                  Navigator.pop(context);
                  // Aquí podrías abrir una pantalla para editar:
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => EditarReservaScreen(reserva)));
                },
              ),
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

  Future<void> _eliminarReserva(int id) async {
    final url = Uri.parse('https://10.0.2.2:3000/reservas/$id');
    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final request = await client.deleteUrl(url);
      request.headers.set('Content-Type', 'application/json');
      final response = await request.close();

      if (response.statusCode == 200) {
        print('Reserva eliminada');
        // Refresca la lista
        await _cargarReservasDesdeServidor();
      } else {
        print('Error al eliminar reserva: ${response.statusCode}');
      }
    } catch (e) {
      print('Error eliminando reserva: $e');
    } finally {
      client.close();
    }
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
                final fecha = DateTime.tryParse(reserva['fecha']);
                final fechaFormateada = fecha != null
                    ? DateFormat('dd/MM/yyyy').format(fecha)
                    : reserva['fecha'];
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
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscador'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Reservas'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
