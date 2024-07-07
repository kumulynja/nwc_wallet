import 'package:example/services/lightning_wallet_service.dart';
import 'package:example/view_models/reserved_amounts_list_item_view_model.dart';
import 'package:example/widgets/reserved_amounts/reserved_amounts_list_item.dart';
import 'package:flutter/material.dart';

class ReservedAmountsList extends StatelessWidget {
  const ReservedAmountsList({
    super.key,
    required this.reservedAmounts,
    required this.walletService,
  });

  final List<ReservedAmountsListItemViewModel>? reservedAmounts;
  final LightningWalletService walletService;

  @override
  Widget build(BuildContext context) {
    return reservedAmounts == null || reservedAmounts!.isEmpty
        ? const SizedBox()
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Reserved amounts',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap:
                    true, // To set constraints on the ListView in an infinite height parent (ListView in HomeScreen)
                physics:
                    const NeverScrollableScrollPhysics(), // Scrolling is handled by the parent (ListView in HomeScreen)
                itemBuilder: (ctx, index) {
                  return ReservedAmountsListItem(
                    reservedAmount: reservedAmounts![index],
                    walletService: walletService,
                  );
                },
                itemCount:
                    reservedAmounts == null ? 0 : reservedAmounts!.length,
              ),
            ],
          );
  }
}
