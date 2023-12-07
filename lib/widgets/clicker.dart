import 'dart:async';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class Clicker extends StatefulWidget {
  Clicker({
    required AnimationController rotateClickAnimationController,
    required Function onTap,
    double? spreadRadius,
    double? blurRadius,
    double? borderRadius,
  })  : _rotateClickAnimationController = rotateClickAnimationController,
        _onTap = onTap,
        _spreadRadius = spreadRadius ?? 10,
        _blurRadius = blurRadius ?? 70,
        _borderRadius = borderRadius ?? 500,
        super();

  final AnimationController _rotateClickAnimationController;
  final Function _onTap;
  final double _spreadRadius;
  final double _blurRadius;
  final double _borderRadius;

  @override
  _ClickerState createState() => _ClickerState();
}

class _ClickerState extends State<Clicker> {
  int clickPerSecond = 0;
  double baseRotate = 0;
  int clickPerSecCompt = 0;
  bool autoClickerEnabled = false;
  Timer? autoClickerTimer;

  @override
  void initState() {
    super.initState();

    Timer.periodic(const Duration(seconds: 1), (_) => updateClickPerSecond());
    Timer.periodic(const Duration(milliseconds: 1), (_) => updateRotation());
  }

  void updateClickPerSecond() {
    setState(() {
      clickPerSecond = clickPerSecCompt;
      clickPerSecCompt = 1;
    });
  }

  void updateRotation() {
    setState(() {
      baseRotate += 0.01 + (clickPerSecond * 0.01);
    });
  }

  void toggleAutoClicker() {
    setState(() {
      autoClickerEnabled = !autoClickerEnabled;
      if (autoClickerEnabled) {
        autoClickerTimer =
            Timer.periodic(const Duration(seconds: 2), (_) => widget._onTap());
      } else {
        autoClickerTimer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    autoClickerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget._rotateClickAnimationController,
      builder: (_, child) {
        return Transform.rotate(
          child: child,
          angle: widget._rotateClickAnimationController.velocity *
              (math.pi * baseRotate),
        );
      },
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          GestureDetector(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget._borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.8),
                    spreadRadius: widget._spreadRadius,
                    blurRadius: widget._blurRadius,
                    offset: Offset(0, 3), //shadow
                  ),
                ],
                image: const DecorationImage(
                  image: AssetImage('assets/images/cookie.png'),
                  fit: BoxFit.cover,
                ),
              ),
              height: MediaQuery.of(context).size.width * 0.5,
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            behavior: HitTestBehavior.translucent,
            onTap: () {
              widget._onTap();
              clickPerSecCompt++;
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: FloatingActionButton(
              onPressed: toggleAutoClicker,
              child: Icon(autoClickerEnabled ? Icons.pause : Icons.play_arrow),
            ),
          ),
        ],
      ),
    );
  }
}
