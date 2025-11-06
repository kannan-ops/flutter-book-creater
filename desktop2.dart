import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  List<Map<String, dynamic>> widgets = [];
  String orientation = "portrait";
  final TextEditingController _titleController = TextEditingController();

  void _addTextWidget() {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController textCtrl = TextEditingController();
        TextEditingController sizeCtrl = TextEditingController(text: "20");
        TextEditingController colorCtrl = TextEditingController(text: "#FFFFFF");

        return AlertDialog(
          backgroundColor: const Color(0xFF2B2B2B),
          title: const Text("Add Text", style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _textField("Text", textCtrl),
              _textField("Font Size", sizeCtrl),
              _textField("Color (hex)", colorCtrl),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
            ElevatedButton(
                onPressed: () {
                  setState(() {
                    widgets.add({
                      "type": "Text",
                      "props": {
                        "text": textCtrl.text,
                        "fontSize": double.tryParse(sizeCtrl.text) ?? 20,
                        "color": colorCtrl.text
                      }
                    });
                  });
                  Navigator.pop(context);
                },
                child: const Text("Add"))
          ],
        );
      },
    );
  }

  void _addImageWidget() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        widgets.add({
          "type": "Image",
          "props": {"url": result.files.single.path}
        });
      });
    }
  }

  void _addVideoWidget() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      setState(() {
        widgets.add({
          "type": "Video",
          "props": {"url": result.files.single.path}
        });
      });
    }
  }

  Widget _textField(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white54),
          enabledBorder:
          const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
          focusedBorder:
          const OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
        ),
      ),
    );
  }

  void _exportJson() async {
    final jsonMap = {
      "pageTitle": _titleController.text.isEmpty ? "Untitled Page" : _titleController.text,
      "page_size_X": 800,
      "page_size_Y": 1000,
      "orientation": orientation,
      "widgets": widgets
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(jsonMap);
    final dir = await getExternalStorageDirectory();
    final file = File("${dir!.path}/sample_book.json");
    await file.writeAsString(jsonStr);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Exported: ${file.path}")),
      );
    }
  }

  Widget _previewWidget(Map<String, dynamic> widgetData) {
    switch (widgetData['type']) {
      case "Text":
        final props = widgetData['props'];
        return Text(
          props['text'] ?? '',
          style: TextStyle(
              color: _parseColor(props['color']),
              fontSize: (props['fontSize'] ?? 20).toDouble()),
        );
      case "Image":
        return Image.file(File(widgetData['props']['url']),
            height: 150, fit: BoxFit.cover);
      case "Video":
        return _VideoPreview(path: widgetData['props']['url']);
      default:
        return const SizedBox.shrink();
    }
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) hexColor = "FF$hexColor";
    return Color(int.parse("0x$hexColor"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Editor App", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(onPressed: _exportJson, icon: const Icon(Icons.save)),
        ],
      ),
      floatingActionButton: PopupMenuButton<String>(
        color: const Color(0xFF2B2B2B),
        icon: const Icon(Icons.add, color: Colors.white),
        onSelected: (choice) {
          switch (choice) {
            case "Text":
              _addTextWidget();
              break;
            case "Image":
              _addImageWidget();
              break;
            case "Video":
              _addVideoWidget();
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: "Text", child: Text("Add Text")),
          const PopupMenuItem(value: "Image", child: Text("Add Image")),
          const PopupMenuItem(value: "Video", child: Text("Add Video")),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Page Title",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          DropdownButton<String>(
            dropdownColor: const Color(0xFF2B2B2B),
            value: orientation,
            items: const [
              DropdownMenuItem(value: "portrait", child: Text("Portrait")),
              DropdownMenuItem(value: "landscape", child: Text("Landscape")),
            ],
            onChanged: (val) => setState(() => orientation = val!),
          ),
          const Divider(color: Colors.white24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widgets
                    .asMap()
                    .entries
                    .map((entry) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B2B2B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _previewWidget(entry.value)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => setState(() => widgets.removeAt(entry.key)),
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPreview extends StatefulWidget {
  final String path;
  const _VideoPreview({required this.path});

  @override
  State<_VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<_VideoPreview> {
  late VideoPlayerController _controller;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) => setState(() => ready = true));
  }

  @override
  Widget build(BuildContext context) {
    return ready
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : const CircularProgressIndicator();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
