import 'package:example/enums/lightning_node_implementation.dart';
import 'package:example/view_models/reserved_amounts_list_item_view_model.dart';
import 'package:example/view_models/transactions_list_item_view_model.dart';
import 'package:example/view_models/wallet_balance_view_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class HomeState extends Equatable {
  const HomeState({
    this.walletBalances = const [],
    this.transactionLists = const [],
    this.reservedAmountsLists = const [],
    this.walletIndex = 0,
  });

  final List<WalletBalanceViewModel> walletBalances;
  final List<List<TransactionsListItemViewModel>?> transactionLists;
  final List<List<ReservedAmountsListItemViewModel>?> reservedAmountsLists;
  final int walletIndex;

  HomeState copyWith({
    List<WalletBalanceViewModel>? walletBalances,
    List<List<TransactionsListItemViewModel>?>? transactionLists,
    List<List<ReservedAmountsListItemViewModel>?>? reservedAmountsLists,
    int? walletIndex,
  }) {
    return HomeState(
      walletBalances: walletBalances ?? this.walletBalances,
      transactionLists: transactionLists ?? this.transactionLists,
      reservedAmountsLists: reservedAmountsLists ?? this.reservedAmountsLists,
      walletIndex: walletIndex ?? this.walletIndex,
    );
  }

  LightningNodeImplementation get selectedLightningNodeImplementation {
    if (walletBalances.isEmpty) return LightningNodeImplementation.ldkNode;
    return walletBalances[walletIndex].lightningNodeImplementation;
  }

  @override
  List<Object?> get props => [
        walletBalances,
        transactionLists,
        reservedAmountsLists,
        walletIndex,
      ];
}
