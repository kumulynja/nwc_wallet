import 'dart:async';

import 'package:example/entities/nwc_connection_entity.dart';
import 'package:example/services/nwc_wallet_service/nwc_wallet_service.dart';
import 'package:nwc_wallet/nwc_wallet.dart';

class NwcWalletServiceProxy implements NwcWalletService {
  NwcWalletServiceProxy();

  @override
  Future<void> init() async {
    print('init from proxy');
  }

  @override
  Future<NwcConnection> addConnection({
    required String name,
    required List<NwcMethod> permittedMethods,
  }) async {
    // Todo: save connection to repository

    return NwcConnection(pubkey: 'pubkey', permittedMethods: permittedMethods);
  }

  @override
  Future<List<NwcConnectionEntity>> getSavedConnections() {
    return Future.value([]); // Todo: get stored connections from repository
  }

  @override
  Future<void> dispose() async {}
}
