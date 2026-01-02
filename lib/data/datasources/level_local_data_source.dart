import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/level_config.dart';

abstract class LevelLocalDataSource {
  Future<List<LevelConfig>> fetchLevels();
  Future<void> saveLevels(List<LevelConfig> levels);
}

class LevelLocalDataSourceImpl implements LevelLocalDataSource {
  static const String _fileName = 'level.json';
  static const String _assetPath = 'assets/data/level.json';
  static const String _prefsKey = 'levels_data';
  List<LevelConfig>? _cache;

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> _ensureStorageExists() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_prefsKey)) return;
      final raw = await rootBundle.loadString(_assetPath);
      await prefs.setString(_prefsKey, raw);
      return;
    }

    final file = await _getFile();
    if (await file.exists()) return;

    final raw = await rootBundle.loadString(_assetPath);
    await file.create(recursive: true);
    await file.writeAsString(raw);
  }

  Future<String> _readRaw() async {
    await _ensureStorageExists();
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_prefsKey) ?? '[]';
    }
    final file = await _getFile();
    if (!await file.exists()) return '[]';
    return file.readAsString();
  }

  Future<void> _writeRaw(String data) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, data);
      return;
    }

    final file = await _getFile();
    await file.writeAsString(data);
  }

  @override
  Future<List<LevelConfig>> fetchLevels() async {
    if (_cache != null) return _cache!;

    final raw = (await _readRaw()).trim();
    if (raw.isEmpty) {
      _cache = [];
      return _cache!;
    }

    final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
    _cache = decoded
        .map((e) => LevelConfig.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    return _cache!;
  }

  @override
  Future<void> saveLevels(List<LevelConfig> levels) async {
    _cache = List<LevelConfig>.from(levels)
      ..sort((a, b) => a.id.compareTo(b.id));
    final encoded =
        jsonEncode(_cache!.map((e) => e.toJson()).toList(growable: false));
    await _writeRaw(encoded);
  }
}
