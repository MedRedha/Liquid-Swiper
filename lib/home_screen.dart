import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: non_constant_identifier_names
final String Flutter = 'https://cdn.worldvectorlogo.com/logos/flutter-logo.svg';

void main() => runApp(Swiper());

class Swiper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Swiper',
      home: Gooey(),
    );
  }
}

class Gooey extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: Center(
          child: GooeyCarousel(),
        ),
      ),
    );
  }
}

enum Side { left, top, right, bottom }

class GooeyCarousel extends StatefulWidget {
  final List<Widget> children;

  GooeyCarousel({this.children}) : super();

  @override
  GooeyCarouselState createState() => GooeyCarouselState();
}

class GooeyCarouselState extends State<GooeyCarousel>
    with SingleTickerProviderStateMixin {
  int _index = 1; // index of the base (bottom) child
  int _dragIndex; // index of the top child
  Offset _dragOffset; // starting offset of the drag
  double _dragDirection; // +1 when dragging left to right, -1 for right to left
  bool _dragCompleted; // has the drag successfully resulted in a swipe
  Widget _image1;
  Widget _image2;
  Widget _image3;
  GooeyEdge _edge;
  Ticker _ticker;
  GlobalKey _key = GlobalKey();

  @override
  void initState() {
    _edge = GooeyEdge(count: 25.0);
    _ticker = createTicker(_tick)..start();
    _image1 = FutureBuilder(
      future: Future.delayed(Duration(seconds: 5)),
      builder: (c, s) => s.connectionState == ConnectionState.done
          ? Image.asset('images/WuuD.png', height: 200.0, width: 200.0)
          : Shimmer.fromColors(
              baseColor: Colors.black12,
              highlightColor: Colors.white,
              loop: 3,
              child:
                  Image.asset('images/WuuD.png', height: 200.0, width: 200.0),
            ),
    );
    _image2 = Padding(
      padding: EdgeInsets.all(20),
      child: FutureBuilder(
        future: Future.delayed(Duration(seconds: 5)),
        builder: (c, s) => s.connectionState == ConnectionState.done
            ? SvgPicture.network(Flutter, height: 200.0, width: 200.0
//              placeholderBuilder: (BuildContext context) => Container(
//                  padding: const EdgeInsets.all(30.0),
//                  child: const CircularProgressIndicator()),
                )
            : Shimmer.fromColors(
                baseColor: Colors.black12,
                highlightColor: Colors.white,
                loop: 3,
                child: SvgPicture.network(Flutter, height: 200.0, width: 200.0
//              placeholderBuilder: (BuildContext context) => Container(
//                  padding: const EdgeInsets.all(30.0),
//                  child: const CircularProgressIndicator()),
                    ),
              ),
      ),
    );
    _image3 = FutureBuilder(
      future: Future.delayed(Duration(seconds: 5)),
      builder: (c, s) => s.connectionState == ConnectionState.done
          ? Image.asset('images/flutter.png', height: 200.0, width: 200.0)
          : Shimmer.fromColors(
              baseColor: Colors.black12,
              highlightColor: Colors.white,
              loop: 3,
              child: Image.asset('images/flutter.png',
                  height: 200.0, width: 200.0),
            ),
    );
    super.initState();
  }

  void didChange(State value) {
    setState(() {
      _image1 = _image1;
      _image2 = _image2;
      _image3 = _image3;
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _tick(Duration duration) {
    _edge.tick(duration);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        key: _key,
        onPanDown: (details) => _handlePanDown(details, _getSize()),
        onPanUpdate: (details) => _handlePanUpdate(details, _getSize()),
        onPanEnd: (details) => _handlePanEnd(details, _getSize()),
        child: Stack(
          children: <Widget>[
            cards(_index % 3),
            _dragIndex == null
                ? SizedBox()
                : ClipPath(
                    child: cards(_dragIndex % 3),
                    clipBehavior: Clip.hardEdge,
                    clipper: GooeyEdgeClipper(_edge, margin: 10.0),
                  ),
          ],
        ));
  }

  Widget cards(int index) {
    if (index == 0) {
      return ContentCard(
        index: index,
        color: Color.fromARGB(255, 53, 101, 248),
        image: _image1,
      );
    }
    if (index == 1) {
      return ContentCard(
        index: index,
        color: Color.fromARGB(255, 240, 101, 79),
        image: _image2,
      );
    }
    if (index == 2) {
      return ContentCard(
        index: index,
        color: Color.fromARGB(255, 240, 147, 61),
        image: _image3,
      );
    }
    return Container();
  }

  Size _getSize() {
    final RenderBox box = _key.currentContext.findRenderObject();
    return box.size;
  }

  void _handlePanDown(DragDownDetails details, Size size) {
    if (_dragIndex != null && _dragCompleted) {
      _index = _dragIndex;
    }
    _dragIndex = null;
    _dragOffset = details.localPosition;
    _dragCompleted = false;
    _dragDirection = 0;

    _edge.farEdgeTension = 0.0;
    _edge.edgeTension = 0.01;
    _edge.reset();
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    double dx = details.globalPosition.dx - _dragOffset.dx;

    if (!_isSwipeActive(dx)) {
      return;
    }
    if (_isSwipeComplete(dx, size.width)) {
      return;
    }

    if (_dragDirection == -1) {
      dx = size.width + dx;
    }
    _edge.applyTouchOffset(Offset(dx, details.localPosition.dy), size);
  }

  bool _isSwipeActive(double dx) {
    // check if a swipe is just starting:
    if (_dragDirection == 0.0 && dx.abs() > 20.0) {
      _dragDirection = dx.sign;
      _edge.side = _dragDirection == 1.0 ? Side.left : Side.right;
      setState(() {
        _dragIndex = _index - _dragDirection.toInt();
      });
    }
    return _dragDirection != 0.0;
  }

  bool _isSwipeComplete(double dx, double width) {
    if (_dragDirection == 0.0) {
      return false;
    } // haven't started
    if (_dragCompleted) {
      return true;
    } // already done

    // check if swipe is just completed:
    double availW = _dragOffset.dx;
    if (_dragDirection == 1) {
      availW = width - availW;
    }
    double ratio = dx * _dragDirection / availW;

    if (ratio > 0.8 && availW / width > 0.5) {
      _dragCompleted = true;
      _edge.farEdgeTension = 0.01;
      _edge.edgeTension = 0.0;
      _edge.applyTouchOffset();
    }
    return _dragCompleted;
  }

  void _handlePanEnd(DragEndDetails details, Size size) {
    _edge.applyTouchOffset();
  }
}

class ContentCard extends StatefulWidget {
  final Color color;
  final int index;
  final Widget image;

  ContentCard({this.color, this.index, this.image}) : super();

  @override
  _ContentCardState createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  Ticker _ticker;
  @override
  void initState() {
    _ticker = Ticker((d) {
      setState(() {});
    })
      ..start();
    super.initState();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Roboto'),
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          centerTitle: true,
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: 'Animated Swipe by ',
              style: TextStyle(
                  color: Colors.white, fontSize: 20, fontFamily: 'Roboto'),
              children: <TextSpan>[
                TextSpan(
                  text: 'Med Redha',
                  style: new TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'Roboto Medium'),
                  recognizer: new TapGestureRecognizer()
                    ..onTap = () {
                      launch('https://github.com/MedRedha');
                    },
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 1.0,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[
            Container(
              child: Stack(
                children: <Widget>[
                  Positioned.fill(child: AnimatedBackground()),
                  Positioned.fill(child: Particles(10)),
                ],
              ),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(child: widget.image),
                      ],
                    ),
                  ),
                  Container(
                    margin: new EdgeInsets.only(bottom: 200),
                    child: this.widget.index == 0
                        ? RichText(
                            text: TextSpan(
                              text: 'Powered by The ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Roboto'),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'WuuD Team',
                                  style: new TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto Medium'),
                                  recognizer: new TapGestureRecognizer()
                                    ..onTap = () {
                                      launch('https://github.com/WuuD-Team');
                                    },
                                ),
                              ],
                            ),
                          )
                        : this.widget.index == 1
                            ? RichText(
                                text: TextSpan(
                                  text: 'Coding Your ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Roboto'),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text: 'Ideas',
                                      style: new TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto Medium'),
                                      recognizer: new TapGestureRecognizer()
                                        ..onTap = () {
                                          launch(
                                              'https://github.com/WuuD-Team');
                                        },
                                    ),
                                  ],
                                ),
                              )
                            : this.widget.index == 2
                                ? RichText(
                                    text: TextSpan(
                                      text: 'Developers by ',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontFamily: 'Roboto'),
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: 'Passion',
                                          style: new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Roboto Medium'),
                                          recognizer: new TapGestureRecognizer()
                                            ..onTap = () {
                                              launch(
                                                  'https://github.com/WuuD-Team');
                                            },
                                        ),
                                      ],
                                    ),
                                  )
                                : Text(" "),
                  ),
                  Container(
                    child: Stack(
                      children: <Widget>[
                        _buildPageIndicator(this.widget.index)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 25,
                    ),
                    Text(" SWIPE",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Roboto Medium')),
                  ]),
            ),
            _indicator(0),
            SizedBox(
              width: 10,
            ),
            _indicator(1),
            SizedBox(
              width: 10,
            ),
            _indicator(2),
            Expanded(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Text("SWIPE ",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Roboto Medium')),
                    Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 25,
                    ),
                  ]),
            ),
          ],
        ));
  }

  Widget _indicator(int idx) {
    BoxDecoration _selected =
        BoxDecoration(color: Colors.white, shape: BoxShape.circle);
    BoxDecoration _unselected = BoxDecoration(
      border: Border.all(color: Colors.white),
      shape: BoxShape.circle,
    );
    return Container(
      decoration: this.widget.index == idx ? _selected : _unselected,
      height: 10,
      width: 10,
      //  width: 30,
    );
  }
}

class GooeyEdge {
  List<_GooeyPoint> points;
  Side side;
  double edgeTension = 0.01;
  double farEdgeTension = 0.0;
  double touchTension = 0.1;
  double pointTension = 0.25;
  double damping = 0.9;
  double maxTouchDistance = 0.15;
  int lastT = 0;

  FractionalOffset touchOffset;

  GooeyEdge({count = 10, this.side = Side.left}) {
    points = [];
    for (int i = 0; i < count; i++) {
      points.add(_GooeyPoint(0.0, i / (count - 1)));
    }
  }

  void reset() {
    points.forEach((pt) => pt.x = pt.velX = pt.velY = 0.0);
  }

  void applyTouchOffset([Offset offset, Size size]) {
    if (offset == null) {
      touchOffset = null;
      return;
    }
    FractionalOffset o = FractionalOffset.fromOffsetAndSize(offset, size);
    if (side == Side.left) {
      touchOffset = o;
    } else if (side == Side.right) {
      touchOffset = FractionalOffset(1.0 - o.dx, 1.0 - o.dy);
    } else if (side == Side.top) {
      touchOffset = FractionalOffset(o.dy, 1.0 - o.dx);
    } else {
      touchOffset = FractionalOffset(1.0 - o.dy, o.dx);
    }
  }

  Path buildPath(Size size, {double margin = 0.0}) {
    if (points == null || points.length == 0) {
      return null;
    }

    Matrix4 mtx = _getTransform(size, margin);

    Path path = Path();
    int l = points.length;
    Offset pt = _GooeyPoint(-margin, 1.0).toOffset(mtx), pt1;
    path.moveTo(pt.dx, pt.dy); // bl

    pt = _GooeyPoint(-margin, 0.0).toOffset(mtx);
    path.lineTo(pt.dx, pt.dy); // tl

    pt = points[0].toOffset(mtx);
    path.lineTo(pt.dx, pt.dy); // tr

    pt1 = points[1].toOffset(mtx);
    path.lineTo(pt.dx + (pt1.dx - pt.dx) / 2, pt.dy + (pt1.dy - pt.dy) / 2);

    for (int i = 2; i < l; i++) {
      pt = pt1;
      pt1 = points[i].toOffset(mtx);
      double midX = pt.dx + (pt1.dx - pt.dx) / 2;
      double midY = pt.dy + (pt1.dy - pt.dy) / 2;
      path.quadraticBezierTo(pt.dx, pt.dy, midX, midY);
    }

    path.lineTo(pt1.dx, pt1.dy); // br
    path.close(); // bl

    return path;
  }

  void tick(Duration duration) {
    if (points == null || points.length == 0) {
      return;
    }
    int l = points.length;
    double t = min(1.5, (duration.inMilliseconds - lastT) / 1000 * 60);
    lastT = duration.inMilliseconds;
    double dampingT = pow(damping, t);

    for (int i = 0; i < l; i++) {
      _GooeyPoint pt = points[i];
      pt.velX -= pt.x * edgeTension * t;
      pt.velX += (1.0 - pt.x) * farEdgeTension * t;
      if (touchOffset != null) {
        double ratio =
            max(0.0, 1.0 - (pt.y - touchOffset.dy).abs() / maxTouchDistance);
        pt.velX += (touchOffset.dx - pt.x) * touchTension * ratio * t;
      }
      if (i > 0) {
        _addPointTension(pt, points[i - 1].x, t);
      }
      if (i < l - 1) {
        _addPointTension(pt, points[i + 1].x, t);
      }
      pt.velX *= dampingT;
    }

    for (int i = 0; i < l; i++) {
      _GooeyPoint pt = points[i];
      pt.x += pt.velX * t;
    }
  }

  Matrix4 _getTransform(Size size, double margin) {
    bool vertical = side == Side.top || side == Side.bottom;
    double w = (vertical ? size.height : size.width) + margin * 2;
    double h = (vertical ? size.width : size.height) + margin * 2;

    Matrix4 mtx = Matrix4.identity()
      ..translate(-margin, 0.0)
      ..scale(w, h);
    if (side == Side.top) {
      mtx
        ..rotateZ(pi / 2)
        ..translate(0.0, -1.0);
    } else if (side == Side.right) {
      mtx
        ..rotateZ(pi)
        ..translate(-1.0, -1.0);
    } else if (side == Side.bottom) {
      mtx
        ..rotateZ(pi * 3 / 2)
        ..translate(-1.0, 0.0);
    }

    return mtx;
  }

  void _addPointTension(_GooeyPoint pt0, double x, double t) {
    pt0.velX += (x - pt0.x) * pointTension * t;
  }
}

class _GooeyPoint {
  double x;
  double y;
  double velX = 0.0;
  double velY = 0.0;

  _GooeyPoint([this.x = 0.0, this.y = 0.0]);

  Offset toOffset([Matrix4 transform]) {
    Offset o = Offset(x, y);
    if (transform == null) {
      return o;
    }
    return MatrixUtils.transformPoint(transform, o);
  }
}

class GooeyEdgeClipper extends CustomClipper<Path> {
  GooeyEdge edge;
  double margin;

  GooeyEdgeClipper(this.edge, {this.margin = 0.0}) : super();

  @override
  Path getClip(Size size) {
    return edge.buildPath(size, margin: margin);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class ParticleBackgroundApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      Positioned.fill(child: AnimatedBackground()),
      Positioned.fill(child: Particles(20)),
    ]);
  }
}

class Particles extends StatefulWidget {
  final int numberOfParticles;

  Particles(this.numberOfParticles);

  @override
  _ParticlesState createState() => _ParticlesState();
}

class _ParticlesState extends State<Particles> {
  final Random random = Random();

  final List<ParticleModel> particles = [];

  @override
  void initState() {
    List.generate(widget.numberOfParticles, (index) {
      particles.add(ParticleModel(random));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return Rendering(
      startTime: Duration(seconds: 30),
      onTick: _simulateParticles,
      builder: (context, time) {
        return CustomPaint(
          painter: ParticlePainter(particles, time),
        );
      },
    );
  }

  _simulateParticles(Duration time) {
    particles.forEach((particle) => particle.maintainRestart(time));
  }
}

class ParticleModel {
  Animatable tween;
  double size;
  // ignore: deprecated_member_use
  AnimationProgress animationProgress;
  Random random;

  ParticleModel(this.random) {
    restart();
  }

  restart({Duration time = Duration.zero}) {
    final startPosition = Offset(-0.2 + 1.4 * random.nextDouble(), 1.2);
    final endPosition = Offset(-0.2 + 1.4 * random.nextDouble(), -0.2);
    final duration = Duration(milliseconds: 3000 + random.nextInt(6000));

    // ignore: deprecated_member_use
    tween = MultiTrackTween([
      // ignore: deprecated_member_use
      Track("x").add(
          duration, Tween(begin: startPosition.dx, end: endPosition.dx),
          curve: Curves.easeInOutSine),
      // ignore: deprecated_member_use
      Track("y").add(
          duration, Tween(begin: startPosition.dy, end: endPosition.dy),
          curve: Curves.easeIn),
    ]);
    // ignore: deprecated_member_use
    animationProgress = AnimationProgress(duration: duration, startTime: time);
    size = 0.2 + random.nextDouble() * 0.4;
  }

  maintainRestart(Duration time) {
    if (animationProgress.progress(time) == 1.0) {
      restart(time: time);
    }
  }
}

class ParticlePainter extends CustomPainter {
  List<ParticleModel> particles;
  Duration time;

  ParticlePainter(this.particles, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withAlpha(70);

    particles.forEach((particle) {
      var progress = particle.animationProgress.progress(time);
      final animation = particle.tween.transform(progress);
      final position =
          Offset(animation["x"] * size.width, animation["y"] * size.height);
      canvas.drawCircle(position, size.width * 0.1 * particle.size, paint);
    });
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class AnimatedBackground extends StatefulWidget {
  @override
  AnimatedBackgroundState createState() => AnimatedBackgroundState();
}

class AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 20));

    _backgroundAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              _animationController.reset();
              _animationController.forward();
            }
          });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    final tween = MultiTrackTween(
      [
        // ignore: deprecated_member_use
        Track("color1").add(
          Duration(seconds: 1),
          ColorTween(begin: Color(0xff8a113a), end: Colors.lightBlue.shade900),
        ),
        // ignore: deprecated_member_use
        Track("color2").add(
          Duration(seconds: 1),
          ColorTween(begin: Color(0xff440216), end: Colors.blue.shade600),
        )
      ],
    );

    // ignore: deprecated_member_use
    return ControlledAnimation(
      // ignore: deprecated_member_use
      playback: Playback.MIRROR,
      tween: tween,
      duration: tween.duration,
      builder: (context, animation) {
        return Stack(
          children: <Widget>[
            ConstrainedBox(
              child: Image.asset(
                'images/background.png',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                alignment: FractionalOffset(_backgroundAnimation.value, 0),
              ),
              constraints: BoxConstraints.expand(),
            ),
            Container(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 7, sigmaY: 7),
                child: Container(
                    decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0),
                )),
              ),
            ),
          ],
        );

//        CHANGING THE BACKGROUND TO ANIMATED COLORS
//          Container(
//          decoration: BoxDecoration(
//            gradient: LinearGradient(
//              begin: Alignment.topLeft,
//              end: Alignment.bottomRight,
//              colors: [animation["color1"], animation["color2"]],
//            ),
//          ),
//        );
      },
    );
  }
}
