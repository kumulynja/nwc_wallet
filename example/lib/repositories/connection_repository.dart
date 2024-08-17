import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nwc_wallet_app/entities/nwc_connection_entity.dart';

abstract class ConnectionRepository {
  Future<void> saveConnection(NwcConnectionEntity connection);
  Future<NwcConnectionEntity?> getConnection(String pubkey);
  Future<List<NwcConnectionEntity>> getConnections();
  Future<void> deleteConnection(String pubkey);
}

class SecureStorageConnectionRepository implements ConnectionRepository {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _connectionKey = 'connection';

  // Make this a singleton class.
  SecureStorageConnectionRepository._privateConstructor();

  static final SecureStorageConnectionRepository _instance =
      SecureStorageConnectionRepository._privateConstructor();

  factory SecureStorageConnectionRepository() {
    return _instance;
  }

  @override
  Future<void> saveConnection(NwcConnectionEntity connection) async {
    await _secureStorage.write(
      key: _getConnectionKey(connection.pubkey),
      value: jsonEncode(connection.toJson()),
    );
  }

  @override
  Future<NwcConnectionEntity?> getConnection(String pubkey) async {
    final connection =
        await _secureStorage.read(key: _getConnectionKey(pubkey));
    if (connection == null) {
      return null;
    }
    return NwcConnectionEntity.fromJson(jsonDecode(connection));
  }

  @override
  Future<List<NwcConnectionEntity>> getConnections() async {
    final allKeyValues = await _secureStorage.readAll();
    return allKeyValues.entries
        .where((element) => element.key.startsWith(_connectionKey))
        .map((e) => NwcConnectionEntity.fromJson(jsonDecode(e.value)))
        .toList();
  }

  @override
  Future<void> deleteConnection(String pubkey) async {
    return _secureStorage.delete(key: _getConnectionKey(pubkey));
  }

  String _getConnectionKey(String pubkey) => '$_connectionKey$pubkey';
}
