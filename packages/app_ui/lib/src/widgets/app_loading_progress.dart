// ignore_for_file: public_member_api_docs

import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

class AppLoadingIndeterminate extends StatefulWidget {
  const AppLoadingIndeterminate({
    super.key,
  });

  @override
  State<AppLoadingIndeterminate> createState() =>
      AppLoadingIndeterminateState();
}

class AppLoadingIndeterminateState extends State<AppLoadingIndeterminate> {
  final _visible = ValueNotifier<bool>(false);
  final _opacity = ValueNotifier<double>(0);
  final _debouncer = Debouncer(milliseconds: 5000);

  @override
  void initState() {
    super.initState();

    // _visible = ValueNotifier(false);
    // _opacity = ValueNotifier(0);
  }

  void setVisibility({
    required bool visible,
    double? opacity,
    bool autoHide = true,
  }) {
    _visible.value = visible;
    _opacity.value = visible == false ? 1 : opacity ?? 1;
    if (!autoHide && !visible) return;
    _debouncer.run(() {
      _visible.value = false;
    });
  }

  @override
  void dispose() {
    _visible.dispose();
    _opacity.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return SafeArea(
    child: Center(
      child: AnimatedBuilder(
        animation: Listenable.merge([_opacity, _visible]),
        builder: (context, child) {
          return AnimatedOpacity(
            duration: 700.ms,
            opacity: _opacity.value,
            child: _visible.value
                ? CircularProgressIndicator(
                    strokeWidth: 5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color.alphaBlend(
                        AppColors.black.withOpacity(.5),
                        context.theme.colorScheme.primary,
                      ),
                    ),
                    backgroundColor: Color.alphaBlend(
                      AppColors.black.withOpacity(.45),
                      context.theme.colorScheme.secondaryContainer,
                    ),
                  )
                : const SizedBox.shrink(),
          );
        },
      ),
    ),
  );
}
}
/// {@template helper}
/// Helper class to get the width of the navigation sidebar.
/// {@endtemplate}
class Helper {
  const Helper._();

  /// Returns 0 if no navigation sidebar should be shown.
  static double getWidthNavigationSidebar(BuildContext context) {
    const screenPercent = 0.3;
    const maxWidthNavigation = 270;
    const minScreenWidth = 700;

    if (context.screenWidth < minScreenWidth) return 0;
    return (context.screenWidth * screenPercent > maxWidthNavigation
            ? maxWidthNavigation
            : context.screenWidth * screenPercent) +
        context.viewPadding.left;
  }

  /// Returns true if the navigation sidebar should be shown.
  static bool getIsFullScreen(BuildContext context) {
    return getWidthNavigationSidebar(context) > 0;
  }
}
