import 'package:flutter_test/flutter_test.dart';
import 'package:nwc_wallet/constants/app_configs.dart';
import 'package:nwc_wallet/enums/nostr_event_kind.dart';
import 'package:nwc_wallet/nips/nip01.dart';
import 'package:nwc_wallet/nips/nip04.dart';

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
      );

      //await Future.delayed(const Duration(seconds: 1000));

      expect(
        connectionUri,
        startsWith('nostr+walletconnect://${nostrKeyPair.publicKey}?secret='),
      );
      expect(connectionUri, endsWith('&relay=${AppConfigs.defaultRelayUrl}'));
    },
  );

  test('nip04 decrypt', () {
    NostrKeyPair keyPair = NostrKeyPair(
      privateKey:
          '9bdc0737ecc9b7871b21537cc707c972389c829028f9fa8e6c95b331768ee4ac',
    );
    const encryptedContent =
        'zdiUBdrfA+HNM4qF67oKN2HcUv4kxnlRkpjHP5mqd9UrFuoSbwGAXQeTBUUrYO1svYBvhnpBK4s5XNVvXmvQ4yuji+v7KOwrDYjQzFveXLXXlyoFPakp5CD2BUdGkNn3pVzodWD84dgmfuuUDNYNfmm8EyjVyGBE1TmiBHawOI0MkhZ+uHf4VGhO6EIvhunLYQITe4YQvTRHiNlO4hoHh9kOjQLxYEY9AEkZ2EEPcfYpSkuYqUnvwUii7qzPJWU8o7PI86k4R3IryEf7hnN1DvZgZxRiWrwJwXP7P9PTiaorzjsEZWrKsus+65vU2e1F6L0jOPX0f5+/lZkSwF7Qgq4YZc/OlyJSqMDrz0SoMw0NbugGYOU/DxO4pP75o0NPIeG6lyr4jA4VsXMyA2NiNfFQRlGbRuk/qF8nmG4we70=?iv=yIIcMRiYu41Qlztn0asP3g==';
    const connectionPublicKey =
        '7a29579ddcb698db1b93f7078c5020dc932de36cba53fedd6a0746005db7fd7f';

    expect(
      Nip04.decrypt(
        encryptedContent,
        keyPair.privateKey,
        connectionPublicKey,
      ),
      '{"method":"pay_invoice","params":{"invoice":"lntbs210n1pn83jurpp5lgvkz8w6y6vws7urs97ewkz5j9dmlfcsqksrw0egjt34ml6yezgsdqqcqzzsxqyz5vqsp5yke8eagt7uynk30adlq707rtq496lvrn3nxxs80levkfyfczd7uq9qyyssqmhx239fvsulum8nekent00v6x7nfgv9peuy6q4r0pakmc63cqkm8vjjrx4nk2e0z0nekzzqkhxsdt5jv2vfnwu0sn9cl09hgfedzmyspzje739"}}',
    );
  });
}
