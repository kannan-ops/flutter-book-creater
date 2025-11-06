import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class WidgetFactory {
  static Widget render(Map<String, dynamic> data) {
    print("🔹 Rendering widget type: ${data['type']}");
    switch (data['type']) {
      case 'Text':
        print("📝 Rendering Text: ${data['props']}");
        return SizedBox(
          width: (data['width'] ?? 200).toDouble(),
          child: Text(
            data['props']?['text'] ?? 'No Text',
            style: TextStyle(
              fontSize: (data['props']?['fontSize'] ?? 18).toDouble(),
              color: Color(
                int.parse(
                    (data['props']?['color'] ?? '#000000').replaceFirst('#', '0xff')),
              ),
            ),
          ),
        );

      case 'Image':
        return Image.network(
          data['props']?['url'] ?? '',
          width: (data['width'] ?? 200).toDouble(),
          height: (data['height'] ?? 200).toDouble(),
          fit: BoxFit.cover,
        );

      case 'Video':
        return _VideoPlayerWidget(url: data['props']?['url'] ?? '');

      case 'Audio':
        return _AudioWidget(url: data['props']?['url'] ?? '');

      case 'LiveData':
        return  _LiveClock();

      default:
        return  SizedBox(child: Text(" Unknown Widget"));
    }
  }
}


class _VideoPlayerWidget extends StatefulWidget {
  final String url;
  const _VideoPlayerWidget({required this.url});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        :  CircularProgressIndicator();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


class _AudioWidget extends StatelessWidget {
  final String url;
  const _AudioWidget({required this.url});

  @override
  Widget build(BuildContext context) {
    final player = AudioPlayer();
    return Row(
      children: [
        IconButton(
          icon:  Icon(Icons.play_arrow),
          onPressed: () => player.play(UrlSource(url)),
        ),
        IconButton(
          icon:  Icon(Icons.stop),
          onPressed: () => player.stop(),
        ),
      ],
    );
  }
}


class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  late Timer timer;
  String time = "";

  @override
  void initState() {
    super.initState();
    time = DateTime.now().toLocal().toIso8601String();
    timer = Timer.periodic( Duration(seconds: 1), (_) {
      setState(() => time = DateTime.now().toLocal().toIso8601String());
    });
  }

  @override
  Widget build(BuildContext context) => Text(
    time,
    style:  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  );

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
