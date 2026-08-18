import 'package:flutter/material.dart';

class VentvoMotion {
  VentvoMotion._();

  // General screen transitions.
  static const Duration screenTransition =
      Duration(milliseconds: 450);

  // Slightly slower movement for expressive moments.
  static const Duration expressive =
      Duration(milliseconds: 650);

  // Crash Out / immersive experiences.
  static const Duration immersive =
      Duration(milliseconds: 900);

  // Small UI interactions.
  static const Duration micro =
      Duration(milliseconds: 180);

  // Standard curves.
  static const Curve standard =
      Curves.easeOutCubic;

  static const Curve expressiveCurve =
      Curves.easeOutBack;

  static const Curve gentle =
      Curves.easeOut;

  static const Curve immersiveCurve =
      Curves.easeInOutCubic;
}