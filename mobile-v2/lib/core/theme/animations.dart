import 'package:flutter/material.dart';

/// JetStream Animation Constants
class AppAnimations {
  AppAnimations._();

  // Duration in milliseconds
  static const int fast = 150;
  static const int normal = 250;
  static const int slow = 350;
  static const int verySlow = 500;

  // Curves
  static const easeIn = Curves.easeIn;
  static const easeOut = Curves.easeOut;
  static const easeInOut = Curves.easeInOut;
  static const spring = Curves.elasticOut;
  static const bounce = Curves.bounceOut;

  // Custom Curves
  static const emphasizedDecelerate = Curves.easeOutCubic;
  static const emphasizedAccelerate = Curves.easeInCubic;

  // Stagger Delays (for list animations)
  static const int staggerShort = 50;
  static const int staggerMedium = 100;
  static const int staggerLong = 150;
}
