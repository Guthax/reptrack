import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/settings_controller.dart';
import 'package:reptrack/utils/app_palette.dart';
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
          const _SectionHeader('UNITS'),
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
          const _SectionHeader('THEME'),
          Obx(
            () => Column(
              children: [
                for (final entry in appPalettes.entries)
                  _ThemeOption(
                    palette: entry.value,
                    selected: settings.themeId.value == entry.key,
                    onTap: () async {
                      await settings.setTheme(entry.key);
                      await Get.forceAppUpdate();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(),
        ],
      ),
    );
  }
}

/// Small uppercase label that introduces a group of settings.
class _SectionHeader extends StatelessWidget {
  final String text;

  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Selectable row showing a theme's name and a preview of its main colors.
class _ThemeOption extends StatelessWidget {
  final AppPalette palette;

  /// Whether this theme is the active one.
  final bool selected;

  final VoidCallback onTap;

  const _ThemeOption({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _Swatch(palette.background),
                const SizedBox(width: 4),
                _Swatch(palette.primary),
                const SizedBox(width: 4),
                _Swatch(palette.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    palette.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small rounded square filled with [color].
class _Swatch extends StatelessWidget {
  final Color color;

  const _Swatch(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.outline),
      ),
    );
  }
}
