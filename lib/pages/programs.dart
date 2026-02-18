import 'package:flutter/material.dart';
import '../persistance/database.dart';

class ProgramsPage extends StatefulWidget {
  const ProgramsPage({super.key});

  @override
  State<ProgramsPage> createState() => _ProgramsPageState();
}

class _ProgramsPageState extends State<ProgramsPage> {
  final db = AppDatabase();
  List<Program> programs = [];

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    final data = await db.getAllPrograms();
    setState(() {
      programs = data;
    });
  }

  Future<void> _addProgram() async {
    await db.addProgram('New Program ${programs.length + 1}');
    _loadPrograms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programs')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Workouts',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: programs.length,
              itemBuilder: (context, index) {
                final program = programs[index];
                return ListTile(
                  leading: const Icon(Icons.fitness_center),
                  title: Text(program.name),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _addProgram,
      ),
    );
  }
}
