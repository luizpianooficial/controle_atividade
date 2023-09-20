import 'package:flutter/material.dart';
import 'package:appgestao/paginas/home.dart';
import 'package:appgestao/paginas/concluidos.dart';
import 'dart:convert';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ValueNotifier<List<Demand>> demands = ValueNotifier<List<Demand>>([]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 94, 6, 153),
        backgroundColor: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(demands:demands), // Pass the value of demands
        '/completed': (context) => CompletedDemandsScreen(completedDemands: demands.value), // Pass the value of demands
      },
    );
  }
}
