import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  Map<String, dynamic>? pageData;

  Future<void> _loadJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      final jsonStr = await file.readAsString();
      setState(() {
        pageData = jsonDecode(jsonStr);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Reader App", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: pageData == null
          ? Center(
        child: ElevatedButton.icon(
          onPressed: _loadJson,
          icon: const Icon(Icons.folder_open),
          label: const Text("Load JSON"),
        ),
      )
          : _buildPageView(),
    );
  }

  Widget _buildPageView() {
    final widgets = pageData!['widgets'] as List;
    final orientation = pageData!['orientation'] ?? "portrait";
    final isPortrait = orientation == "portrait";

    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF121212),
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment:
          isPortrait ? CrossAxisAlignment.center : CrossAxisAlignment.start,
          children: widgets.map((w) => _buildWidget(w)).toList(),
        ),
      ),
    );
  }

  Widget _buildWidget(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'Text':
        final props = data['props'];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            props['text'] ?? '',
            style: TextStyle(
              fontSize: (props['fontSize'] ?? 16).toDouble(),
              color: _parseColor(props['color'] ?? '#FFFFFF'),
            ),
          ),
        );

      case 'Image':
        final props = data['props'];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Image.network(
            props['url'],
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );

      case 'Video':
        final props = data['props'];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: VideoWidget(videoUrl: props['url']),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) hexColor = "FF$hexColor";
    return Color(int.parse("0x$hexColor"));
  }
}

class VideoWidget extends StatefulWidget {
  final String videoUrl;
  const VideoWidget({super.key, required this.videoUrl});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() => _initialized = true);
        _controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : const Center(child: CircularProgressIndicator());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
