import 'dart:io';

import 'package:appmesaya/screens/BuscadorScreen.dart';
import 'package:appmesaya/screens/DetalleRestauranteScreen.dart';
import 'package:appmesaya/screens/FavoritosScreen.dart';
import 'package:appmesaya/screens/PerfilScreen.dart';
import 'package:appmesaya/screens/ReservasScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreenLogin extends StatefulWidget {
  const HomeScreenLogin({super.key});

  @override
  _HomeScreenLoginState createState() => _HomeScreenLoginState();
}

class _HomeScreenLoginState extends State<HomeScreenLogin> {
  List<dynamic> restaurantes = [];
  int _currentIndex = 0;
  @override
  void initState() {
    super.initState();
    fetchRestaurantes();
  }

  Future<void> fetchRestaurantes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) throw Exception('No autenticado');

    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final request = await client.getUrl(
        Uri.parse('https://10.0.2.2:3000/restaurantes'),
      );
      request.headers.set('Authorization', 'Bearer $token');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = jsonDecode(responseBody);
        setState(() {
          restaurantes = data;
        });
      } else {
        print('Error al obtener restaurantes: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión al cargar restaurantes: $e');
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
        // Ya estamos en Home, no necesitamos hacer nada
        return;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BuscadorScreen()),
        );
        return; // Retornamos para no actualizar el índice
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ReservasScreen()),
        );
        return; // Retornamos para no actualizar el índice
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FavoritosScreen()),
        );
        return; // Retornamos para no actualizar el índice
      case 4:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => PerfilScreen()),
        );
        return; // Retornamos para no actualizar el índice
    }
    setState(() {
      _currentIndex = index;
    });
  }

  Widget build(BuildContext context) {
    final mejoresValorados = restaurantes
        .where((rest) => rest['valoracion'] != null && rest['valoracion'] > 4.5)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bienvenido a MesaYa!',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                    height: 16.0), // Espaciado entre el texto y el título
                const Text(
                  'Recomendaciones:',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
              height: 8.0), // Espaciado entre el título y los cuadros
          SizedBox(
            height: 120.0, // Altura del carrusel
            child: ListView.builder(
                scrollDirection: Axis.horizontal, // Desplazamiento horizontal
                itemCount: restaurantes.length,
                itemBuilder: (context, index) {
                  final restaurante = restaurantes[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleRestauranteScreen(
                              restauranteId: restaurante['id']),
                        ),
                      );
                    },
                    child: Container(
                      width: 140.0,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.restaurant_menu,
                              size: 40, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            restaurante['nombre'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${restaurante['categoria']} – ${restaurante['valoracion']}⭐',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          ),
          const SizedBox(height: 16.0), // Espaciado entre el texto y el título
          const Text(
            'Mejores Valorados:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
              height: 8.0), // Espaciado entre el título y los cuadros
          SizedBox(
            height: 120.0, // Altura del carrusel
            child: ListView.builder(
                scrollDirection: Axis.horizontal, // Desplazamiento horizontal
                itemCount:
                    mejoresValorados.length > 5 ? 5 : mejoresValorados.length,
                itemBuilder: (context, index) {
                  final restaurante = mejoresValorados[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetalleRestauranteScreen(
                              restauranteId: restaurante['id']),
                        ),
                      );
                    },
                    child: Container(
                      width: 140.0,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, size: 40, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            restaurante['nombre'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${restaurante['categoria']} – ${restaurante['valoracion']}⭐',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
          )
        ],
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
