import 'package:flutter/material.dart';

// Helper to map icon name string to IconData
IconData getIconData(String iconName) {
  switch (iconName) {
    case 'restaurant':
      return Icons.restaurant;
    case 'directions_car':
      return Icons.directions_car;
    case 'shopping_cart':
      return Icons.shopping_cart;
    case 'movie':
      return Icons.movie;
    case 'receipt':
      return Icons.receipt;
    case 'local_hospital':
      return Icons.local_hospital;
    case 'flight':
      return Icons.flight;
    case 'school':
      return Icons.school;
    case 'work':
      return Icons.work;
    case 'trending_up':
      return Icons.trending_up;
    case 'card_giftcard':
      return Icons.card_giftcard;
    case 'attach_money':
      return Icons.attach_money;
    default:
      return Icons.category;
  }
}

Color parseColor(String colorString) {
  // colorString is like '#FF5722'
  return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
} 