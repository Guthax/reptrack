import 'package:get/get.dart';

/// Controller for bottom navigation bar state.
///
/// Holds the currently selected tab index and exposes a single method to
/// change it. Registered as a permanent singleton in [main].
class NavigationController extends GetxController {
  /// The index of the currently visible bottom-nav tab.
  var selectedIndex = 0.obs;

  /// Switches the active tab to [index].
  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
