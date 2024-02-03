import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:reptrack/data/data_repository.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/schedules/controllers/workout_controller.dart';

/// Controller to handle all business logic regarding schedules.
class SchedulesController extends GetxController {
  DataRepository dataRepository = DataRepository();
  var schedules = <WorkoutSchedule>[].obs;

  @override
  onInit() async {
    super.onInit();
    dataRepository.fillDb();
    readSchedules();
  }

  /// CAlls datarepository to read schedules from the database and updated underlying widgets.
  void readSchedules() async {
    await Future.delayed(Duration(milliseconds: 500));
    schedules.assignAll(await dataRepository.getAllSchedules());
    update();
  }

  /// Calls datarepository to add [schedule] to the database and rereads schedules.
  void addSchedule(WorkoutSchedule schedule) {
    dataRepository.addWorkoutSchedule(schedule);
    readSchedules();
  }

  /// Calls datarepository to delete [schedule] from the database and rereads schedules.
  void deleteWorkoutSchedule(WorkoutSchedule schedule) async {
    await dataRepository.deleteWorkoutSchedule(schedule);
    readSchedules();
  }

  /// Adds [workout] to [schedule] and calls datarepository update the database and rereads schedules.
  /// Also calls workout controller to update workout for direct visiblity.
  void addWorkout(WorkoutSchedule schedule, Workout workout) async {
    await dataRepository.addWorkoutToSchedule(schedule, workout);
    print("workout added");
    readSchedules();
    Get.find<WorkoutController>().updateWorkouts(schedule);
  }
}