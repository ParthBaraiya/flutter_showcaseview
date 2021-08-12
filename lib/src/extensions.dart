import 'dart:ui';

extension ClipPathExtension on Rect {
  Path getPath({bool addPadding = false, bool isCircle = false}) {
    var path = Path();

    final rect = addPadding
        ? Rect.fromLTWH(left - 5, top - 5, width + 10, height + 10)
        : this;

    path.addRRect(
      RRect.fromRectAndRadius(
        rect,
        Radius.circular(isCircle ? rect.height / 2 : 5),
      ),
    );
    return path;
  }
}
