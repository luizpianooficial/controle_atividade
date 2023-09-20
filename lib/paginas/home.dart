import 'package:flutter/material.dart';
import 'package:appgestao/paginas/concluidos.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Demand {
  String assunto;
  bool solucionado;
  String tempo;

  Demand(this.assunto, this.solucionado, this.tempo);

  Map<String, dynamic> toJson() {
    return {
      'assunto': assunto,
      'solucionado': solucionado,
      'tempo': tempo,
    };
  }

  factory Demand.fromJson(Map<String, dynamic> json) {
    return Demand(
      json['assunto'],
      json['solucionado'],
      json['tempo'],
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ValueNotifier<List<Demand>> demands = ValueNotifier<List<Demand>>([]);

  MyApp() {
    _loadDemands();

    demands.addListener(() {
      _saveDemands();
    });
  }

  _loadDemands() async {
    final prefs = await SharedPreferences.getInstance();
    final demandsJson = prefs.getString('demands');

    if (demandsJson != null) {
      final List<dynamic> jsonList = json.decode(demandsJson);
      final List<Demand> loadedDemands = jsonList.map((e) => Demand.fromJson(e)).toList();

      demands.value.addAll(loadedDemands);
    }
  }

  _saveDemands() async {
    final prefs = await SharedPreferences.getInstance();
    final demandsJson = json.encode(demands.value);
    await prefs.setString('demands', demandsJson);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 94, 6, 153),
        backgroundColor: Colors.green,
      ),
      home: HomeScreen(demands: demands),
      routes: {
        '/completed': (context) => CompletedScreen(completedDemands: demands.value),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final ValueNotifier<List<Demand>> demands;
  final List<Demand> completedDemands = [];

  HomeScreen({
    required this.demands,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _addDemand(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddDemandScreen()),
    );

    if (result != null) {
      setState(() {
        widget.demands.value.add(result);
      });
    }
  }

  void _removeDemand(int index) {
    setState(() {
      final removedDemand = widget.demands.value.removeAt(index);
      widget.completedDemands.add(removedDemand);
    });
  }

  void _editDemand(int index, Demand updatedDemand) {
    setState(() {
      if (updatedDemand != null) {
        widget.demands.value[index] = updatedDemand;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Controle de atividades 📝',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 37, 3, 92),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 37, 3, 92),
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Atividades Concluídas'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompletedScreen(
                      completedDemands: widget.completedDemands,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: DemandList(demands: widget.demands.value, removeDemand: _removeDemand, editDemand: _editDemand),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addDemand(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 37, 3, 92),
      ),
    );
  }
}

class CompletedScreen extends StatelessWidget {
  final List<Demand> completedDemands;

  CompletedScreen({
    required this.completedDemands,
  });

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
      body: DemandList(
        demands: completedDemands,
        removeDemand: (_) {},
        editDemand: (int index, Demand updatedDemand) {
          // Logic for editing demand here
        },
      ),
    );
  }
}

class DemandList extends StatelessWidget {
  final List<Demand> demands;
  final Function(int) removeDemand;
  final Function(int, Demand) editDemand;

  DemandList({
    required this.demands,
    required this.removeDemand,
    required this.editDemand,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: demands.length,
      itemBuilder: (context, index) {
        final demand = demands[index];
        return Card(
          elevation: 2.0,
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(
              demand.assunto,
              style: TextStyle(
                color: Color.fromARGB(255, 37, 3, 92),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  margin: EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: demand.solucionado ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  'Status: ${demand.solucionado ? 'Solucionado' : 'Pendente'}, Tempo: ${demand.tempo}',
                  style: TextStyle(
                    color: Color.fromARGB(255, 37, 3, 92),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    removeDemand(index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () async {
                    final updatedDemand = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditDemandScreen(currentDemand: demand)),
                    );

                    if (updatedDemand != null) {
                      editDemand(index, updatedDemand);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddDemandScreen extends StatefulWidget {
  @override
  _AddDemandScreenState createState() => _AddDemandScreenState();
}

class _AddDemandScreenState extends State<AddDemandScreen> {
  final TextEditingController _assuntoController = TextEditingController();
  bool _solucionado = false;
  final TextEditingController _tempoController = TextEditingController();

  void _saveDemand(BuildContext context) {
    final assunto = _assuntoController.text;
    final tempo = _tempoController.text;

    if (assunto.isNotEmpty && tempo.isNotEmpty) {
      final newDemand = Demand(assunto, _solucionado, tempo);
      Navigator.pop(context, newDemand);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Adicionar Demanda',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 37, 3, 92),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _assuntoController,
              decoration: InputDecoration(
                labelText: 'Assunto',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Text('Solucionado:'),
                Checkbox(
                  value: _solucionado,
                  onChanged: (bool? value) {
                    if (value != null) {
                      setState(() {
                        _solucionado = value;
                      });
                    }
                  },
                  activeColor: Color.fromARGB(255, 37, 3, 92),
                ),
              ],
            ),
            TextFormField(
              controller: _tempoController,
              decoration: InputDecoration(
                labelText: 'Tempo Estimado',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveDemand(context);
              },
              child: Text(
                'Salvar',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 37, 3, 92),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditDemandScreen extends StatefulWidget {
  final Demand currentDemand;

  EditDemandScreen({
    required this.currentDemand,
  });

  @override
  _EditDemandScreenState createState() => _EditDemandScreenState();
}

class _EditDemandScreenState extends State<EditDemandScreen> {
  late TextEditingController _assuntoController;
  late bool _solucionado;
  late TextEditingController _tempoController;

  @override
  void initState() {
    super.initState();
    _assuntoController = TextEditingController(text: widget.currentDemand.assunto);
    _solucionado = widget.currentDemand.solucionado;
    _tempoController = TextEditingController(text: widget.currentDemand.tempo);
  }

  void _saveEditedDemand(BuildContext context) {
    final assunto = _assuntoController.text;
    final tempo = _tempoController.text;

    if (assunto.isNotEmpty && tempo.isNotEmpty) {
      final editedDemand = Demand(assunto, _solucionado, tempo);
      Navigator.pop(context, editedDemand);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Preencha todos os campos'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Demanda',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 37, 3, 92),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _assuntoController,
              decoration: InputDecoration(
                labelText: 'Assunto',
              ),
            ),
            SizedBox(height: 16.0),
            Row(
              children: <Widget>[
                Text('Solucionado:'),
                Checkbox(
                  value: _solucionado,
                  onChanged: (bool? value) {
                    if (value != null) {
                      setState(() {
                        _solucionado = value;
                      });
                    }
                  },
                  activeColor: Color.fromARGB(255, 37, 3, 92),
                ),
              ],
            ),
            TextFormField(
              controller: _tempoController,
              decoration: InputDecoration(
                labelText: 'Tempo Estimado',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _saveEditedDemand(context);
              },
              child: Text(
                'Salvar',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                primary: Color.fromARGB(255, 37, 3, 92),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
