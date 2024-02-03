import 'package:flutter/material.dart';

   
class CurrentDateWidget extends StatelessWidget {

@override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now().toLocal();
    String formattedDate = "Todays date: ${currentDate.day}-${currentDate.month}-${currentDate.year}";

    return Card(
      color: Colors.blue,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          formattedDate,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
