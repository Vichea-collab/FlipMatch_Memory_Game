import 'package:flutter_test/flutter_test.dart';
import 'package:memory_pair_game/data/player_repository.dart';
import 'package:memory_pair_game/domain/models/player.dart';
import 'package:memory_pair_game/domain/services/player_service.dart';

void main() {
  group('PlayerService', () {
    late _FakePlayerRepository data;
    late PlayerService service;

    setUp(() {
      data = _FakePlayerRepository();
      service = PlayerService(data);
    });

    test('upsert delegates to data and returns stored player', () async {
      final player = await service.upsert('Sam');

      expect(data.upsertCalls, 1);
      expect(player.name, 'Sam');
      expect(player.totalScore, 0);
      expect(player.highestLevel, 0);
    });

    test('update writes new values when player exists', () async {
      data = _FakePlayerRepository([
        const Player(name: 'Casey', totalScore: 50, highestLevel: 1),
      ]);
      service = PlayerService(data);

      const updated = Player(name: 'Casey', totalScore: 300, highestLevel: 4);
      await service.update(updated);

      expect(data.updateCalls, 1);
      final players = await data.getAllPlayers();
      expect(players.single.totalScore, 300);
      expect(players.single.highestLevel, 4);
    });

    test('delete forwards to data', () async {
      data = _FakePlayerRepository([
        const Player(name: 'Rex', totalScore: 10, highestLevel: 1),
      ]);
      service = PlayerService(data);

      await service.delete('Rex');

      expect(data.deleteCalls, 1);
      final players = await data.getAllPlayers();
      expect(players, isEmpty);
    });

    test('getAll returns data content', () async {
      data = _FakePlayerRepository([
        const Player(name: 'A', totalScore: 5, highestLevel: 1),
        const Player(name: 'B', totalScore: 10, highestLevel: 2),
      ]);
      service = PlayerService(data);

      final players = await service.getAll();

      expect(data.getAllCalls, 1);
      expect(players.map((p) => p.name), containsAll(['A', 'B']));
    });
  });
}

class _FakePlayerRepository extends PlayerRepository {
  final List<Player> _store;
  int upsertCalls = 0;
  int updateCalls = 0;
  int deleteCalls = 0;
  int getAllCalls = 0;

  _FakePlayerRepository([List<Player>? initial])
      : _store = List<Player>.from(initial ?? const []);

  @override
  Future<Player> upsertPlayer(String name) async {
    upsertCalls++;
    for (final player in _store) {
      if (player.name.toLowerCase() == name.toLowerCase()) {
        return player;
      }
    }
    final created = Player(name: name, totalScore: 0, highestLevel: 0);
    _store.add(created);
    return created;
  }

  @override
  Future<void> updatePlayer(Player player) async {
    updateCalls++;
    final index = _store.indexWhere(
      (p) => p.name.toLowerCase() == player.name.toLowerCase(),
    );
    if (index == -1) {
      _store.add(player);
    } else {
      _store[index] = player;
    }
  }

  @override
  Future<void> deletePlayer(String name) async {
    deleteCalls++;
    _store.removeWhere(
      (p) => p.name.toLowerCase() == name.toLowerCase(),
    );
  }

  @override
  Future<List<Player>> getAllPlayers() async {
    getAllCalls++;
    return List<Player>.from(_store);
  }
}
