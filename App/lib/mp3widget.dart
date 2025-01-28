import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PlayMp3Widget extends StatefulWidget {
  final String audioUrl;

  const PlayMp3Widget({required this.audioUrl});

  @override
  _PlayMp3WidgetState createState() => _PlayMp3WidgetState();
}

class _PlayMp3WidgetState extends State<PlayMp3Widget> {
  final player = AudioPlayer();

  bool isPlaying = false;
  StreamSubscription<Duration>? positionSub;
  Duration duration = Duration();
  Duration position = Duration();

  @override
  void initState() {
    super.initState();
    player.onDurationChanged.listen((d) {
      setState(() {
        duration = d;
      });
    });
    positionSub = player.onPositionChanged.listen((p) {
      setState(() {
        position = p;
      });
    });
  }

  @override
  void dispose() {
    positionSub?.cancel();
    player.dispose();
    super.dispose();
  }

  Future<void> playAudioFromUrl(String url) async {
    await player.play(UrlSource(url));

    setState(() {
      isPlaying = true;
    });
  }

  Future<void> pauseAudio() async {
    await player.pause();
    setState(() {
      isPlaying = false;
    });
  }

  Future<void> seekToSecond(int second) async {
    await player.seek(Duration(seconds: second));
  }

  @override
  void didUpdateWidget(PlayMp3Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioUrl != widget.audioUrl) {
      playAudioFromUrl(widget.audioUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: isPlaying ? pauseAudio : () => playAudioFromUrl(widget.audioUrl),
          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
        ),
        Slider(
          value: position.inSeconds.toDouble(),
          min: 0.0,
          max: duration.inSeconds.toDouble(),
          onChanged: (double value) {
            setState(() {
              seekToSecond(value.toInt());
              value = value;
            });
          },
        ),
        Text(
          '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')} / ${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
