import 'package:flutter/material.dart';

class AppColors {
  // Global Night + Aurora Color System
  static const Color obsidian = Color(0xFF080A0F); // Deep Obsidian
  static const Color midnightNavy = Color(0xFF111827); // Midnight Blue
  static const Color midnight = Color(0xFF111827); // Midnight Blue alias
  static const Color deepSpace = Color(0xFF151D2B); // Elevated container / card

  // Accents
  static const Color electricCyan = Color(0xFF36D9FF); // Aurora Cyan
  static const Color auroraTeal = Color(0xFF35E0C0); // Mint Teal
  static const Color champagneSand = Color(0xFFD8C49A); // Champagne

  // Neutrals & Luxury Typography
  static const Color warmIvory = Color(0xFFF5F4ED); // Warm White
  static const Color slateLight = Color(0xFF9AA4B2); // Secondary Text
  static const Color slate = Color(0xFF7A8596);
  static const Color slateDark = Color(0xFF232D3F);

  // Surface Colors
  static const Color surfaceCard = Color(0xFF111827); // Midnight Blue card
  static const Color surfaceElevated = Color(0xFF1A2333);
  static const Color surfaceBorder = Color(0xFF1F293D);
  static const Color surfaceBorderHighlight = Color(0xFF36D9FF);

  // Semantic Status Colors
  static const Color success = Color(0xFF40D99A);
  static const Color emeraldVerified = Color(0xFF40D99A);
  static const Color warning = Color(0xFFF3C969);
  static const Color sunsetAmber = Color(0xFFF3C969);
  static const Color danger = Color(0xFFFF647C);
  static const Color info = Color(0xFF36D9FF);
  static const Color cardBackgroundDark = Color(0xFF151D2B);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [electricCyan, auroraTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF151D2C), Color(0xFF0F1623)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient champagneGradient = LinearGradient(
    colors: [Color(0xFFEADFC8), Color(0xFFD8C49A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient routeGlowGradient = LinearGradient(
    colors: [
      Color(0x0036D9FF),
      Color(0xFF36D9FF),
      Color(0xFF35E0C0),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
