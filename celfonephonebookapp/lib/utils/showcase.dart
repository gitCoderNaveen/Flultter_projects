import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShowcaseService {
  static const String _prefsKey = 'seen_home_showcase_v1';

  static Future<void> showHomeShowcaseIfNeeded(
      BuildContext context,
      List<GlobalKey> targets, {
        bool force = false,
      }) async {

    if (targets.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getBool(_prefsKey) ?? false;

    if (seen && !force) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTutorial(context, targets);
      prefs.setBool(_prefsKey, true);
    });
  }

  static void _showTutorial(BuildContext context, List<GlobalKey> targets) {
    final List<TargetFocus> focusList = [];

    void addTarget(GlobalKey key, String title, String description,
        {ShapeLightFocus shape = ShapeLightFocus.RRect}) {
      if (key.currentContext == null) return;

      focusList.add(
        TargetFocus(
          identify: key.toString(),
          keyTarget: key,
          shape: shape,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(description,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (targets.isNotEmpty) {
      addTarget(
        targets[0],
        "Search",
        "Tap here to search firms, persons, products and brands.",
      );
    }
    if (targets.length > 1) {
      addTarget(
        targets[1],
        "Banners",
        "See top banners and festival animations here.",
      );
    }
    if (targets.length > 2) {
      addTarget(
        targets[2],
        "Quick Find",
        "Tap a tile to open results instantly.",
      );
    }

    if (focusList.isEmpty) return;

    // ✔ Correct constructor for v1.0.2
    TutorialCoachMark tutorialCoachMark = TutorialCoachMark(
      targets: focusList,
      colorShadow: Colors.black.withOpacity(0.8),
      opacityShadow: 0.8,
      textSkip: "SKIP",
      hideSkip: false,
      paddingFocus: 6,
      onFinish: () {},
      onSkip: () {
        // do something (analytics, cleanup...)
        return true; // return true to close, false to continue to next target
      },

      onClickTarget: (target) {},
    );

    // ✔ Correct show() for v1.0.2 (NO named parameters)
    tutorialCoachMark.show( context: context);
  }
}
