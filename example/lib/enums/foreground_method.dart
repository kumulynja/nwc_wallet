enum ForegroundMethod {
  hasWallet('hasWallet'),
  ;

  final String plaintext;

  const ForegroundMethod(this.plaintext);

  factory ForegroundMethod.fromPlaintext(String plaintext) {
    switch (plaintext) {
      case 'hasWallet':
        return ForegroundMethod.hasWallet;
      default:
        throw Exception('Unknown method: $plaintext');
    }
  }
}
