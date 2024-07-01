<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

This package takes care of the [wallet service](https://docs.nwc.dev/bitcoin-lightning-wallets/getting-started) side of the [Nostr Wallet Connect (NWC)](https://docs.nwc.dev/) protocol as described by [NIP-47](https://github.com/nostr-protocol/nips/blob/master/47.md). It is a Flutter package that can be integrated in any Lightning wallet app to let users connect their wallet to websites, platforms, apps or any NWC-enabled services.

## Features

The package provides the following features without the need to understand anything about Nostr or the NWC protocol:

- Generate or import a Nostr keypair for the wallet service.
- Create and remove NWC URI's to connect to websites, platforms, apps or any NWC-enabled services.
- Listen to a stream of NWC requests for your wallet on a specific relay.
- Respond to NWC requests after handling them in your wallet.

## Limitations

The package is still in development and should be used with caution. Following are some of the current limitations:

- Only real-time events are supported, the package does not return missed events yet.
- The package is not fully tested or documented.
- No connection monitoring and reconnect mechanism is implemented yet.
- No retry mechanisms are currently implemented on failures.
- No custom exceptions available yet for better error handling.

All of these limitations will of course be addressed in future releases.
Feel free to open any issues if you encounter any other limitations that are not listed here.

## Getting started

To use this package, your app should have a Lightning Network node, wallet or access to a Lightning wallet service so you can handle the NWC requests. You can look at [ldk-node-flutter](https://github.com/LtbLightning/ldk-node-flutter) for a Flutter package that can be used to run a Lightning node on mobile.

Also install any secure storage mechanism package you want to use to persist the wallet service's Nostr private key and created NWC connections.
To keep this package independent of any specific secure storage mechanism or dependency, the package does not persist keypairs or connections between app restarts, that's up to the user of the package to implement.

Together with the NWC connection data, it is recommended to also save limits and an expiry date for the connection. You should than check these limits and expiry date before handling the NWC requests.

## Usage

```dart
// Generate a new Nostr keypair for the wallet service (do not use the keypair of a user's Nostr profile)
final nostrKeyPair = NostrKeyPair.generate();

// Todo: Save the keypair in your app's secure storage

// Initialize the NwcWallet with the generated keypair,
//  you can optionally pass a relay URL and
//  a list of active NWC connections saved by your app.
final nwcWallet = NwcWallet(
    walletNostrKeyPair: nostrKeyPair,
);

// Add a new NWC connection
final connection = await nwcWallet.addConnection(
    name: 'Test Connection',
    permittedMethods: [
        NwcMethod.getInfo,
        NwcMethod.getBalance,
        NwcMethod.makeInvoice,
        NwcMethod.lookupInvoice,
    ],
);

println('Connection added: ${connection.uri}');
// Todo: Securely store the connection info in your app

// Listen for nwc requests, handle them based on the method type and call the appropriate method after having handled the request with the user's wallet
nwcWallet.nwcRequests.listen((request) {
    switch (request.method) {
        case NwcMethod.getInfo:
            // Todo: Get the info from the wallet/node or define the wallet's info to share with the website
            final alias = '';
            final color = '';
            final network = BitcoinNetwork.mainnet;
            final blockHeight = 0;
            final blockHash = '';

            // Respond to the getInfo request with the wallet's info and the methods your wallet supports
            nwcWallet.getInfoRequestHandled(
                request,
                alias: alias,
                color: color,
                pubkey: nostrKeyPair.publicKey,
                network: <network>,
                blockHeight: <blockHeight>,
                blockHash: <blockHash>,
                methods: [
                    NwcMethod.getInfo,
                    NwcMethod.getBalance,
                    NwcMethod.payInvoice,
                    NwcMethod.makeInvoice,
                    NwcMethod.multiPayInvoice,
                    NwcMethod.payKeysend,
                    NwcMethod.multiPayKeysend,
                    NwcMethod.lookupInvoice,
                    NwcMethod.listTransactions,
                ],
            );

        case NwcMethod.getBalance:
            final balance = 987123; // Todo: get the real balance from the wallet/node

            // Respond to the getBalance request with the wallet's balance
            nwcWallet.getBalanceRequestHandled(request, balanceSat: balance);
        case NwcMethod.makeInvoice:
            // Todo: Fetch a real invoice from the wallet/node in your app
            const invoice =
                'lntbs750u1pngrch7dq8w3jhxaqpp56sm3029nrfdjg67rr7tcdcpvtnngq5dz90xxf7h5zq6cp0y6vhyssp529ge5rfqtfryp4dn2gr4qg84rejfus653j3cf975fj9wyyhz2a7q9qyysgqcqp6xqrgegrzjqdcadltawh0z6qmj6ql2qr5t4ndvk5xz0582ag98dgrz9ml37hhjkzyuuqqqdugqqvqqqqqqqqqqqqqqfqef3lceuteux4sv0xarvmtw2sck964s4xwn2wx8d4q4k772v8jn3jtfhf9tjhqge5nhesgt6rvxlkkwvn4f8kwmtx0ghjal72nkv8gsqpc4uyvg';

            // Respond to the makeInvoice request with the invoice details
            nwcWallet.makeInvoiceRequestHandled(
                request,
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
            // Todo: Fetch the transactions from the wallet/node in your app
            final transactions = <NwcTransaction>[];

            // Respond to the listTransactions request with the transactions
            nwcWallet.listTransactionsRequestHandled(request, transactions: transactions);
        case NwcMethod.payInvoice:
            // Todo: Check the budget limits and expiry date of the connection before making the payment!!!

            // Todo: Pay the invoice with the wallet/node in your app and get the preimage
            final preimage = <preimage>;

            // Respond to the payInvoice request with the preimage
            nwcWallet.payInvoiceRequestHandled(request, preimage: preimage);
        // Todo: Handle other methods your wallet supports
        default:
            print('Unpermitted method: ${request.method}');
    }
});
```

If a request can not be handled, you should use the `failedToHandleRequest` method to inform the website or app, instead of the specific request handled method:

```dart
try {
    // Try paying the invoice with the wallet/node in your app
    final preimage = <preimage>;

    // If no exception is thrown, respond to the payInvoice request with the preimage
    nwcWallet.payInvoiceRequestHandled(request, preimage: preimage);
} catch(e) {
    // If an exception is thrown, inform the website or app that the request could not be handled
    // instead of the specific request handled method and provide the nwc error code that fits best.
    nwcWallet.failedToHandleRequest(request, error: NwcError.paymentFailed);
}
```

## Additional information

Contributions are welcome. Feel free to open any issues or pull requests.

## Credits

Other Nostr Flutter packages have been helpful in the development of this package and some code snippets were borrowed from them. Special thanks to the developers of these packages:

- https://github.com/anasfik/nostr for the bech32 encoding and decoding code.
- https://github.com/ethicnology/dart-nostr for the nip04 encryption and decryption code.

Also the [Nostr Wallet Connect workshop](https://www.youtube.com/watch?v=V-7u7bJccSM) of [Plebdevs](https://www.plebdevs.com/) as instructed by [gudnuf](https://x.com/da_goodenough) was very helpful in understanding the NWC protocol.

Also a special shootout to the amazing people at [Flash](https://paywithflash.com/), who are building the first Bitcoin payment gateway on top of Nostr Wallet Connect. They showed me the great potential of the NWC protocol and their work has been a motivation for me to build this package.

## NWC Apps

The Nostr Wallet Connect protocol consists of different parts. Mainly, the wallet service side and the website or app side. They communicate with each other over Nostr relays. This package is aimed to build the wallet service side of the protocol. If your app is not a wallet, but you would like to enable Lightning wallets to connect to your app through Nostr Wallet Connect, you can use the following Flutter package:

- https://github.com/bringinxyz/nwc
