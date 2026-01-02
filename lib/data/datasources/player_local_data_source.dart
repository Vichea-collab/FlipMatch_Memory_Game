import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/player_model.dart';

abstract class PlayerLocalDataSource {
  Future<List<PlayerModel>> getAllPlayers();
  Future<void> saveAllPlayers(List<PlayerModel> players);
  Future<void> deletePlayer(String name);
}

class PlayerLocalDataSourceImpl implements PlayerLocalDataSource {
  static const String _fileName = 'leaderboard.json';
  static const String _assetPath = 'assets/data/leaderboard.json';
  static const String _prefsKey = 'players_data';

  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> _ensureStorageExists() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_prefsKey)) return;
      final defaultData = await rootBundle.loadString(_assetPath);
      await prefs.setString(_prefsKey, defaultData);
      return;
    }

    final file = await _getFile();
    if (await file.exists()) return;

    final defaultData = await rootBundle.loadString(_assetPath);
    await file.create(recursive: true);
    await file.writeAsString(defaultData);
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

  Future<List<PlayerModel>> _readPlayers() async {
    final raw = (await _readRaw()).trim();
    if (raw.isEmpty) return [];
    final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => PlayerModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _writePlayers(List<PlayerModel> players) async {
    final encoded =
        jsonEncode(players.map((p) => p.toJson()).toList(growable: false));
    await _writeRaw(encoded);
  }

  @override
  Future<List<PlayerModel>> getAllPlayers() {
    return _readPlayers();
  }

  @override
  Future<void> saveAllPlayers(List<PlayerModel> players) {
    return _writePlayers(players);
  }

  @override
  Future<void> deletePlayer(String name) async {
    final players = await _readPlayers();
    players.removeWhere(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
    );
    await _writePlayers(players);
  }
}
