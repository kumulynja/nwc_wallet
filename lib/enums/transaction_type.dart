enum TransactionType {
  incoming('incoming'),
  outgoing('outgoing');

  final String name;

  const TransactionType(this.name);

  factory TransactionType.fromName(String name) {
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
