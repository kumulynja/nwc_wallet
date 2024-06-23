library nwc_wallet;

export 'enums/nwc_method_enum.dart' show NwcMethod;
export 'data/models/nostr_key_pair.dart' show NostrKeyPair;

import 'package:nwc_wallet/constants/app_configs.dart';
import 'package:nwc_wallet/data/models/nostr_key_pair.dart';
import 'package:nwc_wallet/data/models/nwc_connection.dart';
import 'package:nwc_wallet/data/models/nwc_request.dart';
import 'package:nwc_wallet/data/providers/nostr_relay_provider.dart';
import 'package:nwc_wallet/data/repositories/nostr_repository.dart';
import 'package:nwc_wallet/enums/nwc_method_enum.dart';
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
    int? monthlyLimitSat,
    int? expiry,
  }) {
    // Todo: Only if first active connection, connect the _nwcService
    _nwcService.connect();

    return _nwcService.addConnection(
      name: name,
      relayUrl: _relayUrl,
      permittedMethods: permittedMethods,
      monthlyLimitSat: monthlyLimitSat,
      expiry: expiry,
    );
  }

  void removeConnection(int connectionId) {
    // Todo: if last (active) connection, disconnect the _nwcService
    _nwcService.disconnect();
  }
}
