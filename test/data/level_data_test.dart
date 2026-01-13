import 'package:flutter_test/flutter_test.dart';
import 'package:memory_pair_game/data/level_repository.dart';
import 'package:memory_pair_game/domain/models/level_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LevelData', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('returns defaults when storage is empty', () async {
      final data = LevelData();

      final levels = await data.getLevels();

      expect(levels, hasLength(3));
      expect(levels.first.id, 1);
    });

    test('saveLevels persists and sorts by id', () async {
      final data = LevelData();
      const custom = [
        LevelConfig(id: 2, rows: 2, cols: 3, timeLimitSeconds: 60, maxMoves: 10),
        LevelConfig(id: 1, rows: 2, cols: 2, timeLimitSeconds: 60, maxMoves: 8),
      ];

      await data.saveLevels(custom);

      final reloaded = LevelData();
      final levels = await reloaded.getLevels();

      expect(levels, hasLength(2));
      expect(levels.first.id, 1);
      expect(levels.last.id, 2);
    });
  });
}
