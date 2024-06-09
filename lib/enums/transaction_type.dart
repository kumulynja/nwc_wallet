enum TransactionType {
  incoming,
  outgoing,
}

extension TransactionTypeX on TransactionType {
  static TransactionType fromName(String name) {
    switch (name) {
      case 'incoming':
        return TransactionType.incoming;
      case 'outgoing':
        return TransactionType.outgoing;
      default:
        throw Exception('Unknown transaction type: $name');
    }
  }
}
