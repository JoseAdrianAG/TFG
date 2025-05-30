import 'package:appmesaya/screens/BuscadorScreen.dart';
import 'package:appmesaya/screens/DetalleRestauranteScreen.dart';
import 'package:appmesaya/screens/FavoritosScreen.dart';
import 'package:appmesaya/screens/HomeScreenLogin.dart';
import 'package:appmesaya/screens/PerfilScreen.dart';
import 'package:appmesaya/screens/ReservasScreen.dart';
import 'package:appmesaya/servicios/auth_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  List<dynamic> restaurantes = [];

  @override
  void initState() {
    super.initState();
    connectToServer();
    _checkAuthentication();
  }

  Future<void> connectToServer() async {
    const String url = 'https://10.0.2.2:3000';
    try {
      HttpClient client = HttpClient()
        ..badCertificateCallback =
            ((X509Certificate cert, String host, int port) => true);
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode == 200) {
        print('Conectado al servidor exitosamente');
      } else {
        print('Error al conectar con el servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('Error de conexión al servidor: $e');
    }
  }

  Future<void> fetchRestaurantes() async {
    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    try {
      final request = await client.getUrl(
        Uri.parse('https://10.0.2.2:3000/restaurantes'),
      );

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

  Future<void> _checkAuthentication() async {
    final isLoggedIn = await AuthService.isAuthenticated();
    if (isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreenLogin()),
      );
    } else {
      await fetchRestaurantes();
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    switch (index) {
      case 0:
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
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final mejoresValorados = restaurantes
        .where((rest) => rest['valoracion'] != null && rest['valoracion'] > 4.5)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bienvenido a MesaYa',
          style: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Inicia sesión o regístrate para poder disfrutar de todas las funciones que te ofrecemos de manera fácil y sencilla.',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Recomendaciones:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 120.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: restaurantes.length,
              itemBuilder: (context, index) {
                final restaurante = restaurantes[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
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
              },
            ),
          ),
          const SizedBox(height: 16.0),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Mejores Valorados:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            height: 120.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount:
                  mejoresValorados.length > 5 ? 5 : mejoresValorados.length,
              itemBuilder: (context, index) {
                final restaurante = mejoresValorados[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
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
              },
            ),
          ),
        ],
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
