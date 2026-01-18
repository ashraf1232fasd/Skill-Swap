import 'package:flutter/material.dart';
import 'dart:math';

class WalletProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _savedCards = [
    {
      'id': 1,
      'type': 'visa',
      'number': '4242 4242 4242 4242',
      'holder': 'ASHRAF USER',
      'expiry': '12/28',
      'color': const Color(0xFF1A237E),
    },
  ];

  List<Map<String, dynamic>> get savedCards => _savedCards;

  void addCard({
    required String number,
    required String holder,
    required String expiry,
  }) {
    _savedCards.add({
      'id': _savedCards.length + 1,
      'type': number.startsWith('4') ? 'visa' : 'mastercard',
      'number': number,
      'holder': holder.toUpperCase(),
      'expiry': expiry,
      'color': _getRandomColor(),
    });
    notifyListeners(); 
  }

  Color _getRandomColor() {
    final colors = [
      const Color(0xFF2E7D32),
      const Color(0xFFC62828),
      const Color(0xFFEF6C00),
      const Color(0xFF00695C),
      const Color(0xFF4527A0),
      Colors.black87,
    ];
    return colors[Random().nextInt(colors.length)];
  }
}