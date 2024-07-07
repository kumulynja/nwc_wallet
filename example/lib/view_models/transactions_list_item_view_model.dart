import 'package:example/entities/payment_details_entity.dart';
import 'package:equatable/equatable.dart';
import 'package:example/enums/payment_direction.dart';

class TransactionsListItemViewModel extends Equatable {
  final String id;
  final int amountSat;
  final int? timestamp;

  const TransactionsListItemViewModel({
    required this.id,
    required this.amountSat,
    this.timestamp,
  });

  TransactionsListItemViewModel.fromTransactionEntity(
      PaymentDetailsEntity entity)
      : id = entity.paymentHash,
        amountSat = entity.direction == PaymentDirection.incoming
            ? entity.amountSat!
            : -entity.amountSat!,
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
