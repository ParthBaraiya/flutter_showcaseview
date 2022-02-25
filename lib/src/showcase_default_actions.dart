import 'package:flutter/material.dart';

import '../showcaseview.dart';
import 'utilities/_showcase_context_provider.dart';

class ShowCaseDefaultActions extends StatelessWidget {
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;
  final CrossAxisAlignment crossAxisAlignment;
  final TextDirection? textDirection;
  final VerticalDirection verticalDirection;
  final TextBaseline? textBaseline;
  final double? dividerThickness;
  final Color verticalDividerColor;

  final ActionButtonConfig next;
  final ActionButtonConfig previous;
  final ActionButtonConfig stop;

  final GlobalKey _key1 = GlobalKey();

  ShowCaseDefaultActions({
    Key? key,
    this.next = const ActionButtonConfig(),
    this.previous = const ActionButtonConfig(),
    this.stop = const ActionButtonConfig(),
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.textDirection,
    this.verticalDirection = VerticalDirection.down,
    this.textBaseline,
    this.dividerThickness = 1.0,
    this.verticalDividerColor = const Color(0xffee5366),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showcaseContext = ShowcaseContextProvider.of(context)?.context;

    return Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      verticalDirection: verticalDirection,
      crossAxisAlignment: crossAxisAlignment,
      key: _key1,
      textBaseline: textBaseline,
      textDirection: textDirection,
      children: [
        if (previous.buttonVisible)
          Expanded(
            child: TextButton.icon(
              icon: previous.icon ?? SizedBox.shrink(),
              label: Text(
                previous.text ?? 'Previous',
                style: TextStyle(color: previous.textColor),
              ),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      previous.textButtonBgColor)),
              onPressed: previous.callback ??
                  () {
                    if (showcaseContext != null &&
                        ShowCaseWidget.of(showcaseContext)!.ids != null) {
                      ShowCaseWidget.of(showcaseContext)!.prev();
                    }
                  },
            ),
          ),
        if (previous.buttonVisible && stop.buttonVisible ||
            previous.buttonVisible && next.buttonVisible)
          VerticalDivider(
            width: 1.0,
            thickness: dividerThickness,
            color: verticalDividerColor,
          ),
        if (stop.buttonVisible)
          Expanded(
            child: TextButton.icon(
              icon: previous.icon ?? SizedBox.shrink(),
              label: Text(
                stop.text ?? 'Stop',
                style: TextStyle(color: stop.textColor),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(stop.textButtonBgColor)),
              onPressed: stop.callback ??
                  () {
                    if (showcaseContext != null &&
                        ShowCaseWidget.of(showcaseContext)!.ids != null) {
                      ShowCaseWidget.of(showcaseContext)!.dismiss();
                    }
                  },
            ),
          ),
        if (stop.buttonVisible && next.buttonVisible)
          VerticalDivider(
            width: 1.0,
            thickness: dividerThickness,
            color: verticalDividerColor,
          ),
        if (next.buttonVisible)
          Expanded(
            child: TextButton.icon(
              icon: previous.icon ?? SizedBox.shrink(),
              label: Text(
                next.text ?? 'Next',
                style: TextStyle(color: next.textColor),
              ),
              style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(next.textButtonBgColor)),
              onPressed: next.callback ??
                  () {
                    if (showcaseContext != null &&
                        ShowCaseWidget.of(showcaseContext)!.ids != null) {
                      ShowCaseWidget.of(showcaseContext)!.completed(
                          ShowCaseWidget.of(showcaseContext)!.ids![
                              ShowCaseWidget.of(showcaseContext)!
                                      .activeWidgetId ??
                                  0]);
                    }
                  },
            ),
          ),
      ],
    );
  }

  double? getDefaultWidth() {
    return _key1.currentContext != null
        ? (_key1.currentContext!.findRenderObject() as RenderBox).size.width
        : null;
  }
}

class ActionButtonConfig {
  /// button text
  final String? text;

  /// button icon or image
  final Widget? icon;

  /// Color of button text.
  final Color textColor;

  /// Color of button background.
  final Color textButtonBgColor;

  /// Callback on button tap.
  ///
  /// Note: Default callback will be overridden by this one.
  final VoidCallback? callback;

  /// Defines visibility of button.
  final bool buttonVisible;

  const ActionButtonConfig({
    this.text,
    this.icon,
    this.textColor = const Color(0xffee5366),
    this.textButtonBgColor = Colors.transparent,
    this.callback,
    this.buttonVisible = true,
  });
}
