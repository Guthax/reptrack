import 'package:flutter/material.dart';

class TrainingSessionExerciseSetWidget extends StatefulWidget {
  int setNumber = 0;
  int weight = 0;
  int reps = 0;
  var callback;
  TrainingSessionExerciseSetWidget(this.setNumber, this.weight, this.reps, this.callback);

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
                      widget.callback(int.parse(weightTextController.text),int.parse(repsTextController.text));
                      setState(() {
                        enabled = false;
                        widget.weight = int.parse(weightTextController.text);
                        widget.reps = int.parse(repsTextController.text);
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