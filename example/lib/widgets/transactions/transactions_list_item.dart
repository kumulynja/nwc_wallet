import 'package:example/enums/lightning_node_implementation.dart';
import 'package:example/view_models/transactions_list_item_view_model.dart';
import 'package:flutter/material.dart';

class TransactionsListItem extends StatelessWidget {
  const TransactionsListItem({
    super.key,
    required this.transaction,
    required this.lightningNodeImplementation,
  });

  final TransactionsListItemViewModel transaction;
  final LightningNodeImplementation lightningNodeImplementation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        child: Icon(
          transaction.isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
        ),
      ),
      title: Text(
        transaction.isIncoming ? 'Received funds' : 'Sent funds',
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Text(
        transaction.formattedTimestamp != null
            ? transaction.formattedTimestamp!
            : '',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Text(
          '${transaction.isIncoming ? '+' : ''}${transaction.amountSat} sats',
          style: theme.textTheme.bodyMedium),
    );
  }
}
