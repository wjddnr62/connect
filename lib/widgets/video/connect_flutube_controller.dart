import 'package:chewie/chewie.dart';

class ConnectFlutubeController {
  ChewieController chewieController;
  Function _onEnd;
  bool Function(int) _loopingWhile;
  int loopingCount = 0;
  bool looping = false;
  bool _isDragging = false;

  ConnectFlutubeController({Function onEnd, bool Function(int) loopingWhile})
      : this._onEnd = onEnd,
        this._loopingWhile = loopingWhile {
    looping = this._loopingWhile != null;
  }

  void play() async {
    if (chewieController == null) {
      return;
    }

    await chewieController.seekTo(Duration(seconds: 0));
    await chewieController.play();
  }

  void onDragStart() {
    _isDragging = true;
  }

  void onDragEnd() {
    _isDragging = false;
  }

  void _onEndCall() async {
    if (looping && _loopingWhile(++loopingCount)) {
      looping = false;
      await chewieController.setLooping(looping);
    }
    _onEnd?.call();
  }

  void onEnd() {
    _onEndCall();
  }
}
