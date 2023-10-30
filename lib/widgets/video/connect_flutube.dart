import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:connect/utils/logger/log.dart';
import 'package:connect/utils/system_ui_overlay.dart';
import 'package:connect/widgets/video/connect_flutube_controls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:tuple/tuple.dart';
import 'package:video_player/video_player.dart';

import 'connect_flutube_controller.dart';

class ConnectFlutube extends StatefulWidget {
  final String videoUrl;
  final String title;
  final double aspectRatio;
  final bool autoPlay;
  final Duration startAt;
  final Widget controlOverlay;
  final OrientationBuilder overlay;
  final VoidCallback onBackButtonPressed;
  final VoidCallback onStart;
  final ConnectFlutubeController controller;

  ConnectFlutube({
    @required this.videoUrl,
    @required this.title,
    @required this.onBackButtonPressed,
    this.controller,
    this.onStart,
    this.controlOverlay,
    this.overlay,
    this.aspectRatio = 16 / 9,
    this.autoPlay = true,
    this.startAt = const Duration(),
  })  : assert(videoUrl != null),
        assert(title != null);

  @override
  _ConnectFlutubeState createState() => _ConnectFlutubeState();
}

class _ConnectFlutubeState extends State<ConnectFlutube> {
  VideoPlayerController videoController;
  ChewieController chewieController;

  bool get isPlaying => videoController?.value?.isPlaying ?? false;
  bool isStart = false;
  bool isEnd = false;
  double _aspectRatio;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    final videoInfo = await _fetchVideoURL();
    final url = videoInfo.item1;
    final size = videoInfo.item2;
    final videoAspectRatio =
        videoInfo.item2 != null ? size.width / size.height : null;
    Log.d("ConnectFlutube", "videoAspectRatio=$videoAspectRatio");
    _aspectRatio = videoAspectRatio ?? widget.aspectRatio;
    if (!mounted) return;
    setState(() {
      videoController = VideoPlayerController.network(url)
        ..addListener(_playCheck);

      chewieController = ChewieController(
          videoPlayerController: videoController,
          aspectRatio: _aspectRatio,
          autoInitialize: true,
          autoPlay: widget.autoPlay,
          startAt: widget.startAt,
          looping: widget.controller?.looping ?? false,
          deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
          systemOverlaysAfterFullScreen: SystemUiOverlay.values,
          customControls: ConnectFlutubeControls(
            key: widget.key,
            title: widget.title,
            onBackButtonPressed: widget.onBackButtonPressed,
            controller: widget.controller,
            overlay: widget.controlOverlay,
            alwaysOverlay: widget.overlay,
          ));

      if (widget.controller != null) {
        widget.controller.chewieController = chewieController;
      }
    });
  }

  void _playCheck() {
    final position = videoController?.value?.position ?? Duration.zero;
    final max = videoController.value?.duration ?? Duration.zero;
    final diff = (max - position).inMilliseconds;
    final isEnd = max.inMilliseconds > 0 && (diff <= 500);

    if (!isStart && position != null && position.inMilliseconds > 0) {
      isStart = true;
      widget.onStart?.call();
    }

    if (this.isEnd && !isEnd) {
      this.isEnd = false;
    }

    if (!this.isEnd && isEnd) {
      this.isEnd = true;
      widget.controller?.onEnd();
    }
  }

  @override
  void dispose() {
    if (videoController != null) videoController.dispose();
    chewieController?.pause();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(videoSystemUIOverlay);
    if (chewieController == null)
      return AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );

    var chewie = Chewie(
      key: widget.key,
      controller: chewieController,
    );
    if (_aspectRatio != null && _aspectRatio < 1) {
      return chewie;
    } else {
      return AspectRatio(aspectRatio: widget.aspectRatio, child: chewie);
    }
  }

  Future<Tuple2<String, Size>> _fetchVideoURL() async {
    final yt = widget
        .videoUrl; // "https://www.youtube.com/watch?v=Er9xo1LBbQQ";//widget.videoUrl;
    String videoUrl = yt;
    Size videoSize;
    final response = await http.get(yt);

    var streamingDataMatch =
        RegExp(r'streamingData.*?]').firstMatch(response.body);
    if (streamingDataMatch != null) {
      try {
        var streamingData = streamingDataMatch.group(0);
        var urlMatch = RegExp(r'url":".*?"').firstMatch(streamingData);
        if (urlMatch != null) {
          var url = urlMatch.group(0);
          url = url.substring(url.indexOf("http"), url.length - 1);
          videoUrl = Uri.decodeFull(url).replaceAll(r'\u0026', '&');
        }
        var widthMatch = RegExp(r'width":.*?,').firstMatch(streamingData);
        var heightMatch = RegExp(r'height":.*?,').firstMatch(streamingData);
        if (widthMatch != null && heightMatch != null) {
          var width = widthMatch.group(0).split(':')[1];
          var height = heightMatch.group(0).split(':')[1];
          width = width.substring(0, width.length - 1);
          height = height.substring(0, height.length - 1);
          Log.d("ConnectFlutube", "width=$width, height=$height");
          videoSize =
              Size(int.parse(width).toDouble(), int.parse(height).toDouble());
        }
      } catch (e) {
        Log.d("ConnectFlutube", "[fetchVideoUrl]Exception=${e.toString()}");
      }
    }
    return Tuple2(videoUrl, videoSize);
  }

  Iterable<String> _allStringMatches(String text, RegExp regExp) =>
      regExp.allMatches(text).map((m) => m.group(0));

  String _videoThumbURL(String yt) {
    String id = _getVideoIdFromUrl(yt);
    return "http://img.youtube.com/vi/$id/0.jpg";
  }

  String _getVideoIdFromUrl(String url) {
    // For matching https://youtu.be/<VIDEOID>
    RegExp regExp1 = new RegExp(r"youtu\.be\/([^#\&\?]{11})",
        caseSensitive: false, multiLine: false);
    // For matching https://www.youtube.com/watch?v=<VIDEOID>
    RegExp regExp2 = new RegExp(r"\?v=([^#\&\?]{11})",
        caseSensitive: false, multiLine: false);
    // For matching https://www.youtube.com/watch?x=yz&v=<VIDEOID>
    RegExp regExp3 = new RegExp(r"\&v=([^#\&\?]{11})",
        caseSensitive: false, multiLine: false);
    // For matching https://www.youtube.com/embed/<VIDEOID>
    RegExp regExp4 = new RegExp(r"embed\/([^#\&\?]{11})",
        caseSensitive: false, multiLine: false);
    // For matching https://www.youtube.com/v/<VIDEOID>
    RegExp regExp5 = new RegExp(r"\/v\/([^#\&\?]{11})",
        caseSensitive: false, multiLine: false);

    String matchedString;

    if (regExp1.hasMatch(url)) {
      matchedString = regExp1.firstMatch(url).group(0);
    } else if (regExp2.hasMatch(url)) {
      matchedString = regExp2.firstMatch(url).group(0);
    } else if (regExp3.hasMatch(url)) {
      matchedString = regExp3.firstMatch(url).group(0);
    } else if (regExp4.hasMatch(url)) {
      matchedString = regExp4.firstMatch(url).group(0);
    } else if (regExp5.hasMatch(url)) {
      matchedString = regExp5.firstMatch(url).group(0);
    }

    return matchedString != null
        ? matchedString.substring(matchedString.length - 11)
        : null;
  }
}
