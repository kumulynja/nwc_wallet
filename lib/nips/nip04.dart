import 'dart:convert';
import 'dart:typed_data';

import 'package:nwc_wallet/utils/kepler_crypto.dart';
import 'package:pointycastle/export.dart';
import 'package:nwc_wallet/utils/secret_generator.dart';

class Nip04 {
  static String encrypt(
    String content,
    String senderPrivateKey,
    String receiverPublicKey,
  ) {
    try {
      return _nip4cipher(
        senderPrivateKey,
        '02$receiverPublicKey',
        content,
        true,
      );
    } catch (e) {
      throw Exception('Failed to encrypt content: $e');
    }
  }

  static String decrypt(
    String content,
    String receiverPrivateKey,
    String senderPublicKey,
  ) {
    if (!content.contains("?iv=")) {
      // Invlaid content or not encrypted following the NIP-04 standard
      throw Exception('Invalid content or not nip04 encrypted');
    }

    final [encryptedText, initializationVector] = content.split("?iv=");

    try {
      final decryptedText = _nip4cipher(
        receiverPrivateKey,
        '02$senderPublicKey',
        encryptedText,
        false,
        nonce: initializationVector,
      );
      return decryptedText;
    } catch (e) {
      throw Exception('Failed to decrypt content: $e');
    }
  }

  static String _nip4cipher(
    String privkey,
    String pubkey,
    String payload,
    bool cipher, {
    String? nonce,
  }) {
    // if cipher=false –> decipher –> nonce needed
    if (!cipher && nonce == null) throw Exception("missing nonce");

    // init variables
    Uint8List input, output, iv;
    if (!cipher && nonce != null) {
      input = base64.decode(payload);
      output = Uint8List(input.length);
      iv = base64.decode(nonce);
    } else {
      input = const Utf8Encoder().convert(payload);
      output = Uint8List(input.length + 16);
      iv = Uint8List.fromList(SecretGenerator.secretBytes(16));
    }

    // params
    List<List<int>> keplerSecret = Kepler.byteSecret(privkey, pubkey);
    var key = Uint8List.fromList(keplerSecret[0]);
    var params = PaddedBlockCipherParameters(
      ParametersWithIV(KeyParameter(key), iv),
      null,
    );
    var algo = PaddedBlockCipherImpl(
      PKCS7Padding(),
      CBCBlockCipher(AESEngine()),
    );

    // processing
    algo.init(cipher, params);
    var offset = 0;
    while (offset < input.length - 16) {
      offset += algo.processBlock(input, offset, output, offset);
    }
    offset += algo.doFinal(input, offset, output, offset);
    Uint8List result = output.sublist(0, offset);

    if (cipher) {
      String stringIv = base64.encode(iv);
      String plaintext = base64.encode(result);
      return "$plaintext?iv=$stringIv";
    } else {
      return const Utf8Decoder().convert(result);
    }
  }
}
