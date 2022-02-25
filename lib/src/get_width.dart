import 'package:flutter/material.dart';

class GetWidth {
  final GlobalKey? key1;
  final GlobalKey? key2;
  final double? buttonWidth;
  final EdgeInsets? contentPadding;

  GetWidth({
    this.key1,
    this.key2,
    this.buttonWidth,
    this.contentPadding = EdgeInsets.zero,
  });

  double getButtonsContainerWidth() {
    var defaultWidth = 260.0;

    if (buttonWidth != null) {
      return buttonWidth!;
    } else if (key1?.currentContext != null || key2?.currentContext != null) {
      var titleWidth = key1?.currentContext != null
          ? (key1?.currentContext?.findRenderObject() as RenderBox).size.width
          : 0.0;
      var descriptionWidth = key2?.currentContext != null
          ? (key2?.currentContext?.findRenderObject() as RenderBox).size.width
          : 0.0;
      var addExtraPadding = contentPadding!.left + contentPadding!.right;

      if (titleWidth < defaultWidth && descriptionWidth < defaultWidth) {
        return defaultWidth;
      } else if (titleWidth > descriptionWidth) {
        return titleWidth + addExtraPadding;
      } else {
        return descriptionWidth + addExtraPadding;
      }
    }
    return defaultWidth;
  }
}
