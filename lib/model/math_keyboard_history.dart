import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistent storage for recently used math symbols.
///
/// Symbols are stored in a list ordered by most-recently-used first.
/// Up to [_maxStored] symbols are persisted, and up to [displayCount]
/// are presented for display.
class MathKeyboardHistory {
  static const _key = 'recent_math_keyboard';
  static const _maxStored = 20;

  /// The maximum number of symbols to present for display.
  static const displayCount = 20;

  /// Record that a symbol was used.
  ///
  /// Moves it to the head of the list if already present (deduplication),
  /// and trims the list to [_maxStored].
  static Future<void> recordSymbol(String symbol) async {
    final prefs = await SharedPreferences.getInstance();
    final current = _decode(prefs.getString(_key));
    current.remove(symbol);
    current.insert(0, symbol);
    if (current.length > _maxStored) {
      current.removeRange(_maxStored, current.length);
    }
    await prefs.setString(_key, jsonEncode(current));
  }

  /// Get the list of recently used symbols, up to [displayCount].
  static Future<List<String>> getRecentSymbols() async {
    final prefs = await SharedPreferences.getInstance();
    final current = _decode(prefs.getString(_key));
    return current.take(displayCount).toList();
  }

  /// Clear all stored symbols.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static List<String> _decode(String? value) {
    if (value == null) return [];
    try {
      final list = jsonDecode(value) as List;
      return List<String>.from(list);
    } catch (_) {
      return [];
    }
  }
}
