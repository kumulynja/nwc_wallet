import 'package:bip340/bip340.dart' as bip340;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/nips/nip06.dart';
import 'package:nwc_wallet/nips/nip19.dart';
import 'package:nwc_wallet/utils/secret_generator.dart';

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

  factory NostrKeyPair.fromMnemonic(String mnemonic) {
    final privateKey = Nip06.mnemonicToPrivateKey(mnemonic);
    return NostrKeyPair(privateKey: privateKey);
  }

  factory NostrKeyPair.fromNsec(String nsec) {
    final privateKey = Nip19.nsecToHex(nsec);
    return NostrKeyPair(privateKey: privateKey);
  }

  String get nsec => Nip19.nsecFromHex(privateKey);
  String get npub => Nip19.npubFromHex(publicKey);

  /// Signs a message using the private key and returns the signature.
  /// [message] - The message to sign. Must be 32-bytes hex-encoded (a hash of
  ///   the actual message).
  /// [return] -  The signature as a string of 64 bytes hex-encoded.
  String sign(String message) {
    final aux = _generatePrivateKey();

    final signature = bip340.sign(privateKey, message, aux);

    return signature;
  }

  /// Verifies a signature for a message using the public key.
  /// [message] - The message to verify. Must be 32-bytes hex-encoded (a hash of
  ///  the actual message).
  /// [signature] - The signature to verify. Must be 64-bytes hex-encoded.
  /// [return] - True if the signature is valid, false otherwise.
  /// [throws] - ArgumentError if the signature is not 64 bytes long (128 characters)
  bool verify(String publicKey, String message, String signature) {
    if (signature.length != 128) {
      throw ArgumentError('Signature must be 64 hex characters');
    }
    return bip340.verify(publicKey, message, signature);
  }

  static String _generatePrivateKey() {
    // A private key for Nostr has to be 64 hex characters.
    String privateKey = SecretGenerator.secretHex(64);
    return privateKey;
  }

  @override
  List<Object?> get props => [privateKey, publicKey];
}
