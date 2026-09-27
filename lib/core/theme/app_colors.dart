import 'package:flutter/material.dart';

/// ==============================================================================
/// SMYL GLOBAL — DESIGN SYSTEM COLOR PALETTE ("GLOBAL AURORA")
/// ==============================================================================
/// Custom visual language inspired by night skies, international flight corridors,
/// airport illumination, and digital velocity.
/// ==============================================================================
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------------
  // 1. Dark Theme Background Hierarchy
  // ---------------------------------------------------------------------------
  /// Primary canvas background (#070A0F)
  static const Color obsidian = Color(0xFF070A0F);

  /// Secondary background for sectioning (#0D121A)
  static const Color midnightNavy = Color(0xFF0D121A);
  static const Color midnight = Color(0xFF0D121A);
  static const Color deepSpace = Color(0xFF0D121A);

  /// Standard surface (#131A24)
  static const Color surface = Color(0xFF131A24);

  /// Card surface (#111923)
  static const Color surfaceCard = Color(0xFF111923);
  static const Color cardBackgroundDark = Color(0xFF111923);

  /// Elevated card surface (#17212D)
  static const Color cardElevated = Color(0xFF17212D);

  /// Elevated surface for dialogs, modals & bottom sheets (#192230)
  static const Color surfaceElevated = Color(0xFF192230);

  /// Bottom navigation bar background (#0B1017)
  static const Color bottomNav = Color(0xFF0B1017);

  // ---------------------------------------------------------------------------
  // 2. Borders & Dividers
  // ---------------------------------------------------------------------------
  /// Subtle card and container border (#24303D)
  static const Color surfaceBorder = Color(0xFF24303D);

  /// Input field resting border (#273342)
  static const Color inputBorder = Color(0xFF273342);

  /// Active focus and highlight border (#36D9FF)
  static const Color surfaceBorderHighlight = Color(0xFF36D9FF);

  // ---------------------------------------------------------------------------
  // 3. Primary & Secondary Brand Accents
  // ---------------------------------------------------------------------------
  /// Primary Brand Accent — AURORA CYAN (#36D9FF)
  /// Used for primary CTAs, active nav items, live flight vectors, focus states
  static const Color electricCyan = Color(0xFF36D9FF);
  static const Color auroraCyan = Color(0xFF36D9FF);

  /// Secondary Brand Accent — AURORA TEAL (#36E0C0)
  /// Used for verified checkmarks, completed milestones, escrow releases
  static const Color auroraTeal = Color(0xFF36E0C0);

  /// Premium Accent — CHAMPAGNE GOLD (#D8C49A)
  /// Used sparingly for earnings, premium tags, airport codes, brand highlights
  static const Color champagneSand = Color(0xFFD8C49A);
  static const Color champagneGold = Color(0xFFD8C49A);

  // ---------------------------------------------------------------------------
  // 4. Text Hierarchy (Dark Theme)
  // ---------------------------------------------------------------------------
  /// Primary Text — Warm White (#F5F7FA) — High contrast
  static const Color warmIvory = Color(0xFFF5F7FA);
  static const Color textPrimary = Color(0xFFF5F7FA);

  /// Secondary Text — Slate Light (#A5AFBD)
  static const Color slateLight = Color(0xFFA5AFBD);
  static const Color textSecondary = Color(0xFFA5AFBD);

  /// Muted Text — Slate (#687384)
  static const Color slate = Color(0xFF687384);
  static const Color textMuted = Color(0xFF687384);

  /// Disabled / Inactive Text (#454E5C)
  static const Color slateDark = Color(0xFF454E5C);
  static const Color textDisabled = Color(0xFF454E5C);

  // ---------------------------------------------------------------------------
  // 5. Semantic Status Colors
  // ---------------------------------------------------------------------------
  /// SUCCESS — Confirmed payment, delivered parcel, verified KYC (#3DDF9B)
  static const Color success = Color(0xFF3DDF9B);
  static const Color emeraldVerified = Color(0xFF3DDF9B);

  /// WARNING — Awaiting handover, escrow hold, verification needed (#F2C866)
  static const Color warning = Color(0xFFF2C866);
  static const Color sunsetAmber = Color(0xFFF2C866);

  /// ERROR — Failed transaction, dispute open, invalid format (#FF647C)
  static const Color danger = Color(0xFFFF647C);

  /// INFO — System updates, flight telemetry (#36D9FF)
  static const Color info = Color(0xFF36D9FF);

  // ---------------------------------------------------------------------------
  // 6. Light Theme Palette (Section 26: Ivory + Deep Ink + Aurora Accents)
  // ---------------------------------------------------------------------------
  static const Color lightBackground = Color(0xFFF5F3EE);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF667085);
  static const Color lightPrimary = Color(0xFF087F9B);
  static const Color lightTeal = Color(0xFF008F78);
  static const Color lightChampagne = Color(0xFFA88B50);

  // ---------------------------------------------------------------------------
  // 7. Signature Brand Gradients
  // ---------------------------------------------------------------------------
  /// Aurora Cyan to Aurora Teal brand gradient
  static const LinearGradient brandGradient = LinearGradient(
    colors: [electricCyan, auroraTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Subtle atmospheric gradient for cards and hero panels
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF17212D), Color(0xFF111923)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Hero background atmospheric glow (Obsidian to Midnight)
  static const LinearGradient atmosphericHeroGradient = LinearGradient(
    colors: [Color(0xFF070A0F), Color(0xFF0D121A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Champagne Gold luxury gradient
  static const LinearGradient champagneGradient = LinearGradient(
    colors: [Color(0xFFEADFC8), Color(0xFFD8C49A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Active flight route glow
  static const LinearGradient routeGlowGradient = LinearGradient(
    colors: [
      Color(0x0036D9FF),
      Color(0xFF36D9FF),
      Color(0xFF36E0C0),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
