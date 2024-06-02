import 'package:nwc_wallet/constants/database_params.dart';
import 'package:nwc_wallet/data/models/nwc_connection_model.dart';
import 'database_provider.dart';

abstract class NwcConnectionProvider {
  Future<int> addConnection(NwcConnectionModel connection);
  Future<int> updateConnection(NwcConnectionModel connection);
  Future<NwcConnectionModel?> getConnection(int id);
  Future<List<NwcConnectionModel>> queryConnections({
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  });
  Future<int> deleteConnection(int id);
}

class NwcConnectionProviderImpl implements NwcConnectionProvider {
  final DatabaseProvider databaseProvider;

  NwcConnectionProviderImpl(this.databaseProvider);

  @override
  Future<int> addConnection(NwcConnectionModel connection) async {
    final db = await databaseProvider.database;
    return await db.insert(
        DatabaseParams.nwcConnectionsTable, connection.toMap());
  }

  @override
  Future<int> updateConnection(NwcConnectionModel connection) async {
    final db = await databaseProvider.database;
    return await db.update(
      DatabaseParams.nwcConnectionsTable,
      connection.toMap(),
      where: '${DatabaseParams.columnId} = ?',
      whereArgs: [connection.id],
    );
  }

  @override
  Future<NwcConnectionModel?> getConnection(int id) async {
    final db = await databaseProvider.database;
    final maps = await db.query(
      DatabaseParams.nwcConnectionsTable,
      where: '${DatabaseParams.columnId} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return NwcConnectionModel.fromMap(maps.first);
    } else {
      return null; // Return null if no match found
    }
  }

  @override
  Future<List<NwcConnectionModel>> queryConnections({
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await databaseProvider.database;
    final connections = await db.query(
      DatabaseParams.nwcConnectionsTable,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
    return connections.map((e) => NwcConnectionModel.fromMap(e)).toList();
  }

  @override
  Future<int> deleteConnection(int id) async {
    final db = await databaseProvider.database;
    return await db.delete(
      DatabaseParams.nwcConnectionsTable,
      where: '${DatabaseParams.columnId} = ?',
      whereArgs: [id],
    );
  }
}
