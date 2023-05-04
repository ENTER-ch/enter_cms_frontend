import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final GetIt getIt = GetIt.instance;

class InlineAudioPlayer extends StatefulWidget {
  const InlineAudioPlayer({
    Key? key,
    required this.url,
  }) : super(key: key);

  final String url;

  @override
  State<InlineAudioPlayer> createState() => _InlineAudioPlayerState();
}

class _InlineAudioPlayerState extends State<InlineAudioPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Duration? _duration;

  @override
  void initState() {
    super.initState();

    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _setUrl(widget.url);

    _audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        _duration = event;
      });
    });
  }

  @override
  void didUpdateWidget(covariant InlineAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _audioPlayer.stop();
      _setUrl(widget.url);
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _setUrl(String url) {
    _audioPlayer.setSourceUrl(_getUrl(url));
  }

  String _getUrl(String url) {
    return url.contains('http') ? url : "${getIt<Dio>().options.baseUrl}$url";
  }

  void _onPlayPausePressed() {
    if (_audioPlayer.state == PlayerState.playing) {
      _audioPlayer.seek(Duration.zero);
      _audioPlayer.stop();
    } else if (_audioPlayer.state == PlayerState.paused) {
      _audioPlayer.resume();
    } else {
      _audioPlayer.play(UrlSource(_getUrl(widget.url)));
    }
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String _printPosition(Duration? position) {
    if (position != null && _duration != null) {
      return "${_printDuration(position)} / ${_printDuration(_duration!)}";
    }
    else if (position != null) {
      return _printDuration(position);
    }
    return '--:--';
  }

  double _getPosition(Duration? position) {
    if (position != null && _duration != null && _duration!.inMilliseconds > 0) {
      return position.inMilliseconds / _duration!.inMilliseconds;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.onPlayerStateChanged,
      builder: (context, snapshot) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _onPlayPausePressed,
              child: snapshot.data == PlayerState.playing ? const Icon(Icons.stop) : const Icon(Icons.play_arrow),
            ),
            const SizedBox(
              width: 8,
            ),
            StreamBuilder<Duration>(
              stream: _audioPlayer.onPositionChanged,
              builder: (context, snapshot) {
                return _buildProgress(
                  _audioPlayer.state == PlayerState.playing,
                  snapshot.data,
                );
              }
            ),
          ],
        );
      }
    );
  }

  Widget _buildProgress(bool isPlaying, Duration? position) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(_printPosition(isPlaying ? position : Duration.zero)),
          LinearProgressIndicator(value: _getPosition(isPlaying ? position : Duration.zero)),
        ],
      ),
    );
  }
}
