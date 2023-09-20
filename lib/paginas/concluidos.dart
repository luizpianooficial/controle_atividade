import 'package:flutter/material.dart';
import 'package:appgestao/paginas/home.dart';

class CompletedDemandsScreen extends StatelessWidget {
  final List<Demand> completedDemands;

  CompletedDemandsScreen({required this.completedDemands});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Atividades Concluídas ✅',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 37, 3, 92),
      ),
      body: ListView.builder(
        itemCount: completedDemands.length,
        itemBuilder: (context, index) {
          final completedDemand = completedDemands[index];
          return Card(
            elevation: 2.0,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(
                completedDemand.assunto,
                style: TextStyle(
                  color: Color.fromARGB(255, 37, 3, 92),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Status: Solucionado, Tempo: ${completedDemand.tempo}',
                style: TextStyle(
                  color: Color.fromARGB(255, 37, 3, 92),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
