import 'package:flutter/material.dart';

class Category {
  final String key;
  final String label;
  final IconData icon;
  final Color color;

  const Category({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class AppCategories {
  AppCategories._();

  static const List<Category> expense = [
    Category(key: 'food', label: 'Food & Dining', icon: Icons.restaurant_rounded, color: Color(0xFFFF6B6B)),
    Category(key: 'transport', label: 'Transport', icon: Icons.directions_car_rounded, color: Color(0xFF4ECDC4)),
    Category(key: 'shopping', label: 'Shopping', icon: Icons.shopping_bag_rounded, color: Color(0xFFFFE66D)),
    Category(key: 'entertainment', label: 'Entertainment', icon: Icons.movie_rounded, color: Color(0xFFA855F7)),
    Category(key: 'bills', label: 'Bills & Utilities', icon: Icons.receipt_long_rounded, color: Color(0xFFF97316)),
    Category(key: 'health', label: 'Health', icon: Icons.medical_services_rounded, color: Color(0xFFEF4444)),
    Category(key: 'education', label: 'Education', icon: Icons.school_rounded, color: Color(0xFF3B82F6)),
    Category(key: 'other', label: 'Other', icon: Icons.more_horiz_rounded, color: Color(0xFF6B7280)),
  ];

  static const List<Category> income = [
    Category(key: 'salary', label: 'Salary', icon: Icons.account_balance_wallet_rounded, color: Color(0xFF10B981)),
    Category(key: 'freelance', label: 'Freelance', icon: Icons.laptop_rounded, color: Color(0xFF06B6D4)),
    Category(key: 'investment', label: 'Investment', icon: Icons.trending_up_rounded, color: Color(0xFF8B5CF6)),
    Category(key: 'gift', label: 'Gift', icon: Icons.card_giftcard_rounded, color: Color(0xFFEC4899)),
    Category(key: 'other_income', label: 'Other', icon: Icons.more_horiz_rounded, color: Color(0xFF6B7280)),
  ];

  static List<Category> get all => [...expense, ...income];

  static Category? fromKey(String key) {
    try {
      return all.firstWhere((c) => c.key == key);
    } catch (_) {
      return null;
    }
  }
}
