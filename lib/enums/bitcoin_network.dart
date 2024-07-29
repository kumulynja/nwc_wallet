enum BitcoinNetwork {
  mainnet('mainnet'),
  testnet('testnet'),
  signet('signet'),
  regtest('regtest');

  final String plaintext;

  const BitcoinNetwork(this.plaintext);

  static BitcoinNetwork fromPlaintext(String value) {
    switch (value) {
      case 'mainnet':
        return BitcoinNetwork.mainnet;
      case 'testnet':
        return BitcoinNetwork.testnet;
      case 'signet':
        return BitcoinNetwork.signet;
      case 'regtest':
        return BitcoinNetwork.regtest;
      default:
        throw ArgumentError('Invalid BitcoinNetwork value: $value');
    }
  }
}
