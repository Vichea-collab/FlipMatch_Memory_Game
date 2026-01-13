import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/level_config.dart';

class LevelRepository {
  static const String _storageKey = 'levels';

  static const List<LevelConfig> _defaultLevels = [
    LevelConfig(id: 1, rows: 2, cols: 2, timeLimitSeconds: 90, maxMoves: 16),
    LevelConfig(id: 2, rows: 2, cols: 3, timeLimitSeconds: 120, maxMoves: 22),
    LevelConfig(id: 3, rows: 3, cols: 4, timeLimitSeconds: 150, maxMoves: 30),
  ];

  Future<List<LevelConfig>> getLevels() async {
    return _readLevels();
  }

  Future<List<LevelConfig>> saveLevels(List<LevelConfig> levels) async {
    await _writeLevels(levels);
    return _readLevels();
  }

  Future<List<LevelConfig>> _readLevels() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return List<LevelConfig>.from(_defaultLevels);
    }

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final levels = decoded
          .map((e) => LevelConfig.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      levels.sort((a, b) => a.id.compareTo(b.id));
      return levels;
    } catch (_) {
      return List<LevelConfig>.from(_defaultLevels);
    }
  }

  Future<void> _writeLevels(List<LevelConfig> levels) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = List<LevelConfig>.from(levels)
      ..sort((a, b) => a.id.compareTo(b.id));
    final encoded =
        jsonEncode(sorted.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(_storageKey, encoded);
  }
}
