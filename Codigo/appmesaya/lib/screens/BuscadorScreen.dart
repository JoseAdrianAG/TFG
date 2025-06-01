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
  int _currentIndex = 1;
  List<dynamic> _restaurantes = [];
  List<dynamic> _filtrados = [];

  final List<Map<String, dynamic>> _circleData = [
    {'icon': Icons.local_bar, 'text': 'Bar'},
    {'icon': Icons.local_dining, 'text': 'Restaurante'},
    {'icon': Icons.fastfood, 'text': 'Hamburguesería'},
    {'icon': Icons.local_pizza, 'text': 'Pizzería'},
    {'icon': Icons.euro, 'text': 'Económico'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchRestaurantes();
  }

  Future<void> _fetchRestaurantes() async {
    HttpClient client = HttpClient()
      ..badCertificateCallback = ((_, __, ___) => true);

    try {
      final request =
          await client.getUrl(Uri.parse('https://10.0.2.2:3000/restaurantes'));
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final List<dynamic> data = jsonDecode(body);
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
      case 1:
        // Ya estamos en Buscador, no necesitamos hacer nada
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

  void _filtrarPorBusqueda(String query) {
    setState(() {
      _filtrados = _restaurantes.where((r) {
        final nombre = r['nombre']?.toLowerCase() ?? '';
        final categoria = r['categoria']?.toLowerCase() ?? '';
        return nombre.contains(query.toLowerCase()) ||
            categoria.contains(query.toLowerCase());
      }).toList();
    });
  }

  void _filtrarPorCategoria(String categoria) {
    setState(() {
      if (categoria.toLowerCase() == 'económico') {
        _filtrados = _restaurantes.where((r) {
          final rango = r['rango_precios']?.replaceAll('€', '') ?? '';
          final partes = rango.split('-');
          if (partes.length == 2) {
            final min = int.tryParse(partes[0].trim()) ?? 0;
            final max = int.tryParse(partes[1].trim()) ?? 0;
            return min >= 10 && max <= 20;
          }
          return false;
        }).toList();
      } else {
        _filtrados = _restaurantes
            .where((r) => (r['categoria']?.toLowerCase() ?? '')
                .contains(categoria.toLowerCase()))
            .toList();
      }
    });
  }

  void _showRandomRestaurant() {
    if (_filtrados.isEmpty) return;

    final random = (_filtrados..shuffle()).first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetalleRestauranteScreen(
          restauranteId: random['id'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              onChanged: _filtrarPorBusqueda,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o tipo...',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Filtrar por categoría:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _circleData.length,
              itemBuilder: (_, i) {
                final item = _circleData[i];
                return GestureDetector(
                  onTap: () => _filtrarPorCategoria(item['text']),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.orange.shade400,
                          child: Icon(item['icon'], color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(item['text'],
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500))
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 20),
          Expanded(
            child: _filtrados.isEmpty
                ? const Center(child: Text('No se encontraron resultados.'))
                : ListView.builder(
                    itemCount: _filtrados.length,
                    itemBuilder: (_, index) {
                      final r = _filtrados[index];
                      return ListTile(
                        leading: const Icon(Icons.restaurant),
                        title: Text(r['nombre']),
                        subtitle: Text(r['categoria']),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetalleRestauranteScreen(
                                  restauranteId: r['id']),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Icon(Icons.casino, color: Colors.blueAccent),
                const SizedBox(width: 8),
                const Text('¿No sabes qué elegir?',
                    style: TextStyle(fontSize: 16)),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _showRandomRestaurant,
                  icon: const Icon(Icons.shuffle),
                  label: const Text('Sorpréndeme'),
                ),
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
