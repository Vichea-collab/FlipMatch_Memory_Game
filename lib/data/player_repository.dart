import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/player.dart';

class PlayerRepository {
  static const String _storageKey = 'players';

  Future<List<Player>> getAllPlayers() async {
    final players = await _readPlayers();
    players.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return players;
  }

  Future<Player> upsertPlayer(String name) async {
    final players = await _readPlayers();
    final index =
        players.indexWhere((p) => p.name.toLowerCase() == name.toLowerCase());

    if (index != -1) {
      return players[index];
    }

    final newPlayer = Player(
      name: name,
      totalScore: 0,
      highestLevel: 0,
    );
    players.add(newPlayer);
    await _writePlayers(players);
    return newPlayer;
  }

  Future<void> updatePlayer(Player player) async {
    final players = await _readPlayers();
    final index = players
        .indexWhere((p) => p.name.toLowerCase() == player.name.toLowerCase());

    if (index != -1) {
      players[index] = player;
    } else {
      players.add(player);
    }

    await _writePlayers(players);
  }

  Future<void> deletePlayer(String name) async {
    final players = await _readPlayers();
    players.removeWhere((p) => p.name.toLowerCase() == name.toLowerCase());
    await _writePlayers(players);
  }

  Future<List<Player>> _readPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.trim().isEmpty) {
      return [];
    }

    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => _fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writePlayers(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = List<Player>.from(players)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    final encoded = jsonEncode(sorted.map(_toJson).toList(growable: false));
    await prefs.setString(_storageKey, encoded);
  }

  Player _fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'] as String,
      totalScore: json['totalScore'] as int,
      highestLevel: json['highestLevel'] as int,
    );
  }

  Map<String, dynamic> _toJson(Player player) {
    return {
      'name': player.name,
      'totalScore': player.totalScore,
      'highestLevel': player.highestLevel,
    };
  }
}
