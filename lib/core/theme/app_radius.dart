import 'package:flutter/material.dart';

/// ==============================================================================
/// SMYL GLOBAL — DESIGN SYSTEM CORNER RADIUS CONSTANTS
/// ==============================================================================
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double button = 14.0;
  static const double card = 16.0;
  static const double cardLarge = 20.0;
  static const double modal = 24.0;
  static const double pill = 30.0;
  static const double circle = 999.0;

  // BorderRadius objects
  static final BorderRadius radiusXs = BorderRadius.circular(xs);
  static final BorderRadius radiusSm = BorderRadius.circular(sm);
  static final BorderRadius radiusMd = BorderRadius.circular(md);
  static final BorderRadius radiusButton = BorderRadius.circular(button);
  static final BorderRadius radiusCard = BorderRadius.circular(card);
  static final BorderRadius radiusCardLarge = BorderRadius.circular(cardLarge);
  static final BorderRadius radiusModal = BorderRadius.circular(modal);
  static final BorderRadius radiusPill = BorderRadius.circular(pill);
}
