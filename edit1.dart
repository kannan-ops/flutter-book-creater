import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'edit2.dart';
import 'edit3.dart';

class EditorCanvas extends StatefulWidget {
  const EditorCanvas({super.key});

  @override
  State<EditorCanvas> createState() => _EditorCanvasState();
}

class _EditorCanvasState extends State<EditorCanvas> {
  List<WidgetData> widgets = [];


  void addWidget(WidgetData data) {
    setState(() => widgets.add(data));
    if (kDebugMode) print(" Widget added: ${data.toJson()}");
  }


  Future<void> exportToDesktop() async {
    print("🚀 Starting exportToDesktop...");

    final book = {
      "pageTitle": "My Lesson",
      "page_size_X": "800",
      "page_size_Y": "1000",
      "orientation": "portrait",
      "widgets": widgets.isEmpty
          ? _getDefaultWidgets()
          : widgets.map((e) => e.toJson()).toList(),
    };

    print(" JSON data prepared:");
    print( JsonEncoder.withIndent('  ').convert(book));

    try {
      Directory? desktopDir;
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        final userDir = Platform.environment['USERPROFILE'] ??
            Platform.environment['HOME'] ??
            "";
        desktopDir = Directory("$userDir/Desktop");
        if (!desktopDir.existsSync()) {
          desktopDir = await getApplicationDocumentsDirectory();
        }
      } else {
        desktopDir = await getApplicationDocumentsDirectory();
      }

      final file = File("${desktopDir.path}/sample_page.json");
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(book));

      print('JSON saved successfully at: ${file.path}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('JSON saved: ${file.path}')),
        );
      }
    } catch (e) {
      print(" Error while saving JSON: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' Failed to save JSON: $e')),
        );
      }
    }
  }

  Future<void> saveAsJson() async {
    print("Saving JSON to app directory...");

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/sample_page.json');
    final book = {
      "pageTitle": "My Lesson",
      "page_size_X": "800",
      "page_size_Y": "1000",
      "orientation": "portrait",
      "widgets": widgets.map((e) => e.toJson()).toList(),
    };

    try {
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(book));
      print(" JSON saved at ${file.path}");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("💾 JSON saved to ${file.path}")),
        );
      }
    } catch (e) {
      print(" Error saving JSON: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(" Failed to save JSON: $e")),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getDefaultWidgets() => [
    {
      "type": "Text",
      "x": 50,
      "y": 50,
      "width": 300,
      "height": 50,
      "props": {
        "text": "Welcome to Science!",
        "fontSize": 22,
        "color": "#333333"
      }
    },
    {
      "type": "Image",
      "x": 50,
      "y": 120,
      "width": 200,
      "height": 150,
      "props": {"url": "https://picsum.photos/200"}
    },
    {
      "type": "Video",
      "x": 50,
      "y": 300,
      "width": 300,
      "height": 200,
      "props": {
        "url":
        "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4"
      }
    }
  ];

  @override
  Widget build(BuildContext context) {
    print(" Building EditorCanvas UI...");

    return Scaffold(
      appBar: AppBar(
        title:  Text("Editor Canvas"),
        actions: [
          IconButton(
            icon:  Icon(Icons.text_fields),
            tooltip: 'Add Text',
            onPressed: () => addWidget(WidgetData.textWidget()),
          ),
          IconButton(
            icon:  Icon(Icons.image),
            tooltip: 'Add Image',
            onPressed: () => addWidget(WidgetData.imageWidget()),
          ),
          IconButton(
            icon:  Icon(Icons.video_library),
            tooltip: 'Add Video',
            onPressed: () => addWidget(WidgetData.videoWidget()),
          ),
          IconButton(
            icon:  Icon(Icons.save),
            tooltip: 'Export JSON to Desktop',
            onPressed: exportToDesktop,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 800,
                height: 1000,
                color: Colors.grey.shade200,
                child: Stack(
                  children: widgets.map((data) => buildWidget(data)).toList(),
                ),
              ),
            ),
          ),
           SizedBox(height: 8),
          ElevatedButton(
            onPressed: saveAsJson,
            child:  Text("💾 Save JSON (App Directory)"),
          ),
           SizedBox(height: 16),
        ],
      ),
    );
  }


  Widget buildWidget(WidgetData data) {
    return Positioned(
      left: data.x,
      top: data.y,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            data.x = (data.x + details.delta.dx).clamp(0, 800).toDouble();
            data.y = (data.y + details.delta.dy).clamp(0, 1000).toDouble();
          });
          if (kDebugMode) {
            print("📍 Widget moved → ${data.type} at (${data.x}, ${data.y})");
          }
        },
        child: WidgetFactory.renderEditable(data),
      ),
    );
  }
}
