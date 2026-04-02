import 'package:flutter/foundation.dart';

import 'package:chatapp/features/home/presentation/models/home_tab.dart';

class HomeController extends ValueNotifier<HomeTab> {
  HomeController({HomeTab initialTab = HomeTab.inbox}) : super(initialTab);

  int get selectedIndex => HomeTab.values.indexOf(value);

  void selectTab(HomeTab tab) {
    if (value == tab) {
      return;
    }

    value = tab;
  }

  void syncInitialTab(HomeTab tab) {
    if (value == tab) {
      return;
    }

    value = tab;
  }
}
