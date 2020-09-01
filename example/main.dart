import 'package:flutter/material.dart';
import 'package:video_autoplay_list/autoplay_video.dart';
import 'package:video_autoplay_list/video_autoplay_list.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Autoplay Video List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
       home: Scaffold(
         appBar: AppBar(title: Text('Autoplay Video List'),),
         body: VideosList(),
       )
    );
  }
}

class VideosList extends StatelessWidget{

  final _videosURLs = [
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    'https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4',
  ];

  @override 
  Widget build(BuildContext context) {
    // autoplay list widget
    return AutoPlayList(
      itemCount: _videosURLs.length, 
      itemExtent: 400, 
      itemBuilder: (context, index) => Container(
        padding: EdgeInsets.all(1),
        // autoplay video widget (this widget can also be used individually without AutoPlayList)
        child: AutoPlayVideo(
          index: index,
          network: _videosURLs[index],
        ),
      )
    );
  }
}