import 'package:appmesaya/screens/FavoritosScreen.dart';
import 'package:appmesaya/screens/HomeScreen.dart';
import 'package:appmesaya/screens/PerfilScreen.dart';
import 'package:appmesaya/screens/ReservasScreen.dart';
import 'package:appmesaya/screens/DetalleRestauranteScreen.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';

class BuscadorScreen extends StatefulWidget {
  const BuscadorScreen({super.key});

  @override
  _BuscadorScreenState createState() => _BuscadorScreenState();
}

class _BuscadorScreenState extends State<BuscadorScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _currentIndex = 1;

  List<dynamic> _restaurantes = [];
  List<dynamic> _filtrados = [];

  final List<Map<String, dynamic>> _circleData = [
    {'icon': Icons.local_bar, 'text': 'Bar'},
    {'icon': Icons.local_dining, 'text': 'Restaurante'},
    {'icon': Icons.fastfood, 'text': 'Hamburguesería'},
    {'icon': Icons.local_pizza, 'text': 'Pizzería'},
    {'icon': Icons.euro, 'text': 'Economico'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchRestaurantes();
  }

  Future<void> _fetchRestaurantes() async {
    HttpClient client = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);
    try {
      final request =
          await client.getUrl(Uri.parse('https://10.0.2.2:3000/restaurantes'));
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final List<dynamic> data = jsonDecode(responseBody);
        setState(() {
          _restaurantes = data;
          _filtrados = data;
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
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

  void _showRandomRestaurant() {
    final randomRestaurant = (_filtrados..shuffle()).first;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restaurante Sugerido'),
          content: Text(randomRestaurant['nombre']),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Buscador',
          style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                final query = value.toLowerCase();
                setState(() {
                  _filtrados = _restaurantes.where((r) {
                    final nombre = r['nombre']?.toLowerCase() ?? '';
                    final categoria = r['categoria']?.toLowerCase() ?? '';
                    return nombre.contains(query) || categoria.contains(query);
                  }).toList();
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Nombre de Restaurante, tipo de comida...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('¿Qué deseas comer hoy?',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          ),
          SizedBox(
            height: 120.0,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _circleData.length,
              itemBuilder: (context, index) {
                final item = _circleData[index];
                return GestureDetector(
                  onTap: () {
                    final categoria = item['text'].toLowerCase();
                    setState(() {
                      _filtrados = _restaurantes
                          .where((r) => (r['categoria']?.toLowerCase() ?? '')
                              .contains(categoria))
                          .toList();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: 100.0,
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(item['icon'], color: Colors.white, size: 35.0),
                            Text(
                              item['text'],
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filtrados.length,
              itemBuilder: (context, index) {
                final r = _filtrados[index];
                return ListTile(
                  title: Text(r['nombre']),
                  subtitle: Text(r['categoria']),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetalleRestauranteScreen(
                          restauranteId: r['id'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('¿No sabes qué elegir?',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                const Text('Sorpréndeme', style: TextStyle(fontSize: 16.0)),
                IconButton(
                  onPressed: _showRandomRestaurant,
                  icon: const Icon(Icons.casino),
                )
              ],
            ),
          ),
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
