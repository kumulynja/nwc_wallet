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

# nwc_wallet Flutter package

This package takes care of the [wallet service](https://docs.nwc.dev/bitcoin-lightning-wallets/getting-started) side of the [Nostr Wallet Connect (NWC)](https://docs.nwc.dev/) protocol as described by [NIP-47](https://github.com/nostr-protocol/nips/blob/master/47.md). It is a Flutter package that can be integrated into any Lightning wallet app to let its users connect their wallet to websites, platforms, apps or any NWC-enabled services.

[![NWC Infogram](https://github.com/kumulynja/nwc_wallet/assets/92805150/54bb7ec1-41fa-4bb5-b032-288bff9b77c1)](https://nwc.dev)

## What does this package do for you?

- It lets you generate or restore a Nostr keypair for the wallet
- It takes care of (re)connecting to a Nostr relay and subscribing to events for the wallet
- It lets you create and remove NWC connections to manage connections to websites, platforms, apps or any NWC-enabled services
- It handles and parses Nostr events like relay messages and NIP47 requests
- It decrypts and validates NIP47 requests and puts them in a stream for you to listen to
- The validation of the requests includes checking that it is a valid NIP47 request, that the request is not expired if it contains an expiration tag, that it is coming from a known and active connection and that the requested method is a known method and permitted for that connection. If any of the checks fails, the package handles the response and will not put the request in the stream.
- It provides methods to respond to NIP47 requests after you have handled them with your wallet
- The response methods take care of encrypting and publishing the response to the relay following NIP47

## What does this package NOT do for you?

- It does not persist the wallet service's Nostr keypair or the created NWC connections between app restarts

Since you are building a wallet, you certainly already have your own secure storage mechanism in place.
It is recommended to not only use a secure form of storage for the private key, but also for the The NWC connections (URI and permitted methods) since the URI contains the secret key of the connection.
As an id to store the connection by, you can use its pubkey, which is the public key related to its secret key. You could let the user set a readable name for the connection, but as an id to store the connection by, you should use the pubkey, since the pubkey is the only way to identify the connection in the NWC protocol.
When the app is restarted, you should pass the stored keypair and the connections to the `NwcWallet` constructor to continue using the same keypair and connections.

- It does not set or verify any budget limits, auto- or manual approvals or expiry date for the NWC connections

Together with the connection data like the name, URI and permitted methods, you should also save spending limits (budgets) and an expiry date for every connection. You could also let the user configure auto- or manual approval for payment requests. It is your responsability as a wallet builder to validate those settings when handling a request from the stream. The expiry date should be checked when handling any NWC requests and the budget and other limits before making a payment. If the expiry date or any budget limits are reached, you should use the `failedToHandleRequest` function and pass the appropriate error code. In case a connection is expired, also remove the connection with `removeConnection` so no further requests will be put on the stream for this connection anymore.

- It does not store the requests, they are only available in real-time through the stream

You should handle the requests in real-time and respond to them as soon as possible. If you can not handle a request, you should use the `failedToHandleRequest` method to inform the website or app that the request could not be handled. You could store the requests yourself if you want, but this is not required. If you want to process any missed events that were send while the app was not running, you should at least store the timestamp of the last event and pass it to the `NwcWallet` constructor when restarting the app.

- This package is not a Lightning wallet itself, it should be used alongside a Lightning wallet

To use this package, your app should already have a Lightning Network node or wallet embedded or have access to a Lightning wallet API so you can handle the NWC requests. You can look at [ldk-node-flutter](https://github.com/LtbLightning/ldk-node-flutter) for a Flutter package that can be used to run a Lightning node on mobile.

## Getting started

Install `nwc_wallet` as a dependency in your Flutter wallet app.

```bash
flutter pub add nwc_wallet
```

or add it to your `pubspec.yaml` file:

```yaml
dependencies:
  nwc_wallet: /*latest version*/
```

## Usage

Next, you can follow the steps below to integrate Nostr Wallet Connect into your app:

### 1. Generate or import a Nostr keypair for the wallet service\*

```dart
// New Nostr keypair
final nostrKeyPair = NostrKeyPair.generate();

print('Private key: ${nostrKeyPair.privateKey}');
```

```dart
// Existing Nostr keypair
final nostrKeyPair = NostrKeyPair(
    privateKey: 'your_private_key_here',
);
```

```dart
// Existing Nostr keypair from nsec
final nostrKeyPair = NostrKeyPair.fromNsec('your_nsec_here');
```

You should persist the private key in your app's secure storage to be able to use the same keypair between app restarts.

\* I recommend not using the same keypair of a user's Nostr profile (social media or others) for the wallet service. Generate or import a separate keypair used ONLY for NWC. Otherwise the apps you connect with can link your profile/identity with your wallet info and with the payments you make for their connection. This is a privacy concern and can be avoided by using a separate keypair for the wallet service.

### 2. Initialize an `NwcWallet` instance

`NwcWallet` is the main class of this package. It is a singleton class as normally you would only use one dedicated relay for NWC connections in your app. It takes care of connecting to the relay, subscribing to events and handling NIP47 requests and responses.

To initialize an `NwcWallet` instance, you should provide it the Nostr keypair from the previous step.
If it is not the first time and the user already has some active connections, also pass the list of existing NWC connections as saved by your app. If you want to get requests from when the app was not running, you can also pass the last event timestamp as saved by your app. You can also provide your preferred relay URL, but if you don't provide one, a default relay will be used.

```dart
final existingConnections = <NwcConnection>[/* existing connections here */];

final nwcWallet = NwcWallet(
    walletNostrKeyPair: nostrKeyPair,
    connections: existingConnections,
);
```

### 3. Listen for NWC requests and handle them based on the method type and with the wallet in your app

For every request that comes in through the stream, you should handle it based on the method type and call the appropriate method after the request has been handled through the user's Lightning wallet. This can be done by a simple switch statement based on the method type of the request.

```dart
nwcWallet.nwcRequests.listen((request) {
    switch (request.method) {
        case NwcMethod.getInfo:
            /* Todo yourself: Get the alias, color, network, blockHeight and blockHash of the Lightning wallet/node */
            nwcWallet.getInfoRequestHandled(
                request as NwcGetInfoRequest,
                alias: <alias>,
                color: <color>,
                pubkey: nostrKeyPair.publicKey,
                network: <network>,
                blockHeight: <blockHeight>,
                blockHash: <blockHash>,
                // Only keep the methods that the wallet supports and wants to permit for this connection
                methods: [
                    NwcMethod.getInfo,
                    NwcMethod.getBalance,
                    NwcMethod.makeInvoice,
                    NwcMethod.lookupInvoice,
                    NwcMethod.payInvoice,
                    NwcMethod.multiPayInvoice,
                    NwcMethod.payKeysend,
                    NwcMethod.multiPayKeysend,
                    NwcMethod.listTransactions,
                ],
            );
        case NwcMethod.getBalance:
            // Todo yourself: get the balance from the wallet/node
            nwcWallet.getBalanceRequestHandled(
                request as NwcGetBalanceRequest,
                balanceSat: <balance>,
            );
        case NwcMethod.makeInvoice:
            // Todo yourself: generate a new invoice with the wallet/node in your app
            nwcWallet.makeInvoiceRequestHandled(
                request as NwcMakeInvoiceRequest,
                invoice: <invoice>,
                description: <description>,
                descriptionHash: <descriptionHash>,
                preimage: <preimage>,
                paymentHash: <paymentHash>,
                amountSat: <amountSat>,
                feesPaidSat: <feesPaidSat>,
                createdAt: <createdAt>,
                expiresAt: <expiresAt>,
                metadata: <metadata>,
            );
        case NwcMethod.lookupInvoice:
            // Todo yourself: lookup the invoice with the wallet/node in your app
            nwcWallet.lookupInvoiceRequestHandled(
                request as NwcLookupInvoiceRequest,
                invoice: <invoice>,
                description: <description>,
                descriptionHash: <descriptionHash>,
                preimage: <preimage>,
                paymentHash: <paymentHash>,
                amountSat: <amountSat>,
                feesPaidSat: <feesPaidSat>,
                createdAt: <createdAt>,
                expiresAt: <expiresAt>,
                settledAt: <settledAt>,
                metadata: <metadata>,
            );
        case NwcMethod.payInvoice:
            // Todo yourself: Check the budget limits and expiry date of the connection before making the payment!!!
            // Todo yourself: Pay the invoice with the wallet/node in your app and get the preimage
            nwcWallet.payInvoiceRequestHandled(
                request as NwcPayInvoiceRequest,
                preimage: <preimage>
            );
        case NwcMethod.multiPayInvoice:
            // Todo yourself: Check the budget limits and expiry date of the connection before making the payments!!!
            // Todo yourself: Pay the invoices with the wallet/node in your app and get the preimages, pass them as a map with the invoice id as key
            nwcWallet.multiPayInvoiceRequestHandled(
                request as NwcMultiPayInvoiceRequest,
                preimageById: <{preimagesById}>,
            );
        case NwcMethod.payKeysend:
            // Todo yourself: Check the budget limits and expiry date of the connection before making the payment!!!
            // Todo yourself: Pay the keysend with the wallet/node in your app and get the preimage
            nwcWallet.payKeysendRequestHandled(
                request as NwcPayKeysendRequest,
                preimage: <preimage>
            );
        case NwcMethod.multiPayKeysend:
            // Todo yourself: Check the budget limits and expiry date of the connection before making the payments!!!
            // Todo yourself: Pay the keysends with the wallet/node in your app and get the preimages, pass them as a map with the keysend id as key
            nwcWallet.multiPayKeysendRequestHandled(
                request as NwcMultiPayKeysendRequest,
                preimageById: <{preimagesById}>,
            );
        case NwcMethod.listTransactions:
            // Todo yourself: Fetch the transactions from the wallet/node in your app
            final transactions = <NwcTransaction>[];
            nwcWallet.listTransactionsRequestHandled(
                request as NwcListTransactionsRequest,
                transactions: transactions,
            );
        default:
            // This should never happen as the package only puts known methods on the stream,
            //  but it is better to handle it anyway to prevent any unexpected behavior
            print('Unpermitted method: ${request.method}');
    }

    // (Optionally) Todo yourself: store the timestamp to get missed events since this moment after an app restart
});
```

If a request can not be handled, you should use the `failedToHandleRequest` method to inform the website or app, instead of using the specific request handled method. You could add a try catch block around the request handling to catch any exceptions that are thrown by the wallet/node in your app.

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

### 4. Create and store a new NWC connection

To create a new NWC connection, you can use the `addConnection` method:

```dart
final connection = await nwcWallet.addConnection(
    permittedMethods: [
        NwcMethod.getInfo,
        NwcMethod.getBalance,
        NwcMethod.makeInvoice,
        NwcMethod.lookupInvoice,
    ],
);

println('Connection added with id: ${connection.pubkey} and URI: ${connection.uri}');
```

The `addConnection` method returns the created connection with the pubkey, URI and permitted methods. You should store this connection in your app's secure storage mechanism to use it in the future when the app is restarted.
Also let the user enter a readable name, spending limit(s), approval logic and the expiry date for the connection and store this data as well, so you can validate it when handling requests.

## WIP

All basic functionality of the NWC protocol is implemented and working in this package, so you should already be able to use it in your app to make it compatible with NWC apps. But software is never finished, so be aware that following things should still be added or improved upon in future versions:

- [ ] Missed events handling
- [ ] Connection monitoring
- [ ] Updating permitted methods of a connection
- [ ] Status checks
- [ ] Custom exceptions
- [ ] More tests
- [ ] More documentation

Feel free to open an issue for any suggestions to improve or if you encounter any other problems or limitations that should be addressed.
And if you feel like contributing, pull requests are very welcome as well.

## Credits

Other Nostr Flutter packages have been helpful in the development of this package and some code snippets were borrowed from them. A big thanks to the developers of these packages:

- https://github.com/anasfik/nostr for the bech32 encoding and decoding code.
- https://github.com/ethicnology/dart-nostr for the nip04 encryption and decryption code.

Also the [Nostr Wallet Connect workshop](https://www.youtube.com/watch?v=V-7u7bJccSM) of [Plebdevs](https://www.plebdevs.com/) as instructed by [gudnuf](https://x.com/da_goodenough) was very helpful in understanding the NWC protocol.

## Special thanks

Also a special shootout to the amazing people at [Flash](https://paywithflash.com/), who are building the first Bitcoin payment gateway on top of Nostr Wallet Connect. They showed me the great potential of the NWC protocol and their work has been a motivation for me to build this package.

## NWC Apps

The Nostr Wallet Connect protocol consists of different parts. Mainly, the wallet service side and the website or app side. They communicate with each other over Nostr relays. This package is aimed to build the wallet service side of the protocol. If your app is not a wallet, but you would like to enable Lightning wallets to connect to your app through Nostr Wallet Connect, you can use the following Flutter package: https://github.com/bringinxyz/nwc.
