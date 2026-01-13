import '../../data/player_repository.dart';
import '../models/player.dart';

class PlayerService {
  final PlayerData data;

  PlayerService(this.data);

  Future<Player> upsert(String name) => data.upsertPlayer(name);

  Future<void> update(Player player) => data.updatePlayer(player);

  Future<void> delete(String name) => data.deletePlayer(name);

  Future<List<Player>> getAll() => data.getAllPlayers();
}
