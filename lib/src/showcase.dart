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

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'extensions.dart';
import 'get_position.dart';
import 'shape_clipper.dart';
import 'showcase_widget.dart';
import 'tooltip_widget.dart';

class Showcase extends StatefulWidget {
  @override
  final GlobalKey key;

  final Widget child;
  final String? title;
  final String? description;
  final ShapeBorder? shapeBorder;
  final TextStyle? titleTextStyle;
  final TextStyle? descTextStyle;
  final EdgeInsets contentPadding;
  final Color overlayColor;
  final double overlayOpacity;
  final Widget? container;
  final Color showcaseBackgroundColor;
  final Color textColor;
  final bool showArrow;
  final double? height;
  final double? width;
  final Duration animationDuration;
  final VoidCallback? onToolTipClick;
  final VoidCallback? onTargetClick;
  final bool disposeOnTap;
  final bool disableAnimation;
  final EdgeInsets overlayPadding;
  final bool addShowcasePadding;
  final double? blur;

  const Showcase({
    required this.key,
    required this.child,
    this.title,
    required this.description,
    this.shapeBorder,
    this.overlayColor = Colors.black45,
    this.overlayOpacity = 0.75,
    this.titleTextStyle,
    this.descTextStyle,
    this.showcaseBackgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.showArrow = true,
    this.onTargetClick,
    this.disposeOnTap = false,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.disableAnimation = false,
    this.contentPadding =
        const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
    this.onToolTipClick,
    this.overlayPadding = EdgeInsets.zero,
    this.addShowcasePadding = false,
    this.blur,
  })  : height = null,
        width = null,
        container = null,
        assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0,
            "overlay opacity should be >= 0.0 and <= 1.0.");

  const Showcase.withWidget({
    required this.key,
    required this.child,
    required this.container,
    required this.height,
    required this.width,
    this.title,
    this.description,
    this.shapeBorder,
    this.overlayColor = Colors.black45,
    this.overlayOpacity = 0.75,
    this.titleTextStyle,
    this.descTextStyle,
    this.showcaseBackgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.onTargetClick,
    this.disposeOnTap = false,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.disableAnimation = false,
    this.contentPadding = const EdgeInsets.symmetric(vertical: 8),
    this.overlayPadding = EdgeInsets.zero,
    this.addShowcasePadding = false,
    this.blur,
  })  : showArrow = false,
        onToolTipClick = null,
        assert(overlayOpacity >= 0.0 && overlayOpacity <= 1.0,
            "overlay opacity should be >= 0.0 and <= 1.0.");

  @override
  ShowcaseState createState() => ShowcaseState();
}

class ShowcaseState extends State<Showcase> with TickerProviderStateMixin {
  ShowCaseWidgetState? _ancestor;

  Timer? _timer;
  GetPosition? _position;
  OverlayEntry? _overlayEntry;

  List<GlobalKey<ShowcaseState>> _sequence = [];
  int _currentIndex = -1;
  bool _autoPlay = false;

  @override
  void dispose() {
    hideOverlay();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();

    if (_overlayEntry != null) {
      hideOverlay();
      showOverlay();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ancestor == null) {
      _ancestor = ShowCaseWidget.of(context);
      _ancestor?.registerKey(widget.key as GlobalKey<ShowcaseState>);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  bool get isShowingOverlay => _overlayEntry != null;

  void showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (context) {
        // To calculate the "anchor" point we grab the render box of
        // our parent Container and then we find the center of that box.
        final box = this.context.findRenderObject() as RenderBox;

        final topLeft = box.size.topLeft(box.localToGlobal(Offset.zero));

        final bottomRight =
            box.size.bottomRight(box.localToGlobal(Offset.zero));

        final anchorBounds = Rect.fromLTRB(
          topLeft.dx,
          topLeft.dy,
          bottomRight.dx,
          bottomRight.dy,
        );

        final anchorCenter = box.size.center(topLeft);

        final size = MediaQuery.of(context).size;

        _position = GetPosition(
          box: box,
          padding: widget.overlayPadding,
          screenWidth: size.width,
          screenHeight: size.height,
        );
        return _buildOverlayOnTarget(
            anchorCenter, anchorBounds.size, anchorBounds, size);
      },
    );

    Overlay.of(_ancestor?.context ?? context)!.insert(_overlayEntry!);
  }

  void hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }

  ///
  /// Starts the showcase of respected widget.
  ///
  void showcase({
    List<GlobalKey<ShowcaseState>> sequence = const [],
    int currentIndex = 0,
    bool autoPlay = false,
  }) {
    _ancestor!.widget.onStart?.call(currentIndex, widget.key);

    showOverlay();

    _sequence = sequence;
    _currentIndex = currentIndex;
    _autoPlay = autoPlay;

    if (autoPlay && sequence.isNotEmpty) {
      _timer = Timer(_ancestor!.autoPlayDelay, _next);
    }
  }

  /// When user taps on target
  ///
  void _onTargetTap() {
    _clearTimer();

    if (widget.disposeOnTap) {
      hideOverlay();
      _ancestor!.dismiss();
      widget.onTargetClick!();
    } else {
      (widget.onTargetClick ?? _next).call();
    }
  }

  /// when user taps on tooltip.
  ///
  void _onTooltipTap() {
    _clearTimer();
    if (widget.disposeOnTap) {
      hideOverlay();
      _ancestor!.dismiss();
    }
    widget.onToolTipClick?.call();
  }

  void _next() {
    if (_timer != null && _timer!.isActive) {
      if (_ancestor!.autoPlayLockEnable) {
        return;
      }
      _timer!.cancel();
    } else {
      _timer = null;
    }

    hideOverlay();

    _nextShowcase();
  }

  void _nextShowcase() {
    _ancestor!.widget.onComplete?.call(_currentIndex, widget.key);

    _ancestor!.nextShowCase(
      keyIndex: _currentIndex + 1,
      sequence: _sequence,
      autoPlay: _autoPlay,
    );
  }

  void _clearTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    } else {
      _timer = null;
    }
  }

  Widget _buildOverlayOnTarget(
    Offset offset,
    Size size,
    Rect rectBound,
    Size screenSize,
  ) {
    final blur = widget.blur == null ? _ancestor!.defaultBlur : widget.blur!;
    return Stack(
      children: [
        GestureDetector(
          onTap: _next,
          child: ClipPath(
            clipper: RRectClipper(
              innerPath: rectBound.getPath(
                isCircle: widget.shapeBorder == CircleBorder(),
                addPadding: widget.addShowcasePadding,
              ),
              outerPath: _ancestor!.screenPath,
            ),
            child: blur != 0
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      decoration: BoxDecoration(
                        color: widget.overlayColor,
                      ),
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: widget.overlayColor,
                    ),
                  ),
          ),
        ),
        _TargetWidget(
          offset: offset,
          size: size,
          onTap: _onTargetTap,
          shapeBorder: widget.shapeBorder,
        ),
        ToolTipWidget(
          position: _position,
          offset: offset,
          screenSize: screenSize,
          title: widget.title,
          description: widget.description,
          titleTextStyle: widget.titleTextStyle,
          descTextStyle: widget.descTextStyle,
          container: widget.container,
          tooltipColor: widget.showcaseBackgroundColor,
          textColor: widget.textColor,
          showArrow: widget.showArrow,
          contentHeight: widget.height,
          contentWidth: widget.width,
          onTooltipTap: _onTooltipTap,
          contentPadding: widget.contentPadding,
          disableAnimation: widget.disableAnimation,
          animationDuration: widget.animationDuration,
        ),
      ],
    );
  }
}

class _TargetWidget extends StatelessWidget {
  final Offset offset;
  final Size? size;
  final Animation<double>? widthAnimation;
  final VoidCallback? onTap;
  final ShapeBorder? shapeBorder;

  _TargetWidget({
    Key? key,
    required this.offset,
    this.size,
    this.widthAnimation,
    this.onTap,
    this.shapeBorder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: size!.height + 16,
            width: size!.width + 16,
            decoration: ShapeDecoration(
              shape: shapeBorder ??
                  RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
