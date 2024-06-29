library nwc_wallet;

export 'enums/nwc_method.dart' show NwcMethod;
export 'data/models/nostr_key_pair.dart' show NostrKeyPair;

import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/constants/app_configs.dart';
import 'package:nwc_wallet/data/models/nostr_key_pair.dart';
import 'package:nwc_wallet/data/models/nwc_connection.dart';
import 'package:nwc_wallet/data/models/nwc_request.dart';
import 'package:nwc_wallet/data/providers/nostr_relay_provider.dart';
import 'package:nwc_wallet/data/repositories/nostr_repository.dart';
import 'package:nwc_wallet/enums/nwc_method.dart';
import 'package:nwc_wallet/services/nwc_service.dart';

class NwcWallet {
  // Private fields
  final String _relayUrl;
  final NostrKeyPair _walletNostrKeyPair;
  late NwcService _nwcService;

  // Public fields
  Stream<NwcRequest> get nwcRequests => _nwcService.nwcRequests;

  // Private constructor
  NwcWallet._(
    this._walletNostrKeyPair,
    this._relayUrl,
    List<NwcConnection> connections,
  ) {
    _nwcService = NwcServiceImpl(
      _walletNostrKeyPair,
      NostrRepositoryImpl(
        NostrRelayProviderImpl(
          _relayUrl,
        ),
      ),
      connections,
    );
  }

  // Singleton instance
  static NwcWallet? _instance;

  // Factory constructor
  factory NwcWallet({
    required NostrKeyPair walletNostrKeyPair,
    String relayUrl = AppConfigs.defaultRelayUrl,
    List<NwcConnection> connections = const [],
  }) {
    _instance ??= NwcWallet._(walletNostrKeyPair, relayUrl, connections);
    return _instance!;
  }

  Future<String> addConnection({
    required String name,
    required List<NwcMethod> permittedMethods,
  }) async {
    // If first active connection, connect the _nwcService
    if (_nwcService.connections.isEmpty) {
      _nwcService.connect();
    }

    final connectionUri = await _nwcService.addConnection(
      name: name,
      relayUrl: _relayUrl,
      permittedMethods: permittedMethods,
    );

    debugPrint('Connection URI: $connectionUri');

    return connectionUri;
  }

  void removeConnection(int connectionId) {
    // Todo: remove the connection from the _nwcService connections list

    // Disconnect the _nwcService if no active connections left
    if (_nwcService.connections.isEmpty) {
      _nwcService.disconnect();
    }
  }
}
