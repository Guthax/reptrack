import 'package:get/get.dart';
import 'package:realm/realm.dart';
import 'package:reptrack/data/schemas/schemas.dart';
import 'package:reptrack/schedules/controllers/schedules_controller.dart';

class AddScheduleController extends GetxController {
  SchedulesController controller = Get.find<SchedulesController>();
  
  RxString scheduleName = "".obs;
  RxInt scheduleNumWeeks = 6.obs;


  void submitSchedule() {
    WorkoutSchedule ws = WorkoutSchedule(ObjectId(), name: scheduleName.toString(), numWeeks: scheduleNumWeeks.toInt());
    controller.addSchedule(ws);
  }
}