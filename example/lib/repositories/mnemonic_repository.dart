import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class MnemonicRepository {
  Future<void> setMnemonic(String walletName, String mnemonic);
  Future<String?> getMnemonic(String walletName);
  Future<void> deleteMnemonic(String walletName);
}

class SecureStorageMnemonicRepository implements MnemonicRepository {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _mnemonicKey = 'mnemonic';

  @override
  Future<void> setMnemonic(String walletName, String mnemonic) async {
    await _secureStorage.write(
      key: _getMnemonicKey(walletName),
      value: mnemonic,
    );
  }

  @override
  Future<String?> getMnemonic(String walletName) {
    return _secureStorage.read(key: _getMnemonicKey(walletName));
  }

  @override
  Future<void> deleteMnemonic(String walletName) {
    return _secureStorage.delete(key: _getMnemonicKey(walletName));
  }

  String _getMnemonicKey(String walletName) => '$_mnemonicKey$walletName';
}
