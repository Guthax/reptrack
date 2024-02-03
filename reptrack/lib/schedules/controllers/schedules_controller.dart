import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:reptrack/data/data_repository.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/schedules/controllers/workout_controller.dart';

class SchedulesController extends GetxController {
  DataRepository dataRepository = DataRepository();
  var schedules = <WorkoutSchedule>[].obs;

  @override
  onInit() async {
    super.onInit();
    dataRepository.fillDb();
    readSchedules();
  }

  void readSchedules() async {
    await Future.delayed(Duration(milliseconds: 500));
    schedules.assignAll(await dataRepository.getAllSchedules());
    update();
  }

  void addSchedule(WorkoutSchedule schedule) {
    dataRepository.addWorkoutSchedule(schedule);
    readSchedules();
  }

  void deleteWorkoutSchedule(WorkoutSchedule schedule) async {
    await dataRepository.deleteWorkoutSchedule(schedule);
    readSchedules();
  }


  void addWorkout(WorkoutSchedule schedule, Workout w) async {
    await dataRepository.addWorkoutToSchedule(schedule, w);
    print("workout added");
    readSchedules();
    Get.find<WorkoutController>().updateWorkouts(schedule);
  }
}