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

This package takes care of the [wallet service](https://docs.nwc.dev/bitcoin-lightning-wallets/getting-started) side of the [Nostr Wallet Connect (NWC)](https://docs.nwc.dev/) protocol as described by [NIP-47](https://github.com/nostr-protocol/nips/blob/master/47.md). It is a Flutter package that can be integrated in any Lightning wallet app to let users connect their wallet to websites and apps.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Limitations

The package is still in development and should be used with caution. Following are some of the current limitations:

- Only real-time events are supported, the package does not return missed events yet.
- The package is not yet fully tested or documented.
- No connection monitoring and reconnect mechanism is implemented yet.
- No retry mechanisms are currently implemented on failures.
- No custom exceptions available yet for better error handling.

All of these limitations will of course be addressed in future releases.
Feel free to open any issues if you encounter any other limitations that are not listed here.

## Getting started

TODO: List prerequisites and provide or point to information on how to
start using the package.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.

## Credits

Other Nostr Flutter packages have been helpful in the development of this package and some code snippets were borrowed from them. Special thanks to the developers of these packages:

- https://github.com/anasfik/nostr for the bech32 encoding and decoding code.
- https://github.com/ethicnology/dart-nostr for the nip04 encryption and decryption code.

Also the [Nostr Wallet Connect workshop](https://www.youtube.com/watch?v=V-7u7bJccSM) of [Plebdevs](https://www.plebdevs.com/) as instructed by [gudnuf](https://x.com/da_goodenough) was very helpful in understanding the NWC protocol.

Also a special shootout to the amazing people at [Flash](https://paywithflash.com/), who are building the first Bitcoin payment gateway on top of Nostr Wallet Connect. Thanks to them I could see the great potential of the NWC protocol and decided to build this package.

## NWC Apps

The Nostr Wallet Connect protocol consists of different parts. Mainly, the wallet service side and the website or app side. They communicate with each other over Nostr relays. This package is aimed to build the wallet service side of the protocol. If your app is not a wallet, but you would like to enable Lightning wallets to connect to your app through Nostr Wallet Connect, you can use the following Flutter package:

- https://github.com/bringinxyz/nwc
