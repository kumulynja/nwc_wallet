import 'package:nwc_wallet_app/constants/app_sizes.dart';
import 'package:nwc_wallet_app/view_models/wallet_balance_view_model.dart';
import 'package:flutter/material.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard(
    this.walletBalance, {
    super.key,
    required this.onDelete,
    required this.onTap,
  });

  final WalletBalanceViewModel walletBalance;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.kSpacingUnit),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.kSpacingUnit),
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: AppSizes.kSpacingUnit * 12,
                  width: double.infinity,
                  color: theme.colorScheme.surface,
                  child: Image.asset('assets/logos/ldk_node.png',
                      fit: BoxFit
                          .contain // This will make the image fit the container, but it will not stretch it
                      ),
                ),
                // Expanded to take up all the space of the height the list is constrained to
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSizes.kSpacingUnit),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${walletBalance.balanceSat} SAT',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                )
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: CloseButton(
                onPressed: onDelete,
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    EdgeInsets.zero,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  iconSize: WidgetStateProperty.all(
                    AppSizes.kSpacingUnit * 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
