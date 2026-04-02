import 'package:flutter_test/flutter_test.dart';

import 'package:chatapp/features/home/presentation/controllers/home_controller.dart';
import 'package:chatapp/features/home/presentation/models/home_tab.dart';

void main() {
  test('selects and syncs tabs through HomeController', () {
    final controller = HomeController(initialTab: HomeTab.calls);

    expect(controller.value, HomeTab.calls);
    expect(controller.selectedIndex, 1);

    controller.selectTab(HomeTab.profile);
    expect(controller.value, HomeTab.profile);
    expect(controller.selectedIndex, 2);

    controller.syncInitialTab(HomeTab.settings);
    expect(controller.value, HomeTab.settings);
    expect(controller.selectedIndex, 3);

    controller.dispose();
  });
}
