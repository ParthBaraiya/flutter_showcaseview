/*
 * Copyright © 2020, Simform Solutions
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

import 'package:flutter/material.dart';

class GetPosition {
  final RenderBox box;
  final EdgeInsets padding;
  final double? screenWidth;
  final double? screenHeight;

  double center = 0;
  Rect rect = Rect.zero;
  double bottom = 0;
  double top = 0;
  double left = 0;
  double right = 0;
  double height = 0;
  double width = 0;

  GetPosition(
      {required this.box,
      this.padding = EdgeInsets.zero,
      this.screenWidth,
      this.screenHeight}) {
    rect = _getRect();
    top = _getTop();
    left = _getLeft();
    right = _getRight();
    bottom = _getBottom();
    height = bottom - top;
    width = right - left;
    center = (left + right) / 2;
  }

  Rect _getRect() {
    final topLeft = box.size.topLeft(box.localToGlobal(Offset.zero));
    final bottomRight = box.size.bottomRight(box.localToGlobal(Offset.zero));

    final rect = Rect.fromLTRB(
      topLeft.dx - padding.left < 0 ? 0 : topLeft.dx - padding.left,
      topLeft.dy - padding.top < 0 ? 0 : topLeft.dy - padding.top,
      bottomRight.dx + padding.right > screenWidth!
          ? screenWidth!
          : bottomRight.dx + padding.right,
      bottomRight.dy + padding.bottom > screenHeight!
          ? screenHeight!
          : bottomRight.dy + padding.bottom,
    );
    return rect;
  }

  ///Get the bottom position of the widget
  double _getBottom() {
    final bottomRight = box.size.bottomRight(box.localToGlobal(Offset.zero));
    return bottomRight.dy + padding.bottom;
  }

  ///Get the top position of the widget
  double _getTop() {
    final topLeft = box.size.topLeft(box.localToGlobal(Offset.zero));
    return topLeft.dy - padding.top;
  }

  ///Get the left position of the widget
  double _getLeft() {
    final topLeft = box.size.topLeft(box.localToGlobal(Offset.zero));
    return topLeft.dx - padding.left;
  }

  ///Get the right position of the widget
  double _getRight() {
    final bottomRight = box.size.bottomRight(box.localToGlobal(Offset.zero));
    return bottomRight.dx + padding.right;
  }
}
