import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'loading_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return MaterialApp(
      title: 'Swiper',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff140635),
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

//Positioned(
//bottom: 24.0,
//left: 0.0,
//right: 0.0,
//child: Center(
//child: Opacity(
//opacity: 0.8,
//child: Shimmer.fromColors(
//child: Row(
//mainAxisSize: MainAxisSize.min,
//children: <Widget>[
//Image.asset(
//'assets/images/chevron_right.png',
//height: 20.0,
//),
//const Padding(
//padding: EdgeInsets.symmetric(horizontal: 4.0),
//),
//const Text(
//'Slide to unlock',
//style: TextStyle(
//fontSize: 28.0,
//),
//)
//],
//),
//baseColor: Colors.black12,
//highlightColor: Colors.white,
//loop: 3,
//),
//),
//))
