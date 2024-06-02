import 'package:nwc_wallet/constants/database_params.dart';
import 'package:nwc_wallet/data/models/nwc_connection_model.dart';
import 'package:nwc_wallet/data/providers/nwc_connection_provider.dart';
import 'package:nwc_wallet/enums/nwc_method_enum.dart';

abstract class NwcConnectionRepository {
  Future<int> addConnection(
    String name,
    String relayUrl,
    List<NwcMethod> permittedMethods,
    String secret,
    int monthlyLimitSat,
    int expiry,
  );
  Future<void> updateConnection(
    int id, {
    String? name,
    List<NwcMethod>? permittedMethods,
    int? monthlyLimitSat,
    int? expiry,
    bool? isDeactivated,
  });
  Future<int> deleteConnection(int id);
  Future<NwcConnectionModel?> getConnection(int id);
  Future<List<NwcConnectionModel>> getConnections({
    int? limit,
    int? offset,
  });
  Future<List<NwcConnectionModel>> getActiveConnections({
    int? limit,
    int? offset,
  });
  Future<List<NwcConnectionModel>> getDeactivatedConnections({
    int? limit,
    int? offset,
  });
}

class NwcConnectionRepositoryImpl implements NwcConnectionRepository {
  final NwcConnectionProvider connectionProvider;

  NwcConnectionRepositoryImpl(this.connectionProvider);

  @override
  Future<int> addConnection(
    String name,
    String relayUrl,
    List<NwcMethod> permittedMethods,
    String secret,
    int monthlyLimitSat,
    int expiry,
  ) async {
    final creationTime = DateTime.now().millisecondsSinceEpoch;

    final connection = NwcConnectionModel(
      name: name,
      relayUrl: relayUrl,
      permittedMethods: permittedMethods,
      secret: secret,
      monthlyLimitSat: monthlyLimitSat,
      expiry: expiry,
      createdAt: creationTime,
      updatedAt: creationTime,
    );

    return await connectionProvider.addConnection(connection);
  }

  @override
  Future<int> updateConnection(
    int id, {
    String? name,
    List<NwcMethod>? permittedMethods,
    String? secret,
    int? monthlyLimitSat,
    int? expiry,
    bool? isDeactivated,
  }) async {
    final updateTime = DateTime.now().millisecondsSinceEpoch;
    final deactivationTime = isDeactivated == true ? updateTime : null;

    final connection = await connectionProvider.getConnection(id);

    if (connection == null) {
      throw Exception('Connection not found');
    }

    final updatedConnection = connection.copyWith(
      name: name,
      permittedMethods: permittedMethods,
      secret: secret,
      monthlyLimitSat: monthlyLimitSat,
      expiry: expiry,
      isDeactivated: isDeactivated,
      updatedAt: updateTime,
      deactivatedAt: deactivationTime,
    );

    return await connectionProvider.updateConnection(updatedConnection);
  }

  @override
  Future<int> deleteConnection(int id) async {
    return await connectionProvider.deleteConnection(id);
  }

  @override
  Future<NwcConnectionModel?> getConnection(int id) async {
    return await connectionProvider.getConnection(id);
  }

  @override
  Future<List<NwcConnectionModel>> getConnections({
    int? limit,
    int? offset,
  }) async {
    return await connectionProvider.queryConnections(
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<NwcConnectionModel>> getActiveConnections({
    int? limit,
    int? offset,
  }) async {
    return await connectionProvider.queryConnections(
      where: '${DatabaseParams.columnIsDeactivated} = ?',
      whereArgs: [0],
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<List<NwcConnectionModel>> getDeactivatedConnections({
    int? limit,
    int? offset,
  }) async {
    return await connectionProvider.queryConnections(
      where: '${DatabaseParams.columnIsDeactivated} = ?',
      whereArgs: [1],
      limit: limit,
      offset: offset,
    );
  }
}
