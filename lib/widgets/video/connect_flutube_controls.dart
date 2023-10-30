import 'dart:async';
import 'dart:io';

import 'package:chewie/src/chewie_player.dart';
import 'package:chewie/src/chewie_progress_colors.dart';
import 'package:chewie/src/material_progress_bar.dart';
import 'package:connect/resources/app_resources.dart';
import 'package:connect/widgets/base_widget.dart';
import 'package:connect/widgets/video/connect_flutube_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multiscreen/multiscreen.dart';
import 'package:video_player/video_player.dart';

class ConnectFlutubeControls extends StatefulWidget {
  final String title;
  final VoidCallback onBackButtonPressed;
  final Widget overlay;
  final OrientationBuilder alwaysOverlay;
  final ConnectFlutubeController controller;

  const ConnectFlutubeControls(
      {Key key,
      @required this.title,
      @required this.onBackButtonPressed,
      this.overlay,
      this.alwaysOverlay,
      this.controller})
      : assert(title != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ConnectFlutubeControlsState();
  }
}

// origin : https://github.com/brianegan/chewie/blob/master/lib/src/material_controls.dart
class _ConnectFlutubeControlsState extends State<ConnectFlutubeControls> {
  VideoPlayerValue _latestValue;
  bool _hideStuff = true;
  Timer _hideTimer;
  Timer _initTimer;
  Timer _showAfterExpandCollapseTimer;
  bool _displayTapped = false;

  final barHeight = 48.0;
  final marginSize = 5.0;

  VideoPlayerController controller;
  ChewieController chewieController;

  @override
  Widget build(BuildContext context) {
    if (_latestValue.hasError) {
      return chewieController.errorBuilder != null
          ? chewieController.errorBuilder(context,
              chewieController.videoPlayerController.value.errorDescription)
          : Center(child: Icon(Icons.error, color: Colors.white, size: 42));
    }

    return MouseRegion(
        onHover: (_) {
          _cancelAndRestartTimer();
        },
        child: GestureDetector(
            onTap: () => _cancelAndRestartTimer(),
            child: AbsorbPointer(
                absorbing: _hideStuff,
                child: Stack(fit: StackFit.expand, children: <Widget>[
                  _notPrepared()
                      ? const Center(child: const CircularProgressIndicator())
                      : _buildHitArea(),
                  Align(alignment: Alignment.topLeft, child: _createTop()),
                  Center(child: _createCenterIcon()),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            _createBottomBarHeader(),
                            _buildBottomBar(context)
                          ])),
                  stuffOpacity(child: widget.overlay ?? Container()),
                  widget.alwaysOverlay ?? Container()
                ]))));
  }

  Widget _createCenterIcon() {
    if (_latestValue == null) return CircularProgressIndicator();

    return GestureDetector(
        onTap: _playPause,
        child: stuffOpacity(
            child: Icon(_latestValue.isPlaying ? Icons.pause : Icons.play_arrow,
                color: AppColors.white, size: resize(40))));
  }

  Widget _buildHitArea() {
    return GestureDetector(
        onTap: _toggle,
        child: Container(
            width: double.infinity,
            height: double.infinity,
            child: stuffOpacity(
                child: Container(color: AppColors.black.withOpacity(0.6)))));
  }

  bool _notPrepared() {
    return _latestValue != null &&
            !_latestValue.isPlaying &&
            _latestValue.duration == null ||
        _latestValue.isBuffering;
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller.removeListener(_updateState);
    _hideTimer?.cancel();
    _initTimer?.cancel();
    _showAfterExpandCollapseTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = chewieController;
    chewieController = ChewieController.of(context);
    controller = chewieController.videoPlayerController;

    if (_oldController != chewieController) {
      _dispose();
      _initialize();
    }

    super.didChangeDependencies();
  }

  AnimatedOpacity stuffOpacity({@required Widget child}) {
    return AnimatedOpacity(
        opacity: _hideStuff ? 0.0 : 1.0,
        duration: Duration(milliseconds: 300),
        child: child);
  }

  Widget _createTop() {
    List<Widget> row = [];
    if (widget.onBackButtonPressed != null) {
      row.add(GestureDetector(
          child: Container(
              width: resize(20),
              height: resize(20),
              margin: EdgeInsets.only(left: resize(16)),
              child:
                  Image.asset(AppImages.ic_arrow_left, color: AppColors.white)),
          onTap: () {
            widget.onBackButtonPressed();
          }));
    }

    row.add(SizedBox(width: resize(20)));

    row.add(Flexible(
      child: chewieController.isFullScreen
          ? Text(widget.title,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyle.from(
                  color: AppColors.white, size: TextSize.body_small))
          : Container(),
      flex: 6,
    ));

    row.add(Spacer(flex: 4));

    return stuffOpacity(
        child: Container(
            height: resize(60),
            margin: EdgeInsets.only(top: resize(20)),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.start, children: row)));
  }

  Widget _createBottomBarHeader() {
    if (chewieController.isFullScreen) return Container();

    return stuffOpacity(
        child: Row(children: <Widget>[
      _createPositionText(_currentPosition),
      Spacer(),
      _createPositionText(_maxPosition),
      _buildExpandButton()
    ]));
  }

  Widget _buildBottomBar(BuildContext context) {
    return stuffOpacity(
        child: Container(
            margin: chewieController.isFullScreen
                ? EdgeInsets.only(
                    left: resize(24), right: resize(16), bottom: resize(20))
                : null,
            child: Row(children: <Widget>[
              chewieController.isFullScreen
                  ? _createPositionText(_currentPosition)
                  : Container(),
              Flexible(child: _buildProgressBar()),
              chewieController.isFullScreen
                  ? _createPositionText(_maxPosition)
                  : Container(),
              chewieController.isFullScreen ? _buildExpandButton() : Container()
            ])));
  }

  Widget _createPositionText(Duration duration) {
    return Container(
      margin: EdgeInsets.only(left: resize(10), right: resize(10)),
      child: Text(
          "${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}",
          style: AppTextStyle.from(
              size: TextSize.caption_medium, color: AppColors.white)),
    );
  }

  GestureDetector _buildExpandButton() {
    return GestureDetector(
        onTap: _onExpandCollapse,
        child: stuffOpacity(
            child: Container(
                margin: EdgeInsets.only(right: 12.0),
                padding: EdgeInsets.only(left: 8.0, right: 8.0),
                child: Center(
                    child: Icon(
                        chewieController.isFullScreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: AppColors.white)))));
  }

  void _toggle() {
    if (_latestValue == null) return;

    setState(() {
      _hideStuff = true;
      _hideTimer.cancel();
    });
  }

  Duration _currentPosition = Duration.zero;
  Duration _maxPosition = Duration.zero;

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();

    setState(() {
      _hideStuff = false;
    });
  }

  Future<Null> _initialize() async {
    controller.addListener(_updateState);

    _updateState();

    if ((controller.value != null && controller.value.isPlaying) ||
        chewieController.autoPlay) {
      _startHideTimer();
    }

    if (chewieController.showControlsOnInitialize) {
      _initTimer = Timer(Duration(milliseconds: 200), () {
        setState(() {
          _hideStuff = false;
        });
      });
    }
  }

  void _onExpandCollapse() {
    setState(() {
      _hideStuff = true;
      if (Platform.isIOS) {
        if (!chewieController.isFullScreen)
          SystemChrome.setPreferredOrientations(
              [DeviceOrientation.landscapeLeft]);
      }
      chewieController.toggleFullScreen();
      _showAfterExpandCollapseTimer = Timer(Duration(milliseconds: 300), () {
        setState(() {
          _cancelAndRestartTimer();
        });
      });
    });
  }

  void _playPause() {
    bool isFinished = _latestValue.position >= _latestValue.duration;

    setState(() {
      if (controller.value.isPlaying) {
        _hideStuff = false;
        _hideTimer?.cancel();
        controller.pause();
      } else {
        _cancelAndRestartTimer();

        if (!controller.value.initialized) {
          controller.initialize().then((_) {
            controller.play();
          });
        } else {
          if (isFinished) {
            controller.seekTo(Duration(seconds: 0));
          }
          controller.play();
        }
      }
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideStuff = true;
      });
    });
  }

  void _updateState() async {
    _latestValue = controller.value;
    _currentPosition =
        _latestValue?.position != null ? _latestValue.position : Duration.zero;
    _maxPosition =
        _latestValue?.duration != null ? _latestValue.duration : Duration.zero;

    if (_latestValue?.isPlaying == false &&
        _currentPosition != null &&
        _maxPosition != null &&
        _currentPosition > _maxPosition) {
      await controller.pause();
    }

    setState(() {});
  }

  Widget _buildProgressBar() {
    return Container(
        height: resize(20),
        margin: chewieController.isFullScreen
            ? null
            : EdgeInsets.only(left: resize(10), right: resize(10)),
        child: MaterialVideoProgressBar(controller, onDragStart: () {
          setState(() {});
          _hideTimer?.cancel();
          widget.controller?.onDragStart();
        }, onDragEnd: () {
          setState(() {
            if (!controller.value.isPlaying &&
                controller.value.position < controller.value.duration)
              controller.play();
          });
          _startHideTimer();
          widget.controller?.onDragEnd();
        },
            colors: chewieController.materialProgressColors ??
                ChewieProgressColors(
                    playedColor: Theme.of(context).accentColor,
                    handleColor: Theme.of(context).accentColor,
                    bufferedColor: Theme.of(context).backgroundColor,
                    backgroundColor: Theme.of(context).disabledColor)));
  }
}
