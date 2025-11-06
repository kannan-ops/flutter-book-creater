import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'reader2.dart'; // WidgetFactory file

class ReaderPage extends StatefulWidget {
  const ReaderPage({super.key});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  Map<String, dynamic>? jsonData;


  Future<void> exportJSON(BuildContext context) async {
    final samplePage = {
      "pageTitle": "My Lesson",
      "page_size_X": "800",
      "page_size_Y": "1000",
      "orientation": "portrait",
      "widgets": [
        {
          "type": "Text",
          "x": 50,
          "y": 50,
          "width": 300,
          "height": 50,
          "props": {
            "text": "Welcome to Science!",
            "fontSize": 22,
            "color": "#ff0000"
          }
        },
        {
          "type": "Image",
          "x": 50,
          "y": 150,
          "width": 200,
          "height": 200,
          "props": {
            "url": "https://picsum.photos/200"
          }
        },
        {
          "type": "Video",
          "x": 50,
          "y": 400,
          "width": 300,
          "height": 200,
          "props": {
            "url":
            "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4"
          }
        },
        {
          "type": "LiveData",
          "x": 50,
          "y": 650,
          "width": 300,
          "height": 50,
          "props": {}
        }
      ]
    };

    try {
      final desktopPath =
          "${Platform.environment['USERPROFILE']}/Desktop/sample_page.json";
      final file = File(desktopPath);
      await file.writeAsString(
         JsonEncoder.withIndent('  ').convert(samplePage),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' JSON saved: $desktopPath')),
        );
      }

      if (kDebugMode) print(' JSON exported to $desktopPath');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(' Error saving file: $e')),
        );
      }
    }
  }


  Future<void> loadJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final data = json.decode(content);

        setState(() {
          jsonData = data;
        });

        print(" JSON loaded: ${(data['widgets'] as List).length} widgets");
      }
    } catch (e) {
      print(" Error loading JSON: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text(' Reader App'),
        actions: [
          IconButton(
            onPressed: () => exportJSON(context),
            icon:  Icon(Icons.save_alt),
            tooltip: "Export Sample JSON",
          ),
        ],
      ),
      body: Center(
        child: jsonData == null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: loadJson,
              child:  Text(" Load JSON"),
            ),
             SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => exportJSON(context),
              child:  Text(" Export Sample JSON"),
            ),
          ],
        )
            : SingleChildScrollView(
          child: Container(
            width: double.tryParse(jsonData?['page_size_X'] ?? '800') ?? 800,
            height:
            double.tryParse(jsonData?['page_size_Y'] ?? '1000') ?? 1000,
            color: Colors.grey.shade300,
            child: Stack(
              children: (jsonData!['widgets'] as List)
                  .map((w) => buildWidget(w))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }


  Widget buildWidget(Map<String, dynamic> w) {
    try {
      final double left = (w['x'] ?? 0).toDouble();
      final double top = (w['y'] ?? 0).toDouble();
      debugPrint("📍 Widget at x:$left y:$top type:${w['type']}");

      final child = WidgetFactory.render(w);
      return Positioned(
        left: left,
        top: top,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.redAccent, width: 2),
            color: Colors.yellow.withOpacity(0.2),
          ),
          padding: const EdgeInsets.all(4),
          child: child,
        ),
      );
    } catch (e, s) {
      debugPrint(" Widget build error: $e");
      debugPrint("$s");
      return  Text(" Render failed");
    }
  }
}
