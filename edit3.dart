import 'package:flutter/material.dart';
import 'edit2.dart';

class WidgetFactory {
  static Widget renderEditable(WidgetData data) {
    switch (data.type) {
      case 'Text':
        return Container(
          width: data.width,
          height: data.height,
          child: Text(
            data.props['text'] ?? 'Text Block',
            style: TextStyle(
              fontSize: (data.props['fontSize'] ?? 18).toDouble(),
              color: _parseColor(data.props['color'] ?? '#000000'),
            ),
          ),
        );

      case 'Image':
        return Container(
          width: data.width,
          height: data.height,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
          ),
          child: Image.network(
            data.props['url'] ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
             Center(child: Text('Image Error')),
          ),
        );

      case 'Video':
        return Container(
          width: data.width,
          height: data.height,
          color: Colors.black12,
          alignment: Alignment.center,
          child:  Icon(Icons.play_circle_fill, size: 50, color: Colors.blue),
        );

      default:
        return  SizedBox.shrink();
    }
  }

  static Color _parseColor(String hexCode) {
    hexCode = hexCode.replaceAll("#", "");
    if (hexCode.length == 6) {
      hexCode = "FF$hexCode";
    }
    return Color(int.parse("0x$hexCode"));
  }
}
