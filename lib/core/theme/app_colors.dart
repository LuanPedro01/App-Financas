import 'package:flutter/material.dart';

abstract final class AppColors {
  // ─── Brand ───────────────────────────────────────────────────────────────
  static const brand50 = Color(0xFFE8F4FD);
  static const brand100 = Color(0xFFBFDFF8);
  static const brand200 = Color(0xFF92C9F3);
  static const brand300 = Color(0xFF5FB0ED);
  static const brand400 = Color(0xFF3A9BE8);
  static const brand500 = Color(0xFF1A87E3); // primary
  static const brand600 = Color(0xFF1579D4);
  static const brand700 = Color(0xFF0E67C1);
  static const brand800 = Color(0xFF0855A8);
  static const brand900 = Color(0xFF003980);

  // ─── Accent ──────────────────────────────────────────────────────────────
  static const accent50 = Color(0xFFF3EEFF);
  static const accent100 = Color(0xFFDED0FD);
  static const accent200 = Color(0xFFC5AEFB);
  static const accent300 = Color(0xFFA886F9);
  static const accent400 = Color(0xFF9168F7);
  static const accent500 = Color(0xFF7B4CF5); // accent primary
  static const accent600 = Color(0xFF6E3EE9);
  static const accent700 = Color(0xFF5D2ED7);
  static const accent800 = Color(0xFF4C1EC4);
  static const accent900 = Color(0xFF2E00A2);

  // ─── Semantic ─────────────────────────────────────────────────────────────
  static const success50 = Color(0xFFE8FDF5);
  static const success400 = Color(0xFF34D399);
  static const success500 = Color(0xFF10B981);
  static const success600 = Color(0xFF059669);

  static const warning50 = Color(0xFFFFFBEB);
  static const warning400 = Color(0xFFFBBF24);
  static const warning500 = Color(0xFFF59E0B);
  static const warning600 = Color(0xFFD97706);

  static const error50 = Color(0xFFFEF2F2);
  static const error400 = Color(0xFFF87171);
  static const error500 = Color(0xFFEF4444);
  static const error600 = Color(0xFFDC2626);

  static const info50 = Color(0xFFEFF6FF);
  static const info400 = Color(0xFF60A5FA);
  static const info500 = Color(0xFF3B82F6);
  static const info600 = Color(0xFF2563EB);

  // ─── Income / Expense ─────────────────────────────────────────────────────
  static const income = success500;
  static const expense = error500;
  static const transfer = brand500;
  static const investment = accent500;

  // ─── Dark Surface Palette ─────────────────────────────────────────────────
  static const dark900 = Color(0xFF060609);
  static const dark850 = Color(0xFF0C0D12);
  static const dark800 = Color(0xFF111318);
  static const dark750 = Color(0xFF161820);
  static const dark700 = Color(0xFF1C1F28);
  static const dark650 = Color(0xFF222631);
  static const dark600 = Color(0xFF282D3A);
  static const dark550 = Color(0xFF2E3444);
  static const dark500 = Color(0xFF353C4E);
  static const dark400 = Color(0xFF4A5267);
  static const dark300 = Color(0xFF636D88);
  static const dark200 = Color(0xFF8892AA);
  static const dark100 = Color(0xFFB8BFCE);
  static const dark50 = Color(0xFFE2E5EC);

  // ─── Light Surface Palette ────────────────────────────────────────────────
  static const light900 = Color(0xFFF8F9FC);
  static const light800 = Color(0xFFF1F3F8);
  static const light700 = Color(0xFFE8EBF2);
  static const light600 = Color(0xFFDDE1EC);
  static const light500 = Color(0xFFCDD3E0);
  static const light400 = Color(0xFFB8C0D0);
  static const light300 = Color(0xFF9AA4B8);

  // ─── Chart Colors ─────────────────────────────────────────────────────────
  static const List<Color> chartPalette = [
    Color(0xFF1A87E3),
    Color(0xFF7B4CF5),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
  ];

  // ─── Category Colors ──────────────────────────────────────────────────────
  static const categoryFood = Color(0xFFF97316);
  static const categoryTransport = Color(0xFF3B82F6);
  static const categoryHealth = Color(0xFF10B981);
  static const categoryEducation = Color(0xFF8B5CF6);
  static const categoryEntertainment = Color(0xFFEC4899);
  static const categoryHome = Color(0xFF14B8A6);
  static const categoryShopping = Color(0xFFF59E0B);
  static const categoryTravel = Color(0xFF06B6D4);
  static const categoryInvestment = Color(0xFF7B4CF5);
  static const categoryIncome = Color(0xFF10B981);
  static const categoryOther = Color(0xFF6B7280);

  // ─── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brand500, accent500],
  );

  static const LinearGradient incomeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );

  static const LinearGradient expenseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dark700, dark650],
  );

  static const LinearGradient glassDarkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x26FFFFFF), Color(0x0DFFFFFF)],
  );

  // ─── Transparent ──────────────────────────────────────────────────────────
  static const transparent = Colors.transparent;
  static const white = Colors.white;
  static const black = Colors.black;
}
