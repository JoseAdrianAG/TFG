import 'dart:io';
import 'dart:convert';

import 'package:appmesaya/screens/MenuReservas.dart';
import 'package:appmesaya/servicios/favoritos_service.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetalleRestauranteScreen extends StatefulWidget {
  final int restauranteId;

  const DetalleRestauranteScreen({super.key, required this.restauranteId});

  @override
  State<DetalleRestauranteScreen> createState() =>
      _DetalleRestauranteScreenState();
}

class _DetalleRestauranteScreenState extends State<DetalleRestauranteScreen> {
  Map<String, dynamic>? restaurante;
  bool isFavorito = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final datos = await FavoritosService.obtenerDetallesRestaurante(
          widget.restauranteId);
      final favorito = await FavoritosService.esFavorito(widget.restauranteId);

      setState(() {
        restaurante = datos;
        isFavorito = favorito;
      });
    } catch (e) {
      print('Error cargando datos: $e');
    }
  }

  Future<void> _toggleFavorito() async {
    if (restaurante == null) return;

    try {
      await FavoritosService.toggleFavorite(
        restaurante!['id'],
        restaurante!['nombre'],
        !isFavorito,
      );
      setState(() => isFavorito = !isFavorito);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isFavorito ? 'Añadido a favoritos' : 'Eliminado de favoritos'),
        ),
      );
    } catch (e) {
      print('Error al actualizar favorito: $e');
    }
  }

  void _abrirEnMapa(double latitud, double longitud) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitud,$longitud';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'No se pudo abrir el mapa';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (restaurante == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final horario = restaurante!['horario'] as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurante!['nombre']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (restaurante!['imagen'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  restaurante!['imagen'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              restaurante!['nombre'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              restaurante!['categoria'],
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[700]),
                const SizedBox(width: 4),
                Text('${restaurante!['valoracion']}'),
                const SizedBox(width: 16),
                Text(restaurante!['rango_precios']),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Horario:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: horario.entries.map((entry) {
                final dia = entry.key;
                final horarioDia = entry.value;

                if (horarioDia is List) {
                  final franjas = horarioDia.map<String>((franja) {
                    final apertura = franja['apertura'];
                    final cierre = franja['cierre'];
                    return '$apertura - $cierre';
                  }).join(' / ');
                  return Text('$dia: $franjas',
                      style: const TextStyle(fontSize: 16));
                }

                final apertura = horarioDia['apertura'];
                final cierre = horarioDia['cierre'];
                return Text(
                  '$dia: ${apertura == "CERRADO" ? "CERRADO" : "$apertura - $cierre"}',
                  style: const TextStyle(fontSize: 16),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.phone),
                const SizedBox(width: 8),
                Text(restaurante!['telefono']),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on),
                const SizedBox(width: 8),
                Expanded(child: Text(restaurante!['direccion'])),
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: () => _abrirEnMapa(
                    restaurante!['latitud'],
                    restaurante!['longitud'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MenuReservas(restaurante: restaurante!),
                  ),
                );
              },
              child: const Text('Reservar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleFavorito,
        backgroundColor: Colors.white,
        child: Icon(
          isFavorito ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
        ),
      ),
    );
  }
}
