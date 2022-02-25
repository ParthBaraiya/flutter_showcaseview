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
  final bool dividerVisible;

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
    this.dividerVisible = true,
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
            child: TextButton(
              child: Text(
                'Previous',
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
        if (dividerVisible &&
            (previous.buttonVisible && next.buttonVisible ||
                previous.buttonVisible && stop.buttonVisible))
          VerticalDivider(
            thickness: dividerThickness,
            color: previous.verticalDividerColor,
          ),
        if (next.buttonVisible)
          Expanded(
            child: TextButton(
              child: Text(
                'Next',
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
        if (dividerVisible && next.buttonVisible && stop.buttonVisible)
          VerticalDivider(
            thickness: dividerThickness,
            color: next.verticalDividerColor,
          ),
        if (stop.buttonVisible)
          Expanded(
            child: TextButton(
              child: Text(
                'Stop',
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
  /// Color of button text.
  final Color textColor;

  /// Color of button background.
  final Color textButtonBgColor;

  /// Color of vertical divider.
  final Color verticalDividerColor;

  /// Callback on button tap.
  ///
  /// Note: Default callback will be overridden by this one.
  final VoidCallback? callback;

  /// Defines visibility of button.
  final bool buttonVisible;

  const ActionButtonConfig({
    this.textColor = const Color(0xffee5366),
    this.verticalDividerColor = const Color(0xffee5366),
    this.textButtonBgColor = Colors.transparent,
    this.callback,
    this.buttonVisible = true,
  });
}
