import 'package:get/get.dart';

class NavigationController extends GetxController {
  // Use .obs to make the variable observable
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}