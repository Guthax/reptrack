
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SchedulesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var favorites = ["Push Pull Legs 1", "Upper lower"];
    /*
    return ListView.builder(
             padding: const EdgeInsets.all(8),
             itemCount: favorites.length,
             itemBuilder: (BuildContext context, int index) {
               return Container(
          height: 50,
          color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
          child: Center(child: Text('${favorites[index]}')),
               );
             }
           );
    */
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add schedule',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is a snackbar')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            tooltip: 'Go to the next page',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Next page'),
                    ),
                    body: const Center(
                      child: Text(
                        'This is the next page',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  );
                },
              ));
            },
          ),
        ],
      ),
      body: ListView.builder(
             padding: const EdgeInsets.all(8),
             itemCount: favorites.length,
             itemBuilder: (BuildContext context, int index) {
               return Container(
          height: 50,
          color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
          child: Center(child: Text(favorites[index])),
               );
             }
          )
    );
  }
}