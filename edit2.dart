class WidgetData {
  String type;
  double x;
  double y;
  double width;
  double height;
  Map<String, dynamic> props;

  WidgetData({
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.props,
  });


  factory WidgetData.textWidget() => WidgetData(
    type: 'Text',
    x: 100,
    y: 100,
    width: 200,
    height: 50,
    props: {'text': 'New Text', 'fontSize': 18, 'color': '#000000'},
  );

  factory WidgetData.imageWidget() => WidgetData(
    type: 'Image',
    x: 150,
    y: 150,
    width: 200,
    height: 150,
    props: {'url': 'https://picsum.photos/200'},
  );

  factory WidgetData.videoWidget() => WidgetData(
    type: 'Video',
    x: 200,
    y: 200,
    width: 300,
    height: 200,
    props: {
      'url':
      'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4'
    },
  );

  Map<String, dynamic> toJson() => {
    'type': type,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'props': props,
  };
}
