import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand core colors
  static const Color forestGraphite = Color(0xFF18251D);
  static const Color acidMint = Color(0xFFB7FF72);
  static const Color creamWhite = Color(0xFFF8F6F0);

  // Light mode
  static const Color lightBackground = creamWhite;
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEFEBE1);
  static const Color lightTextPrimary = forestGraphite;
  static const Color lightTextSecondary = Color(0xFF5C6B5F);

  // Dark mode
  static const Color darkBackground = forestGraphite;
  static const Color darkSurface = Color(0xFF203027);
  static const Color darkSurfaceVariant = Color(0xFF2A3B31);
  static const Color darkTextPrimary = Color(0xFFF3F7F0);
  static const Color darkTextSecondary = Color(0xFFA9BBA9);

  // Accent (same in both modes — the pop color)
  static const Color accent = acidMint;
  static const Color accentOnLight = Color(0xFF3F6B1D); // darker mint-green for text-on-cream contrast
  static const Color accentText = Color(0xFF18251D); // text ON TOP of acid mint buttons (dark text needed — mint is light)

  // Semantic colors (income/expense)
  static const Color income = Color(0xFF4CAF50);
  static const Color expense = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFB74D);

  // Borders / dividers
  static const Color lightBorder = Color(0xFFE0DCD0);
  static const Color darkBorder = Color(0xFF35473C);
}