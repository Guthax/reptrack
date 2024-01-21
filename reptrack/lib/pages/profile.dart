
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var favorites = ["test", "hey"];
    return ListView.builder(
             padding: const EdgeInsets.all(8),
             itemCount: favorites.length,
             itemBuilder: (BuildContext context, int index) {
               return Container(
          height: 50,
          color: Color((math.Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
          child: Center(child: Text(favorites[index])),
               );
             }
           );
  }
}