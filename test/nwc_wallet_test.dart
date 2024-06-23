import 'package:flutter_test/flutter_test.dart';
import 'package:nwc_wallet/constants/app_configs.dart';
import 'package:nwc_wallet/enums/nostr_event_kind_enum.dart';
import 'package:nwc_wallet/nips/nip01.dart';

import 'package:nwc_wallet/nwc_wallet.dart';

void main() {
  test(
    'calculate event id',
    () {
      final id = Nip01.calculateEventId(
        pubkey:
            '981cc2078af05b62ee1f98cff325aac755bf5c5836a265c254447b5933c6223b',
        createdAt: 1672175320,
        kind: NostrEventKind.textNote,
        tags: [],
        content: "Ceci est une analyse du websocket",
      );
      expect(
        id,
        '4b697394206581b03ca5222b37449a9cdca1741b122d78defc177444e2536f49',
      );
    },
  );
  test(
    'event sig',
    () {
      final keyPair = NostrKeyPair(
        privateKey:
            '5ee1c8000ab28edd64d74a7d951ac2dd559814887b1b9e1ac7c5f89e96125c12',
      );
      final signature = keyPair.sign(
        '4b697394206581b03ca5222b37449a9cdca1741b122d78defc177444e2536f49',
      );
      expect(
        keyPair.verify(
          keyPair.publicKey,
          '4b697394206581b03ca5222b37449a9cdca1741b122d78defc177444e2536f49',
          signature,
        ),
        true,
      );
    },
  );
  test(
    'adds a connection',
    () async {
      final nostrKeyPair = NostrKeyPair.generate();
      final nwcWallet = NwcWallet(
        walletNostrKeyPair: nostrKeyPair,
      );

      final connectionUri = await nwcWallet.addConnection(
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

      expect(
        connectionUri,
        startsWith('nostr+walletconnect://${nostrKeyPair.publicKey}?secret='),
      );
      expect(connectionUri, endsWith('&relay=${AppConfigs.defaultRelayUrl}'));
    },
  );
}
