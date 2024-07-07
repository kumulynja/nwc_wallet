import 'package:equatable/equatable.dart';

class ReservedAmountsListItemViewModel extends Equatable {
  final int amountSat;
  final bool isActionRequired;

  const ReservedAmountsListItemViewModel({
    required this.amountSat,
    required this.isActionRequired,
  });

  double? get amountBtc => amountSat / 100000000;

  @override
  List<Object?> get props => [amountSat, isActionRequired];
}
