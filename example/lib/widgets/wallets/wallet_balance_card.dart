import 'package:example/constants/app_sizes.dart';
import 'package:example/view_models/wallet_balance_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WalletBalanceCard extends StatelessWidget {
  const WalletBalanceCard(
    this.walletBalance, {
    super.key,
    required this.onDelete,
    required this.onTap,
    required this.isSelected,
  });

  final WalletBalanceViewModel walletBalance;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final bool isSelected;

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
                  child: Image.asset(
                      walletBalance.lightningNodeImplementation.logoPath,
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
                          walletBalance.lightningNodeImplementation.label,
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(height: AppSizes.kSpacingUnit),
                        Text(
                          '${walletBalance.balanceBtc} BTC',
                          style: theme.textTheme.bodyMedium,
                        ),
                        const Spacer(),
                        if (isSelected)
                          Container(
                            height: AppSizes.kSpacingUnit / 2,
                            width: double.infinity,
                            color: theme.colorScheme.onSurface,
                          ),
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
