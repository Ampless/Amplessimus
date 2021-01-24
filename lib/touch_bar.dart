import 'package:flutter/material.dart';
import 'package:touch_bar/touch_bar.dart';

import 'langs/language.dart';

void initTouchBar(TabController tabController) async {
  await setTouchBar(TouchBar(children: [
    TouchBarButton(
      label: Language.current.start,
      accessibilityLabel: Language.current.start,
      onClick: () => tabController.index = 0,
      icon: await TouchBarImage.loadFrom(path: 'assets/home.png'),
    ),
    TouchBarButton(
      label: Language.current.settings,
      accessibilityLabel: Language.current.settings,
      onClick: () => tabController.index = 1,
      icon: await TouchBarImage.loadFrom(path: 'assets/settings.png'),
    ),
  ]));
}
