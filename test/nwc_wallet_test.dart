import 'package:flutter_test/flutter_test.dart';
import 'package:nwc_wallet/constants/app_configs.dart';
import 'package:nwc_wallet/data/models/nwc_request.dart';
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

      final connection = await nwcWallet.addConnection(
        permittedMethods: [
          NwcMethod.getInfo,
          NwcMethod.getBalance,
          NwcMethod.makeInvoice,
          NwcMethod.lookupInvoice,
        ],
      );

      // Listen for nwc requests
      final sub = nwcWallet.nwcRequests.listen((request) {
        print('Request: $request');
        switch (request.method) {
          case NwcMethod.getInfo:
            nwcWallet.getInfoRequestHandled(
              request as NwcGetInfoRequest,
              alias: 'kumulynja',
              color: '#FFA500',
              pubkey: nostrKeyPair.publicKey,
              network: BitcoinNetwork.signet,
              blockHeight: 1220149,
              blockHash:
                  '00000237e2ad85bbbe9db8d20ce44054f25b05a56318e30d8f4e1791b228157c',
              methods: [
                NwcMethod.getInfo,
                NwcMethod.getBalance,
                NwcMethod.payInvoice,
                NwcMethod.makeInvoice,
                NwcMethod.multiPayInvoice,
                NwcMethod.payKeysend,
                NwcMethod.lookupInvoice,
                NwcMethod.listTransactions,
              ],
            );

          case NwcMethod.getBalance:
            nwcWallet.getBalanceRequestHandled(request as NwcGetBalanceRequest,
                balanceSat: 987123);
          case NwcMethod.makeInvoice:
            const invoice =
                'lntbs750u1pngrch7dq8w3jhxaqpp56sm3029nrfdjg67rr7tcdcpvtnngq5dz90xxf7h5zq6cp0y6vhyssp529ge5rfqtfryp4dn2gr4qg84rejfus653j3cf975fj9wyyhz2a7q9qyysgqcqp6xqrgegrzjqdcadltawh0z6qmj6ql2qr5t4ndvk5xz0582ag98dgrz9ml37hhjkzyuuqqqdugqqvqqqqqqqqqqqqqqfqef3lceuteux4sv0xarvmtw2sck964s4xwn2wx8d4q4k772v8jn3jtfhf9tjhqge5nhesgt6rvxlkkwvn4f8kwmtx0ghjal72nkv8gsqpc4uyvg';
            nwcWallet.makeInvoiceRequestHandled(
              request as NwcMakeInvoiceRequest,
              invoice: invoice,
              paymentHash:
                  'd43717a8b31a5b246bc31f9786e02c5ce68051a22bcc64faf4103580bc9a65c9',
              amountSat: 75000,
              feesPaidSat: 0,
              createdAt: 1719788286,
              expiresAt: 1719797286,
              metadata: {},
            );
          case NwcMethod.listTransactions:
            nwcWallet.listTransactionsRequestHandled(
                request as NwcListTransactionsRequest,
                transactions: []);
          case NwcMethod.lookupInvoice:
            nwcWallet.lookupInvoiceRequestHandled(
              request as NwcLookupInvoiceRequest,
              invoice:
                  'lntbs750u1pngrch7dq8w3jhxaqpp56sm3029nrfdjg67rr7tcdcpvtnngq5dz90xxf7h5zq6cp0y6vhyssp529ge5rfqtfryp4dn2gr4qg84rejfus653j3cf975fj9wyyhz2a7q9qyysgqcqp6xqrgegrzjqdcadltawh0z6qmj6ql2qr5t4ndvk5xz0582ag98dgrz9ml37hhjkzyuuqqqdugqqvqqqqqqqqqqqqqqfqef3lceuteux4sv0xarvmtw2sck964s4xwn2wx8d4q4k772v8jn3jtfhf9tjhqge5nhesgt6rvxlkkwvn4f8kwmtx0ghjal72nkv8gsqpc4uyvg',
              paymentHash:
                  'd43717a8b31a5b246bc31f9786e02c5ce68051a22bcc64faf4103580bc9a65c9',
              preimage:
                  '5ad05d1f46124f1a191d634e9a16a60224ce118949d72f8b366fef37de01c662',
              amountSat: 75000,
              feesPaidSat: 0,
              createdAt: 1719788286,
              expiresAt: 1719797286,
              settledAt: 1719788757,
              metadata: {},
            );
          default:
            print('Unpermitted method: ${request.method}');
        }
      });

      await Future.delayed(const Duration(seconds: 1000));

      sub.cancel();

      expect(
        connection.uri,
        startsWith('nostr+walletconnect://${nostrKeyPair.publicKey}?secret='),
      );
      expect(connection.uri, endsWith('&relay=${AppConfigs.defaultRelayUrl}'));
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

  test('nip06 mnemonic to private key', () {
    const testCases = [
      {
        'mnemonic':
            'leader monkey parrot ring guide accident before fence cannon height naive bean',
        'privateKey':
            '7f7ff03d123792d6ac594bfa67bf6d0c0ab55b6b1fdb6249303fe861f1ccba9a',
        'publicKey':
            '17162c921dc4d2518f9a101db33695df1afb56ab82f5ff3e5da6eec3ca5cd917',
        'nsec':
            'nsec10allq0gjx7fddtzef0ax00mdps9t2kmtrldkyjfs8l5xruwvh2dq0lhhkp',
        'npub':
            'npub1zutzeysacnf9rru6zqwmxd54mud0k44tst6l70ja5mhv8jjumytsd2x7nu'
      },
      {
        'mnemonic':
            'what bleak badge arrange retreat wolf trade produce cricket blur garlic valid proud rude strong choose busy staff weather area salt hollow arm fade',
        'privateKey':
            'c15d739894c81a2fcfd3a2df85a0d2c0dbc47a280d092799f144d73d7ae78add',
        'publicKey':
            'd41b22899549e1f3d335a31002cfd382174006e166d3e658e3a5eecdb6463573',
        'nsec':
            'nsec1c9wh8xy5eqdzln7n5t0ctgxjcrdug73gp5yj0x03gntn67h83twssdfhel',
        'npub':
            'npub16sdj9zv4f8sl85e45vgq9n7nsgt5qphpvmf7vk8r5hhvmdjxx4es8rq74h',
      }
    ];

    for (final testCase in testCases) {
      final keyPair = NostrKeyPair.fromMnemonic(testCase['mnemonic'] as String);

      expect(keyPair.privateKey, testCase['privateKey']);
      expect(keyPair.publicKey, testCase['publicKey']);
      expect(keyPair.nsec, testCase['nsec']);
      expect(keyPair.npub, testCase['npub']);
      // negative test
      expect(keyPair.privateKey, isNot(NostrKeyPair.generate().privateKey));
    }
  });
}
