import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reptrack/global_states.dart';
import 'package:reptrack/pages/training_session.dart';
import 'package:reptrack/schemas/schemas.dart';


class WorkoutScheduleListCard extends StatelessWidget {
  final WorkoutSchedule schedule;

  const WorkoutScheduleListCard(this.schedule);

  @override
  Widget build(BuildContext context) {
    AppState state = context.watch<AppState>();
    return Card(
      elevation: 4.0,
      margin: EdgeInsets.all(10.0),
      color: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  schedule.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        color: Colors.white,
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        color: Colors.white,
                        onPressed: () {
                          _showDeleteConfirmationDialog(context, state);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditNameDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit"),
          content: Text("Are you sure you want to delete this schedule?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Perform the delete operation here
                // For now, let's just print a message
                print("Item deleted!");
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, AppState state) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Confirmation"),
          content: Text("Are you sure you want to delete this schedule?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Perform the delete operation here
                // For now, let's just print a message
                state.deleteWorkoutSchedule(schedule);
                print("Item deleted!");
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}

