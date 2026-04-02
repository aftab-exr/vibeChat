import 'package:flutter/material.dart';

import 'package:chatapp/features/settings/presentation/controllers/app_settings_controller.dart';

class SettingsScope extends InheritedNotifier<AppSettingsController> {
  const SettingsScope({
    super.key,
    required AppSettingsController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppSettingsController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SettingsScope>();
    assert(scope != null, 'SettingsScope is missing from the widget tree.');
    return scope!.notifier!;
  }
}
