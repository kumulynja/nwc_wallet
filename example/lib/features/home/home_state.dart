import 'package:example/view_models/reserved_amounts_list_item_view_model.dart';
import 'package:example/view_models/transactions_list_item_view_model.dart';
import 'package:example/view_models/wallet_balance_view_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class HomeState extends Equatable {
  const HomeState({
    this.walletBalance,
    this.transactionList = const [],
    this.reservedAmountsList = const [],
  });

  final WalletBalanceViewModel? walletBalance;
  final List<TransactionsListItemViewModel> transactionList;
  final List<ReservedAmountsListItemViewModel> reservedAmountsList;

  HomeState copyWith({
    WalletBalanceViewModel? walletBalance,
    List<TransactionsListItemViewModel>? transactionList,
    List<ReservedAmountsListItemViewModel>? reservedAmountsList,
  }) {
    return HomeState(
      walletBalance: walletBalance ?? this.walletBalance,
      transactionList: transactionList ?? this.transactionList,
      reservedAmountsList: reservedAmountsList ?? this.reservedAmountsList,
    );
  }

  @override
  List<Object?> get props => [
        walletBalance,
        transactionList,
        reservedAmountsList,
      ];
}
