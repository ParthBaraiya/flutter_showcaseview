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

import 'dart:math';

import 'package:flutter/material.dart';

import 'get_position.dart';
import 'measure_size.dart';

enum _CenterOrientation { above, below }

class ToolTipWidget extends StatefulWidget {
  final GetPosition? position;
  final Offset? offset;
  final Size? screenSize;
  final String? title;
  final String? description;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final Widget? container;
  final Color? tooltipColor;
  final Color? textColor;
  final bool? showArrow;
  final double? contentHeight;
  final double? contentWidth;
  final VoidCallback? onTooltipTap;
  final EdgeInsets? contentPadding;
  final Duration animationDuration;
  final bool disableAnimation;

  ToolTipWidget({
    Key? key,
    this.position,
    this.offset,
    this.screenSize,
    this.title,
    this.description,
    this.titleTextStyle,
    this.descTextStyle,
    this.container,
    this.tooltipColor,
    this.textColor,
    this.showArrow,
    this.contentHeight,
    this.contentWidth,
    this.onTooltipTap,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8),
    this.animationDuration = const Duration(milliseconds: 1000),
    this.disableAnimation = false,
  }) : super(key: key);

  @override
  _ToolTipWidgetState createState() => _ToolTipWidgetState();
}

class _ToolTipWidgetState extends State<ToolTipWidget>
    with SingleTickerProviderStateMixin {
  Offset? position;

  late Animation<double> _animation;
  late AnimationController _controller;

  bool _isArrowUp = false;

  @override
  void initState() {
    super.initState();
    position = widget.offset;

    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        }
        if (_controller.isDismissed) {
          if (!widget.disableAnimation) {
            _controller.forward();
          }
        }
      });

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentOrientation = findPositionForContent(position!);

    _isArrowUp = contentOrientation == _CenterOrientation.below;

    var contentOffsetMultiplier = 0.0;
    var contentY = 0.0;
    var paddingTop = 0.0;
    var paddingBottom = 0.0;

    if (_isArrowUp) {
      contentOffsetMultiplier = 1.0;
      contentY = widget.position!.bottom + (contentOffsetMultiplier * 3);
      paddingTop = 22.0;
    } else {
      contentOffsetMultiplier = -1.0;
      contentY = widget.position!.top + (contentOffsetMultiplier * 3);
      paddingBottom = 27.0;
    }

    final contentFractionalOffset = contentOffsetMultiplier.clamp(-1.0, 0.0);

    if (!widget.showArrow!) {
      paddingTop = 10;
      paddingBottom = 10;
    }

    if (widget.container == null) {
      return Stack(
        children: <Widget>[
          widget.showArrow! ? _getArrow(contentOffsetMultiplier) : Container(),
          Positioned(
            top: contentY,
            left: _getLeft(),
            right: _getRight(),
            child: FractionalTranslation(
              translation: Offset(0.0, contentFractionalOffset),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, contentFractionalOffset / 10),
                  end: Offset(0.0, 0.100),
                ).animate(_animation),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding:
                        EdgeInsets.only(top: paddingTop, bottom: paddingBottom),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: GestureDetector(
                        onTap: widget.onTooltipTap,
                        child: Container(
                          width: _getTooltipWidth(),
                          padding: widget.contentPadding,
                          color: widget.tooltipColor,
                          child: Column(
                            crossAxisAlignment: widget.title != null
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: <Widget>[
                              widget.title != null
                                  ? Text(
                                      widget.title!,
                                      style: widget.titleTextStyle ??
                                          Theme.of(context)
                                              .textTheme
                                              .headline6!
                                              .merge(TextStyle(
                                                  color: widget.textColor)),
                                    )
                                  : Container(),
                              Text(
                                widget.description!,
                                style: widget.descTextStyle ??
                                    Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .merge(
                                            TextStyle(color: widget.textColor)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          Positioned(
            left: _getSpace(),
            top: contentY - 10,
            child: FractionalTranslation(
              translation: Offset(0.0, contentFractionalOffset),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0.0, contentFractionalOffset / 10),
                  end: !widget.showArrow! && !_isArrowUp
                      ? Offset(0.0, 0.0)
                      : Offset(0.0, 0.100),
                ).animate(_animation),
                child: Material(
                  color: Colors.transparent,
                  child: GestureDetector(
                    onTap: widget.onTooltipTap,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: paddingTop,
                      ),
                      color: Colors.transparent,
                      child: Center(
                        child: MeasureSize(
                            onSizeChange: (size) {
                              setState(() {
                                var tempPos = position;
                                tempPos = Offset(
                                    position!.dx, position!.dy + size!.height);
                                position = tempPos;
                              });
                            },
                            child: widget.container),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _getArrow(double contentOffsetMultiplier) {
    final contentFractionalOffset = contentOffsetMultiplier.clamp(-1.0, 0.0);
    return Positioned(
      top: _isArrowUp ? widget.position!.bottom : widget.position!.top - 1,
      left: widget.position!.center - 24,
      child: FractionalTranslation(
        translation: Offset(0.0, contentFractionalOffset),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, contentFractionalOffset / 5),
            end: Offset(0.0, 0.150),
          ).animate(_animation),
          child: Icon(
            _isArrowUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            color: widget.tooltipColor,
            size: 50,
          ),
        ),
      ),
    );
  }

  Size _textSize(String text, TextStyle style) {
    final textPainter = (TextPainter(
            text: TextSpan(text: text, style: style),
            maxLines: 1,
            textScaleFactor: MediaQuery.of(context).textScaleFactor,
            textDirection: TextDirection.ltr)
          ..layout())
        .size;
    return textPainter;
  }

  bool isCloseToTopOrBottom(Offset position) {
    var height = 120.0;
    height = widget.contentHeight ?? height;
    return (widget.screenSize!.height - position.dy) <= height;
  }

  _CenterOrientation findPositionForContent(Offset position) {
    if (isCloseToTopOrBottom(position)) {
      return _CenterOrientation.above;
    } else {
      return _CenterOrientation.below;
    }
  }

  double _getTooltipWidth() {
    final titleStyle = widget.titleTextStyle ??
        Theme.of(context)
            .textTheme
            .headline6!
            .merge(TextStyle(color: widget.textColor));
    final descriptionStyle = widget.descTextStyle ??
        Theme.of(context)
            .textTheme
            .subtitle2!
            .merge(TextStyle(color: widget.textColor));
    final titleLength = widget.title == null
        ? 0
        : _textSize(widget.title!, titleStyle).width +
            widget.contentPadding!.right +
            widget.contentPadding!.left;
    final descriptionLength =
        _textSize(widget.description!, descriptionStyle).width +
            widget.contentPadding!.right +
            widget.contentPadding!.left;
    var maxTextWidth = max(titleLength, descriptionLength);
    if (maxTextWidth > widget.screenSize!.width - 20) {
      return widget.screenSize!.width - 20;
    } else {
      return maxTextWidth + 15;
    }
  }

  bool _isLeft() {
    final screenWidth = widget.screenSize!.width / 3;
    return screenWidth > widget.position!.center;
  }

  bool _isRight() {
    final screenWidth = (widget.screenSize!.width * 2) / 3;

    return screenWidth <= widget.position!.center;
  }

  double? _getLeft() {
    final tooltipWidth = _getTooltipWidth();

    if (_isLeft()) {
      var leftPadding = widget.position!.center - (tooltipWidth * 0.1);
      if (leftPadding + tooltipWidth > widget.screenSize!.width) {
        leftPadding = (widget.screenSize!.width - 20) - tooltipWidth;
      }
      if (leftPadding < 20) {
        leftPadding = 14;
      }
      return leftPadding;
    } else if (!(_isRight())) {
      return widget.position!.center - (tooltipWidth * 0.5);
    } else {
      return null;
    }
  }

  double? _getRight() {
    final tooltipWidth = _getTooltipWidth();

    if (_isRight()) {
      var rightPadding = widget.position!.center + (tooltipWidth / 2);
      if (rightPadding + tooltipWidth > widget.screenSize!.width) {
        rightPadding = 14;
      }
      return rightPadding;
    } else if (!(_isLeft())) {
      return widget.position!.center - (tooltipWidth * 0.5);
    } else {
      return null;
    }
  }

  double _getSpace() {
    var space = widget.position!.center - (widget.contentWidth! / 2);
    if (space + widget.contentWidth! > widget.screenSize!.width) {
      space = widget.screenSize!.width - widget.contentWidth! - 8;
    } else if (space < (widget.contentWidth! / 2)) {
      space = 16;
    }
    return space;
  }
}
