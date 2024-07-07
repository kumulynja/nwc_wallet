import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:convert/convert.dart';

class Nip06 {
  static String mnemonicToPrivateKey(String mnemonic, {int accountIndex = 0}) {
    final nip06DerivationPath = "m/44'/1237'/$accountIndex'/0/0";

    final seedHex = bip39.mnemonicToSeedHex(mnemonic);
    final node = bip32.BIP32.fromSeed(Uint8List.fromList(hex.decode(seedHex)));
    final child = node.derivePath(nip06DerivationPath);

    return hex.encode(child.privateKey!.toList());
  }
}
