import 'package:flutter_test/flutter_test.dart';
import 'package:memory_pair_game/data/player_repository.dart';
import 'package:memory_pair_game/domain/models/player.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('PlayerRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('upsert creates and persists a player', () async {
      final data = PlayerRepository();

      final player = await data.upsertPlayer('Sam');
      expect(player.name, 'Sam');
      expect(player.totalScore, 0);
      expect(player.highestLevel, 0);

      final reloaded = PlayerRepository();
      final players = await reloaded.getAllPlayers();

      expect(players, hasLength(1));
      expect(players.single.name, 'Sam');
    });

    test('update replaces existing player values', () async {
      final data = PlayerRepository();

      await data.upsertPlayer('Ava');
      await data.updatePlayer(
        const Player(name: 'Ava', totalScore: 120, highestLevel: 3),
      );

      final players = await data.getAllPlayers();
      expect(players.single.totalScore, 120);
      expect(players.single.highestLevel, 3);
    });

    test('delete removes player by name', () async {
      final data = PlayerRepository();
      await data.upsertPlayer('Rex');

      await data.deletePlayer('rex');

      final players = await data.getAllPlayers();
      expect(players, isEmpty);
    });
  });
}
