import 'dart:math';

import 'package:convert/convert.dart';
import 'package:bip340/bip340.dart' as bip340;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/nips/nip19.dart';

@immutable
class NostrKeyPair extends Equatable {
  final String privateKey;
  late final String publicKey;

  NostrKeyPair({required this.privateKey}) {
    if (privateKey.length != 64) {
      throw ArgumentError('Private key must be 64 hex characters');
    }
    publicKey = bip340.getPublicKey(privateKey);
  }

  factory NostrKeyPair.generate() {
    final privateKey = _generatePrivateKey();
    return NostrKeyPair(privateKey: privateKey);
  }

  factory NostrKeyPair.fromNsec(String nsec) {
    final privateKey = Nip19.nsecToHex(nsec);
    return NostrKeyPair(privateKey: privateKey);
  }

  String get nsec => Nip19.nsecFromHex(privateKey);
  String get npub => Nip19.npubFromHex(publicKey);

  /// Convert bits from one base to another
  /// [message] - The message to sign. Must be 32-bytes hex-encoded (a hash of
  ///   the actual message).
  /// [return] -  The signature as a string of 64 bytes hex-encoded.
  String sign(String message) {
    final aux = _generatePrivateKey();
    return bip340.sign(privateKey, message, aux);
  }

  static String _generatePrivateKey() {
    // A private key for Nostr has to be 64 hex characters,
    //  64 hex characters are 32 bytes, so generate 32 random bytes.
    //  A byte is 8 bits, which is 256 possible values to randomnly select from.
    final secureRandomNumberGenerator = Random.secure();
    final randomBytes = List<int>.generate(
      32,
      (i) => secureRandomNumberGenerator.nextInt(256),
    );
    return hex.encode(randomBytes);
  }

  @override
  List<Object?> get props => [privateKey, publicKey];
}
