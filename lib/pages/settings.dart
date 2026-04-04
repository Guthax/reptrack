import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/settings_controller.dart';
import 'package:reptrack/utils/app_theme.dart';

/// Settings page where users can configure app-wide preferences.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'UNITS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Obx(
              () => SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('kg')),
                  ButtonSegment(value: true, label: Text('lbs')),
                ],
                selected: {settings.useImperial.value},
                onSelectionChanged: (s) => settings.setImperial(s.first),
                showSelectedIcon: false,
              ),
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
