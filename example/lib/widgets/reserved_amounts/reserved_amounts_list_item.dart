import 'package:example/features/reserved_amounts_actions/reserved_amount_actions_bottom_sheet.dart';
import 'package:example/services/lightning_wallet_service.dart';
import 'package:example/view_models/reserved_amounts_list_item_view_model.dart';
import 'package:flutter/material.dart';

class ReservedAmountsListItem extends StatelessWidget {
  const ReservedAmountsListItem({
    super.key,
    required this.reservedAmount,
    required this.walletService,
  });

  final ReservedAmountsListItemViewModel reservedAmount;
  final LightningWalletService walletService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
        leading: const CircleAvatar(
          child: Text('R'),
        ),
        title: Text(
          reservedAmount.isActionRequired
              ? 'Pending allocation'
              : 'Being processed',
          style: theme.textTheme.titleMedium,
        ),
        subtitle: reservedAmount.isActionRequired
            ? const Text('ⓘ Action Required')
            : null,
        trailing: Text(
          '${reservedAmount.amountSat} sats',
          style: theme.textTheme.bodyMedium,
        ),
        onTap: reservedAmount.isActionRequired
            ? () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) {
                    return ReservedAmountActionsBottomSheet(
                      walletService: walletService,
                    );
                  },
                );
              }
            : null);
  }
}
