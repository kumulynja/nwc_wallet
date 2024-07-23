import 'dart:async';

import 'package:example/repositories/mnemonic_repository.dart';
import 'package:nwc_wallet/nwc_wallet.dart';

abstract class NwcWalletForegroundService {
  Stream<NwcRequest> get nwcRequests;
  Future<void> init();
  Future<NwcConnection> addConnection({
    required String name,
    required List<NwcMethod> permittedMethods,
  });
  Future<void> dispose();
}

class NwcWalletForegroundServiceImpl implements NwcWalletForegroundService {
  final MnemonicRepository _mnemonicRepository;
  NwcWallet? _nwcWallet;
  StreamSubscription<NwcRequest>? _nwcRequestsSubscription;
  final StreamController<NwcRequest> _nwcRequestsController =
      StreamController.broadcast();

  NwcWalletForegroundServiceImpl({
    required MnemonicRepository mnemonicRepository,
  }) : _mnemonicRepository = mnemonicRepository;

  @override
  Stream<NwcRequest> get nwcRequests => _nwcRequestsController.stream;

  @override
  Future<void> init() async {
    NostrKeyPair? walletServiceKeypair;
    List<NwcConnection> connections =
        []; // Todo: get stored connections from repository

    final mnemonic = await _mnemonicRepository.getMnemonic('ldk_node');
    if (mnemonic != null && mnemonic.isNotEmpty) {
      walletServiceKeypair = NostrKeyPair.fromMnemonic(mnemonic);

      _nwcWallet = NwcWallet(
        walletNostrKeyPair: walletServiceKeypair,
        connections: connections,
      );

      print(
        'NwcWalletService: Wallet service initialized with pubkey: ${walletServiceKeypair.publicKey}',
      );

      // Start listening to incoming NWC requests
      _subscribeToNwcRequests();
    }
  }

  @override
  Future<NwcConnection> addConnection({
    required String name,
    required List<NwcMethod> permittedMethods,
  }) async {
    if (_nwcWallet == null) {
      throw 'NwcWalletService: Wallet service not initialized';
    }

    final newConnection =
        await _nwcWallet!.addConnection(permittedMethods: permittedMethods);

    return newConnection;
  }

  @override
  Future<void> dispose() async {
    await _nwcRequestsSubscription?.cancel();
    await _nwcRequestsController.close();
  }

  void _subscribeToNwcRequests() {
    _nwcRequestsSubscription = _nwcWallet!.nwcRequests.listen(
      (request) async {
        print('NwcWalletService: Received NWC request: $request');
        _nwcRequestsController.add(request);
      },
      onError: (e) {
        print('NwcWalletService: Error listening to NWC requests: $e');
        _nwcRequestsController.addError(e);
      },
      onDone: () {
        print('NwcWalletService: Done listening to NWC requests');
      },
    );
  }
}
