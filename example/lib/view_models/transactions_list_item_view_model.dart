import 'package:example/entities/transaction_entity.dart';
import 'package:equatable/equatable.dart';

class TransactionsListItemViewModel extends Equatable {
  final String id;
  final int amountSat;
  final int? timestamp;

  const TransactionsListItemViewModel({
    required this.id,
    required this.amountSat,
    this.timestamp,
  });

  TransactionsListItemViewModel.fromTransactionEntity(TransactionEntity entity)
      : id = entity.id,
        amountSat = entity.receivedAmountSat - entity.sentAmountSat,
        timestamp = entity.timestamp;

  bool get isIncoming => amountSat > 0;
  bool get isOutgoing => amountSat < 0;
  double get amountBtc => amountSat / 100000000;

  String? get formattedTimestamp {
    if (timestamp == null) {
      return null;
    }

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp! * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  @override
  List<Object?> get props => [id, amountSat, timestamp];
}
