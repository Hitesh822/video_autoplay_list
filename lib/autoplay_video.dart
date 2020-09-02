import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_autoplay_list/autoplay_notifier.dart';
import 'package:video_player/video_player.dart';

class AutoPlayVideo extends StatefulWidget {
  /// video url
  final String network;

  /// video asset
  final String asset;

  /// video file (only supported in android and iOS)
  final File file;

  /// set whether video plays again and again
  final bool looping;

  /// set whether video plays automatically after loading
  final bool autoPlay;

  /// time jumps (in seconds) on fast-forward or fast-rewind
  final int timeJumps;

  /// height of the video player
  final double height;

  /// width of the video player
  final double width;

  /// loader to display while video loads
  final Widget loader;

  /// used for list of videos
  final int index;

  AutoPlayVideo(
      {this.network,
      this.asset,
      this.file,
      this.looping = false,
      this.autoPlay = true,
      this.timeJumps = 1,
      this.height,
      this.width,
      this.loader,
      this.index})
      : assert(network != null || asset != null || file != null,
            'One of the datasource (network, asset, file) must not be null.'),
        assert(
            (network == null && asset == null) ||
                (network == null && file == null) ||
                (file == null && asset == null),
            'Only one of the datasource (network, asset, file) can be provided.');

  @override
  _AutoPlayVideoState createState() => _AutoPlayVideoState();
}

class _AutoPlayVideoState extends State<AutoPlayVideo>
    with SingleTickerProviderStateMixin {
  Animation<Color> _colorAnimation;
  AnimationController _animationController;
  VideoPlayerController _controller;
  bool _showControllers = false;
  bool _completed = false;
  bool _onceAutoplayed = false;
  final _notifier = AutoPlayNotifier();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
    _colorAnimation = Tween<Color>(begin: Colors.red, end: Colors.red).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeIn));
    if (widget.network != null) {
      _controller = VideoPlayerController.network(widget.network);
    } else if (widget.asset != null) {
      _controller = VideoPlayerController.asset(widget.asset);
    } else {
      bool isWeb;
      try {
        if (Platform.isAndroid)
          isWeb = false;
        else if (Platform.isIOS)
          isWeb = false;
        else
          isWeb = true;
      } catch (e) {
        isWeb = true;
      }

      assert(!isWeb, 'File datasource is not supported for web.');
      _controller = VideoPlayerController.file(widget.file);
    }
    _controller.addListener(_listener);
    _controller.setLooping(widget.looping);
    _init();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// video controller listener
  void _listener() {
    if (!_controller.value.initialized) return;
    if (_controller.value.position.compareTo(_controller.value.duration) >= 0) {
      if (!_completed) {
        _completed = true;
        if (widget.index != null) AutoPlayNotifier().completed(widget.index);
        _onComplete();
      }
    } else
      setState(() {});
  }

  Future<void> _init() async {
    await _controller.initialize();
  }

  /// restart video
  void _onComplete() async {
    await _controller.seekTo(Duration());
    await _controller.pause();
    _onceAutoplayed = false;
    _completed = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.index != null &&
        _controller.value.initialized &&
        widget.autoPlay &&
        _notifier.nextVideoIndex.value == widget.index &&
        !_controller.value.isPlaying &&
        !_onceAutoplayed) {
      _onceAutoplayed = true;
      _controller.play();
    } else if (widget.index != null &&
        _notifier.nextVideoIndex.value != widget.index &&
        _controller.value.initialized &&
        _controller.value.isPlaying) {
      // _onceAutoplayed = false;
      _controller.pause();
    }

    return Center(
      child: Container(
        height: widget.height,
        width: widget.width,
        child: Stack(
          children: [
            InkWell(
              onTap: () => _toggleVideoControllers(),
              child: (_controller.value.initialized)
                  ? VideoPlayer(_controller)
                  : widget.loader ??
                      Container(
                        color: Colors.black,
                        child: Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            valueColor: _colorAnimation,
                          ),
                        ),
                      ),
            ),
            if (_showControllers) _videoControllers(),
          ],
        ),
      ),
    );
  }

  /// video controllers overlay
  Widget _videoControllers() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // rewind button
                  IconButton(
                    onPressed: () => _seekVideo(false),
                    icon: Icon(
                      Icons.fast_rewind,
                      size: 40,
                    ),
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  // play / pause button
                  IconButton(
                    onPressed: () => _playPause(),
                    icon: Icon(
                      (_controller.value.isPlaying)
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 40,
                    ),
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  // forward button
                  IconButton(
                    onPressed: () => _seekVideo(true),
                    icon: Icon(
                      Icons.fast_forward,
                      size: 40,
                    ),
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          Row(
            children: [
              // current duration
              Text(
                _formatDuration(_controller.value.position, false),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              SizedBox(
                width: 6,
              ),
              // duration progress indicator
              Expanded(
                  child: LinearProgressIndicator(
                      value: _durationRatio(),
                      backgroundColor: Colors.white.withOpacity(0.2),
                      minHeight: 2,
                      valueColor: _colorAnimation)),
              SizedBox(
                width: 6,
              ),
              // total duration
              Text(
                _formatDuration(_controller.value.duration, true),
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// format duration into string
  String _formatDuration(Duration duration, bool isTotalDuration) {
    if (!_controller.value.initialized) return '00:00';

    int seconds = duration.inSeconds;
    int minutes = duration.inMinutes;
    int hours = duration.inHours;
    String str = '';

    if (_controller.value.duration.inHours > 0) {
      if (hours < 9)
        str += '0$hours:';
      else
        str += '$hours:';
    }

    if (minutes < 9)
      str += '0$minutes:';
    else
      str += '$minutes:';

    if (seconds < 9)
      str += '0$seconds';
    else
      str += '$seconds';

    return str;
  }

  /// ratio of current and total duration
  double _durationRatio() {
    if (!_controller.value.initialized) return 0.0;
    return _controller.value.position.inSeconds /
        _controller.value.duration.inSeconds;
  }

  /// seek video
  Future<void> _seekVideo(bool forward) async {
    if (!_controller.value.initialized) return;

    int newTime;

    if (forward) {
      newTime = _controller.value.position.inSeconds + widget.timeJumps;
      if (newTime > _controller.value.duration.inSeconds) {
        newTime = _controller.value.duration.inSeconds;
      }
    } else {
      newTime = _controller.value.position.inSeconds - widget.timeJumps;
      if (newTime < 0) {
        newTime = 0;
      }
    }

    _controller.seekTo(Duration(seconds: newTime));
  }

  /// play / pause video
  Future<void> _playPause() async {
    if (!_controller.value.initialized) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _notifier.setIndex(widget.index);
      _controller.play();
    }
  }

  /// show hide video controllers
  Future<void> _toggleVideoControllers() async {
    if (_showControllers) return;
    setState(() => _showControllers = true);
    await Future.delayed(Duration(seconds: 3));
    if (_showControllers) setState(() => _showControllers = false);
  }
}
