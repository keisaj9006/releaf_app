import 'package:flutter/material.dart';

/// The foundational visual language for Releaf's premium product surfaces.
///
/// These tokens are intentionally presentation-only. Product and access rules
/// remain in their feature domains.
abstract final class ReleafColors {
  static const background = Color(0xFF09100D);
  static const backgroundRaised = Color(0xFF0D1511);
  static const surface = Color(0xFF121C17);
  static const surfaceElevated = Color(0xFF18231D);
  static const surfaceSoft = Color(0xFF101914);

  static const textPrimary = Color(0xFFF3EFE4);
  static const textSecondary = Color(0xFFACB7AF);
  static const textMuted = Color(0xFF78857D);

  static const sage = Color(0xFF9CB8A3);
  static const sageStrong = Color(0xFF78A088);
  static const premium = Color(0xFFD7BA82);
  static const premiumSoft = Color(0xFF2A2419);

  static const border = Color(0xFF29362F);
  static const borderSoft = Color(0xFF202C26);
  static const glowSage = Color(0x337BA68B);
  static const glowPremium = Color(0x2ED7BA82);
}

abstract final class ReleafSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const section = 40.0;
  static const screen = 24.0;
}

abstract final class ReleafRadii {
  static const small = 12.0;
  static const medium = 16.0;
  static const large = 22.0;
  static const extraLarge = 28.0;
  static const pill = 999.0;
}

abstract final class ReleafControlSizes {
  static const compact = 40.0;
  static const standard = 48.0;
  static const prominent = 54.0;
}

abstract final class ReleafMotion {
  static const quick = Duration(milliseconds: 150);
  static const standard = Duration(milliseconds: 260);
  static const slow = Duration(milliseconds: 420);

  static const entranceCurve = Curves.easeOutCubic;
  static const emphasisCurve = Curves.easeInOutCubic;
}

abstract final class ReleafTypography {
  static const display = TextStyle(
    fontFamily: 'Poppins',
    color: ReleafColors.textPrimary,
    fontSize: 34,
    height: 1.12,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.1,
  );

  static const sectionTitle = TextStyle(
    fontFamily: 'Poppins',
    color: ReleafColors.textPrimary,
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const cardTitle = TextStyle(
    fontFamily: 'Poppins',
    color: ReleafColors.textPrimary,
    fontSize: 16,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.15,
  );

  static const body = TextStyle(
    fontFamily: 'Poppins',
    color: ReleafColors.textSecondary,
    fontSize: 14,
    height: 1.55,
    fontWeight: FontWeight.w400,
  );

  static const meta = TextStyle(
    fontFamily: 'Poppins',
    color: ReleafColors.textMuted,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  static const eyebrow = TextStyle(
    fontFamily: 'Poppins',
    color: ReleafColors.sage,
    fontSize: 11,
    height: 1.3,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
  );
}
