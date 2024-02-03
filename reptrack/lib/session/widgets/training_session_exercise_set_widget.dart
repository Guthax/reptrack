import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/session/controllers/session_controller.dart';

class TrainingSessionExerciseSetWidget extends StatefulWidget {
  SessionController controller = Get.find<SessionController>();

  Exercise exercise;
  int setNumber = 0;
  int weight = 0;
  int reps = 0;
  TrainingSessionExerciseSetWidget(this.exercise, this.setNumber, this.weight, this.reps);

  @override
  _TrainingSessionExerciseSetWidgetState createState() => _TrainingSessionExerciseSetWidgetState();

  

}

class _TrainingSessionExerciseSetWidgetState extends State<TrainingSessionExerciseSetWidget> {
  final weightTextController = TextEditingController();
  final repsTextController = TextEditingController();
  bool enabled = true;

@override
  Widget build(BuildContext context) {
    weightTextController.text = widget.weight.toString();
    repsTextController.text = widget.reps.toString();
    return Row(
              children: [
                Text(
                "Set ${widget.setNumber}: ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                )),
                Expanded(
                  child: TextField(
                    controller: weightTextController,
                    readOnly: !enabled,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                 Expanded(
                  child: TextField(
                    controller: repsTextController,
                    readOnly: !enabled,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Reps',
                      labelStyle: TextStyle(
                        color: Colors.white,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: enabled ? () {
                      setState(() {
                        enabled = false;
                        widget.weight = int.parse(weightTextController.text);
                        widget.reps = int.parse(repsTextController.text);
                        widget.controller.logSet(widget.exercise, widget.weight, widget.reps);
                      });
                  }: null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: Colors.green,
                    backgroundColor: Colors.white,
                  ),
                  child: enabled ? Text(
                    'Log set',
                    style: TextStyle(
                      color: Colors.blue,
                    ),
                  ) : Icon(Icons.check),
                ),
              ],
            );
  }

}