library video_autoplay_list;

import 'package:flutter/material.dart';
import 'package:video_autoplay_list/autoplay_notifier.dart';

class AutoPlayList extends StatefulWidget {
  final int itemCount;

  /// height of each child
  final double itemExtent;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  final Key key;
  final Axis scrollDirection;

  /// animation duration when list scrolls to next video
  final Duration scrollDuration;

  /// animation curve when list scrolls to next video
  final Curve scrollCurve;

  AutoPlayList(
      {this.key,
      @required this.itemCount,
      @required this.itemExtent,
      @required this.itemBuilder,
      this.physics,
      this.shrinkWrap = false,
      this.scrollDirection = Axis.vertical,
      this.scrollDuration = const Duration(milliseconds: 500),
      this.scrollCurve = Curves.easeIn})
      : assert(itemCount != null, 'itemCount must not be null'),
        assert(itemExtent != null, 'itemExtent must not be null'),
        assert(itemBuilder != null, 'itemBuilder must not be null');

  @override
  _AutoPlayListState createState() => _AutoPlayListState();
}

class _AutoPlayListState extends State<AutoPlayList> {
  ScrollController _scrollController;
  final _notifier = AutoPlayNotifier();
  double _lastScrollPosition = 0.0;
  bool _isScrollNext = false;
  bool _isScrolling = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_listener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _notifier.nextVideoIndex,
      builder: (context, value, child) {
        if (!_isScrolling) _scrollNext(value);
        return ListView.builder(
          controller: _scrollController,
          key: widget.key,
          scrollDirection: widget.scrollDirection,
          shrinkWrap: widget.shrinkWrap,
          physics: widget.physics,
          itemExtent: widget.itemExtent,
          itemCount: widget.itemCount,
          itemBuilder: widget.itemBuilder,
        );
      },
    );
  }

  /// scroll to next
  void _scrollNext(int index) async {
    if (_scrollController.hasClients) {
      _isScrollNext = true;
      double offset = (widget.itemExtent * index) - widget.itemExtent / 2;
      if (offset >= _scrollController.position.maxScrollExtent) {
        offset = _scrollController.position.maxScrollExtent;
      }
      await _scrollController.animateTo(offset,
          duration: widget.scrollDuration, curve: widget.scrollCurve);
      _isScrollNext = false;
    }
  }

  /// scroll listener
  void _listener() {
    if (_isScrollNext) return;
    if (_scrollController.hasClients) {
      _isScrolling = true;

      // print(_lastScrollPosition);
      // print(_scrollController.position.pixels);
      // print(_scrollController.position.pixels / (widget.itemExtent));

      if (_lastScrollPosition - 10 <= _scrollController.position.pixels ||
          _scrollController.position.pixels <= _lastScrollPosition + 10) {
        _isScrolling = false;
        _notifier.setIndex(
            (_scrollController.position.pixels / (widget.itemExtent)).ceil());
      }
      _lastScrollPosition = _scrollController.position.pixels;
    }
  }
}
