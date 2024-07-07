import 'package:example/constants/app_sizes.dart';
import 'package:example/enums/lightning_node_implementation.dart';
import 'package:example/view_models/wallet_balance_view_model.dart';
import 'package:example/widgets/wallets/add_new_wallet_card.dart';
import 'package:example/widgets/wallets/wallet_balance_card.dart';
import 'package:flutter/material.dart';

class WalletCardsList extends StatelessWidget {
  const WalletCardsList(
    this.walletBalances, {
    required this.onAddNewWallet,
    required this.onDeleteWallet,
    required this.onSelectWallet,
    required this.selectedWalletIndex,
    super.key,
  });

  final List<WalletBalanceViewModel> walletBalances;
  final Function(LightningNodeImplementation) onAddNewWallet;
  final Function(int index) onDeleteWallet;
  final Function(int index) onSelectWallet;
  final int selectedWalletIndex;

  @override
  Widget build(context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: walletBalances.length,
      itemExtent: AppSizes.kSpacingUnit * 20,
      itemBuilder: (BuildContext context, int index) {
        if (walletBalances[index].balanceSat == null) {
          return AddNewWalletCard(
            lightningNodeImplementation:
                walletBalances[index].lightningNodeImplementation,
            onPressed: onAddNewWallet,
          );
        } else {
          return WalletBalanceCard(
            walletBalances[index],
            onDelete: () => onDeleteWallet(index),
            onTap: () => onSelectWallet(index),
            isSelected: index == selectedWalletIndex,
          );
        }
      },
    );
  }
}
