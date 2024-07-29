import 'package:nwc_wallet_app/view_models/transactions_list_item_view_model.dart';
import 'package:nwc_wallet_app/widgets/transactions/transactions_list_item.dart';
import 'package:flutter/material.dart';

class TransactionsList extends StatelessWidget {
  const TransactionsList({
    super.key,
    required this.transactions,
  });

  final List<TransactionsListItemViewModel>? transactions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Transactions',
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
            return TransactionsListItem(
              transaction: transactions![index],
            );
          },
          itemCount: transactions == null ? 0 : transactions!.length,
        ),
      ],
    );
  }
}
