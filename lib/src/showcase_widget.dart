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

import 'dart:ui';

import 'package:flutter/material.dart';

import '../showcaseview.dart';
import 'extensions.dart';

class ShowCaseWidget extends StatefulWidget {
  final WidgetBuilder builder;
  final VoidCallback? onFinish;
  final Function(int?, GlobalKey)? onStart;
  final Function(int?, GlobalKey)? onComplete;
  final bool autoPlay;
  final Duration autoPlayDelay;
  final bool autoPlayLockEnable;
  final double defaultBlur;

  const ShowCaseWidget({
    required this.builder,
    this.onFinish,
    this.onStart,
    this.onComplete,
    this.autoPlay = false,
    this.autoPlayDelay = const Duration(milliseconds: 2000),
    this.autoPlayLockEnable = false,
    this.defaultBlur = 2,
  });

  static ShowCaseWidgetState? of(BuildContext context) {
    final state = context.findAncestorStateOfType<ShowCaseWidgetState>();
    if (state != null) {
      return context.findAncestorStateOfType<ShowCaseWidgetState>();
    } else {
      throw Exception('Please provide ShowCaseView context');
    }
  }

  @override
  ShowCaseWidgetState createState() => ShowCaseWidgetState();
}

class ShowCaseWidgetState extends State<ShowCaseWidget> {
  final _changeWidget = WidgetNotifier();

  /// Shows the list of keys of [Showcase] widgets
  /// that are involved in ongoing showcase.
  ///
  /// This will give empty list if no showcase are playing.
  ///
  List<GlobalKey<ShowcaseState>> get ids => _ids.toList(growable: false);

  List<GlobalKey<ShowcaseState>> _ids = [];

  /// Shows list keys of all the children [Showcase] widgets.
  ///
  List<GlobalKey<ShowcaseState>> showcaseKeys = [];

  int? activeWidgetId;
  late bool autoPlay;
  late Duration autoPlayDelay;
  late bool autoPlayLockEnable;
  double defaultBlur = 0;
  late Path screenPath;

  @override
  void initState() {
    super.initState();
    autoPlayDelay = widget.autoPlayDelay;
    autoPlay = widget.autoPlay;
    autoPlayLockEnable = widget.autoPlayLockEnable;
    defaultBlur = widget.defaultBlur;
  }

  void registerKey(GlobalKey<ShowcaseState> key) {
    if (!showcaseKeys.contains(key)) {
      showcaseKeys.add(key);
    }
  }

  void startShowCase([List<GlobalKey<ShowcaseState>>? widgetIds]) async {
    _ids = widgetIds ?? showcaseKeys;

    if (_ids.isNotEmpty) {
      _ids[0].currentState?.showcase(
          autoPlay: widget.autoPlay, currentIndex: 0, sequence: _ids);
    }
  }

  void nextShowCase({
    List<GlobalKey<ShowcaseState>> sequence = const [],
    int keyIndex = -1,
    bool autoPlay = false,
  }) {
    if (sequence.isEmpty || keyIndex >= sequence.length || keyIndex < 0) {
      dismiss();
      return;
    }

    activeWidgetId = keyIndex;
    sequence[keyIndex].currentState?.showcase(
        sequence: sequence, currentIndex: keyIndex, autoPlay: autoPlay);
  }

  void dismiss() {
    _ids.clear();
    activeWidgetId = null;
    _changeWidget.reset();
  }

  void showcase({required Widget overlay}) => _changeWidget.value = overlay;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    screenPath = (Offset.zero & MediaQuery.of(context).size).getPath();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Builder(
          builder: widget.builder,
        ),
        ValueListenableBuilder<Widget>(
          valueListenable: _changeWidget,
          builder: (_, value, __) => value,
        ),
      ],
    );
  }
}

class WidgetNotifier extends ValueNotifier<Widget> {
  WidgetNotifier() : super(SizedBox.shrink());

  void reset() {
    value = SizedBox.shrink();
  }
}
