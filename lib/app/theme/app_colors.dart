import 'package:flutter/material.dart';

/// Primary Palette as specified by the Liah Academy design system:
///
/// | Role              | Hex     | Color Name          | Usage                                  |
/// |-------------------|---------|---------------------|----------------------------------------|
/// | Primary           | #0F4C81 | Deep Academic Blue  | App bars, primary buttons, links       |
/// | Primary Light     | #3A7CA5 | Medium Blue         | Hover / secondary actions              |
/// | Primary Container | #E8F1F8 | Soft Blue           | Selected items, subtle backgrounds     |
/// | Secondary         | #1A7A4C | Forest Green        | Success, "Paid", "Approved"            |
/// | Accent            | #E67E22 | Warm Orange         | Highlights, important CTAs, badges     |
/// | Background        | #F4F7FA | Cool Off-White      | Scaffold background                    |
/// | Surface           | #FFFFFF | White               | Cards, bottom sheets                   |
/// | Error             | #C0392B | Strong Red          | Errors, Rejected, Failed               |
/// | Warning           | #D68910 | Amber               | Pending, deadlines                     |
/// | Text Primary      | #1C2833 | Near Black          | Main text                              |
/// | Text Secondary    | #5D6D7E | Cool Grey           | Captions, hints                        |
abstract final class AppColors {
  // --- Canonical Primary Palette ---
  static const primary = Color(0xFF0F4C81);
  static const primaryLight = Color(0xFF3A7CA5);
  static const primaryContainer = Color(0xFFE8F1F8);

  static const secondary = Color(0xFF1A7A4C);
  static const secondaryContainer = Color(0xFFE8F8F0);

  static const accent = Color(0xFFE67E22);
  static const accentContainer = Color(0xFFFDF2E9);

  static const background = Color(0xFFF4F7FA);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceRaised = Color(0xFFFFFFFF);

  static const error = Color(0xFFC0392B);
  static const errorContainer = Color(0xFFFDEDEC);

  static const warning = Color(0xFFD68910);
  static const warningContainer = Color(0xFFFEF9E7);

  static const textPrimary = Color(0xFF1C2833);
  static const textSecondary = Color(0xFF5D6D7E);

  static const border = Color(0xFFE2E8F0);
  static const borderDark = Color(0xFFD5DBDB);

  // --- Fah Academy Navy & Gold Palette ---
  static const navy = Color(0xFF101D50);
  static const navyDeep = Color(0xFF0B153D);
  static const surfaceNavy = Color(0xFF17265E);
  static const surfaceRaisedNavy = Color(0xFF20336F);
  static const gold = Color(0xFFE4B62A);
  static const onNavy = Color(0xFFF7F8FC);
  static const muted = Color(0xFFB8C1D3);
  static const borderNavy = Color(0xFF344675);
  static const goldTint = Color(0x33E4B62A);
  static const successBackground = Color(0xFFD8F0DC);
  static const successText = Color(0xFF245333);
}
