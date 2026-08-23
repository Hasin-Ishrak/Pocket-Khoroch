import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class CategoryModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class AppCategories {
  AppCategories._();

  static const List<CategoryModel> expenseCategories = [
    CategoryModel(
      id: 'food',
      name: 'Food',
      icon: Icons.restaurant_rounded,
      color: Color(0xFFEF9A9A),
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'transport',
      name: 'Transport',
      icon: Icons.directions_bus_rounded,
      color: Color(0xFF90CAF9),
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'rent',
      name: 'Rent / Hostel',
      icon: Icons.home_rounded,
      color: Color(0xFFCE93D8),
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'utility_bills',
      name: 'Utility Bills',
      icon: Icons.bolt_rounded,
      color: Color(0xFFFFCC80),
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'education',
      name: 'Books & Education',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF80CBC4),
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'entertainment',
      name: 'Entertainment',
      icon: Icons.movie_rounded,
      color: Color(0xFFF48FB1),
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'subscriptions',
      name: 'Subscriptions',
      icon: Icons.subscriptions_rounded,
      color: Color(0xFF9FA8DA),
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'health',
      name: 'Health',
      icon: Icons.local_hospital_rounded,
      color: Color(0xFFA5D6A7),
      type: TransactionType.expense,
    ),
    CategoryModel(
      id: 'others_expense',
      name: 'Others',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFFB0BEC5),
      type: TransactionType.expense,
    ),
  ];

  static const List<CategoryModel> incomeCategories = [
    CategoryModel(
      id: 'allowance',
      name: 'Allowance',
      icon: Icons.family_restroom_rounded,
      color: Color(0xFFB7FF72),
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'part_time_job',
      name: 'Part-time Job',
      icon: Icons.work_rounded,
      color: Color(0xFFA5D6A7),
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'scholarship',
      name: 'Scholarship',
      icon: Icons.school_rounded,
      color: Color(0xFF80CBC4),
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'gift',
      name: 'Gift',
      icon: Icons.card_giftcard_rounded,
      color: Color(0xFFF48FB1),
      type: TransactionType.income,
    ),
    CategoryModel(
      id: 'others_income',
      name: 'Others',
      icon: Icons.more_horiz_rounded,
      color: Color(0xFFB0BEC5),
      type: TransactionType.income,
    ),
  ];

  static List<CategoryModel> get all => [...expenseCategories, ...incomeCategories];

  static CategoryModel? findById(String id) {
    try {
      return all.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}