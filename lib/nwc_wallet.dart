library nwc_wallet;

export 'enums/nwc_method_enum.dart' show NwcMethod;

import 'package:nwc_wallet/data/models/nostr_key_pair.dart';
import 'package:nwc_wallet/data/models/nwc_request.dart';
import 'package:nwc_wallet/data/providers/database_provider.dart';
import 'package:nwc_wallet/data/providers/nostr_relay_provider.dart';
import 'package:nwc_wallet/data/providers/nwc_connection_provider.dart';
import 'package:nwc_wallet/data/repositories/nostr_repository.dart';
import 'package:nwc_wallet/data/repositories/nwc_connection_repository.dart';
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
  NwcWallet._(this._relayUrl, this._walletNostrKeyPair) {
    _nwcService = NwcServiceImpl(
      _walletNostrKeyPair,
      NostrRepositoryImpl(
        NostrRelayProviderImpl(
          _relayUrl,
        ),
      ),
      NwcConnectionRepositoryImpl(
        NwcConnectionProviderImpl(
          DatabaseProviderImpl.instance,
        ),
      ),
    );
  }

  // Singleton instance
  static NwcWallet? _instance;

  // Factory constructor
  factory NwcWallet({
    required String relayUrl,
    required NostrKeyPair walletNostrKeyPair,
  }) {
    _instance ??= NwcWallet._(relayUrl, walletNostrKeyPair);
    return _instance!;
  }

  Future<String> addConnection(
    String name,
    String relayUrl,
    List<NwcMethod> permittedMethods,
    int monthlyLimit,
    int expiry,
  ) {
    // Todo: Only if first active connection, connect the _nwcService
    _nwcService.connect();

    return _nwcService.addConnection(
      name,
      relayUrl,
      permittedMethods,
      monthlyLimit,
      expiry,
    );
  }

  void removeConnection(int connectionId) {
    // Todo: if last (active) connection, disconnect the _nwcService
    _nwcService.disconnect();
  }
}
