import 'package:appmesaya/screens/BuscadorScreen.dart';
import 'package:appmesaya/screens/FavoritosScreen.dart';
import 'package:appmesaya/screens/HomeScreen.dart';
import 'package:appmesaya/screens/LoginScreen.dart';
import 'package:appmesaya/screens/PerfilScreen.dart';
import 'package:appmesaya/screens/ReservasScreen.dart';
import 'package:appmesaya/servicios/auth_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF3E0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFFF7A00),
          primary: Color(0xFFFF7A00),
          secondary: Color(0xFFFECE91),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Color(0xFF3E2723)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF8C42),
            foregroundColor: Colors.white,
          ),
        ),
      ),

      home: const HomeScreen(), // Define la pantalla inicial aquí
      routes: {
        '/home': (context) => const HomeScreen(),
        '/buscador': (context) => const BuscadorScreen(),
        '/reservas': (context) => const ReservasScreen(),
        '/favoritos': (context) => const FavoritosScreen(),
        '/perfil': (context) => const LoginScreen(),
      },
    );
  }
}
