import 'dart:io';
import 'package:appmesaya/screens/BuscadorScreen.dart';
import 'package:appmesaya/screens/DetalleRestauranteScreen.dart';
import 'package:appmesaya/screens/HomeScreen.dart';
import 'package:appmesaya/screens/PerfilScreen.dart';
import 'package:appmesaya/screens/ReservasScreen.dart';
import 'package:appmesaya/servicios/favoritos_service.dart';
import 'package:flutter/material.dart';

class FavoritosScreen extends StatefulWidget {
  const FavoritosScreen({super.key});

  @override
  _FavoritosScreenState createState() => _FavoritosScreenState();
}

class _FavoritosScreenState extends State<FavoritosScreen> {
  int _currentIndex = 3;
  List<Map<String, dynamic>> favoritos = [];

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    try {
      final data = await FavoritosService.obtenerFavoritos();
      setState(() {
        favoritos = data;
      });
    } catch (e) {
      print('Error al cargar favoritos: $e');
    }
  }

  Future<void> _eliminarFavorito(
      int restauranteId, String nombreRestaurante) async {
    try {
      await FavoritosService.toggleFavorite(
          restauranteId, nombreRestaurante, false);
      await _cargarFavoritos();
    } catch (e) {
      print('Error eliminando favorito: $e');
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ReservasScreen()),
        );
        return;
      case 3:
        // Ya estamos en Favoritos, no necesitamos hacer nada
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
          'Favoritos',
          style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: favoritos.isEmpty
          ? const Center(child: Text('No tienes restaurantes favoritos.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: favoritos.length,
              itemBuilder: (context, index) {
                final restaurante = favoritos[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(restaurante['nombre_restaurante'] ??
                        'Sin nombre de Restaurante'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarFavorito(
                          restaurante['restaurante_id'] as int,
                          restaurante['nombre'] ?? 'Sin nombre'),
                    ),
                    onTap: () {
                      final restauranteId = restaurante['restaurante_id'];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleRestauranteScreen(
                              restauranteId: restauranteId),
                        ),
                      );
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
