import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart';

import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _mockCheckForSession().then((status) {
      _navigateToHome();
    });
  }

  Future<bool> _mockCheckForSession() async {
    await Future.delayed(Duration(milliseconds: 4000), () {});

    return true;
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => Swiper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xff140635),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage(
                  'images/bg.png',
                ),
                fit: BoxFit.cover),
          ),
          child: Stack(
            children: <Widget>[
              Center(
                child: new Shimmer.fromColors(
                  period: Duration(milliseconds: 1200),
                  baseColor: Color.fromRGBO(0, 0, 0, 0),
                  highlightColor: Color(0xff89F2FC),
                  direction: ShimmerDirection.rtl,
                  child: new Container(
                      padding: EdgeInsets.all(49.0),
                      margin: EdgeInsets.only(bottom: 260.0),
                      child: Container(
                        padding: EdgeInsets.all(30.0),
                        child: Image.asset("images/Swiper.png"),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
