import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reptrack/controllers/settings_controller.dart';
import 'package:reptrack/main.dart';
import 'package:reptrack/utils/app_theme.dart';

class _Step {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  const _Step({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });
}

const _steps = [
  _Step(
    icon: Icons.fitness_center,
    iconColor: AppColors.primary,
    title: 'Welcome to RepTrack',
    body:
        'Your personal strength training companion. '
        'Track workouts, monitor progress, and hit new PRs. '
        'No ads. Ever.',
  ),
  _Step(
    icon: Icons.schedule,
    iconColor: AppColors.secondary,
    title: 'Build Your Programs',
    body:
        'Create training programs with custom exercises, '
        'sets, reps, and rest timers. Organise days exactly '
        'the way you train. Exercises are grouped by equipment, making for easy switching!',
  ),
  _Step(
    icon: Icons.play_circle_outline,
    iconColor: AppColors.success,
    title: 'Start a Workout',
    body:
        'Pick a program day and log every set as you go. '
        'Previous weights are pre-filled so you always know '
        'where to start.',
  ),
  _Step(
    icon: Icons.track_changes,
    iconColor: AppColors.secondary,
    title: 'Track Your Progress',
    body:
        'View weight-progress charts per exercise and log '
        'your bodyweight over time. See exactly how far '
        "you've come.",
  ),
  _Step(
    icon: Icons.monitor_weight_outlined,
    iconColor: AppColors.primary,
    title: 'Choose Your Units',
    body: 'Prefer pounds or kilos? Switch anytime in Settings!',
  ),
];

/// Full-screen onboarding shown to first-time users.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _current = 0;

  bool get _isLast => _current == _steps.length - 1;

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finish() {
    Get.find<SettingsController>().markOnboardingSeen();
    Get.off(() => const HomePage(), transition: Transition.fadeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text(
                  'Skip',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _steps.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (context, i) {
                  final step = _steps[i];
                  if (i == _steps.length - 1) {
                    return _UnitsStepPage(step: step);
                  }
                  return _StepPage(step: step);
                },
              ),
            ),
            _DotIndicator(count: _steps.length, current: _current),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _next,
                  child: Text(_isLast ? 'Get Started' : 'Next'),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  final _Step step;

  const _StepPage({required this.step});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: step.iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 52, color: step.iconColor),
          ),
          const SizedBox(height: 40),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitsStepPage extends StatelessWidget {
  final _Step step;

  const _UnitsStepPage({required this.step});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: step.iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 52, color: step.iconColor),
          ),
          const SizedBox(height: 40),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            step.body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Obx(
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
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _DotIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 20 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.outline,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
