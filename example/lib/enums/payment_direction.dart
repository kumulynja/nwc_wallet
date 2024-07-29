enum PaymentDirection {
  incoming('incoming'),
  outgoing('outgoing');

  final String plaintext;

  const PaymentDirection(this.plaintext);

  static PaymentDirection fromPlaintext(String plaintext) {
    switch (plaintext) {
      case 'incoming':
        return PaymentDirection.incoming;
      case 'outgoing':
        return PaymentDirection.outgoing;
      default:
        throw Exception('Unknown PaymentDirection: $plaintext');
    }
  }
}
