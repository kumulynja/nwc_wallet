import 'package:flutter_test/flutter_test.dart';

import 'package:nwc_wallet/nwc_wallet.dart';

void main() {
  test('adds a connection', () {
    final nostrKeyPair = NostrKeyPair.generate();
    final nwcWallet = NwcWallet(
      relayUrl: 'https://relay.example.com',
      walletNostrKeyPair: nostrKeyPair,
    );

    final connectionUri = nwcWallet.addConnection(
      name: 'Test Connection',
      permittedMethods: [
        NwcMethod.getBalance,
        NwcMethod.getInfo,
        NwcMethod.listTransactions,
        NwcMethod.lookupInvoice,
        NwcMethod.makeInvoice,
        NwcMethod.multiPayInvoice,
        NwcMethod.multiPayKeysend,
        NwcMethod.payInvoice,
        NwcMethod.payKeysend,
      ],
      monthlyLimitSat: 1000,
      expiry: 1000000000,
    );
    expect(connectionUri, isNotEmpty);
  });
}
