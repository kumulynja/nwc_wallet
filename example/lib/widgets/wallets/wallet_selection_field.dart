import 'package:example/constants/app_sizes.dart';
import 'package:example/enums/lightning_node_implementation.dart';
import 'package:flutter/material.dart';

class WalletSelectionField extends StatelessWidget {
  const WalletSelectionField({
    super.key,
    this.selectedWallet,
    required this.availableWallets,
    required this.onLightningNodeImplementationChange,
    this.helpText,
  });

  final LightningNodeImplementation? selectedWallet;
  final List<LightningNodeImplementation> availableWallets;
  final Function(LightningNodeImplementation)
      onLightningNodeImplementationChange;
  final String? helpText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.kSpacingUnit,
            vertical: AppSizes.kSpacingUnit * 2,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.colorScheme.secondary,
            ),
            borderRadius: BorderRadius.circular(AppSizes.kSpacingUnit / 2),
          ),
          width: 250,
          child: Row(
            children: [
              Image.asset(
                selectedWallet!.logoPath,
                height: 60,
                width: 75,
              ),
              const SizedBox(width: AppSizes.kSpacingUnit),
              Text(selectedWallet!.label),
              const Spacer(),
              TextButton(
                onPressed: availableWallets.length > 1
                    ? () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Select Wallet'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: availableWallets
                                    .map(
                                      (wallet) => ListTile(
                                        title: Text(wallet.label),
                                        onTap: () {
                                          onLightningNodeImplementationChange(
                                              wallet);
                                          Navigator.pop(context);
                                        },
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                        );
                      }
                    : null,
                child: const Text('Change'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSizes.kSpacingUnit),
        // Helper text
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.kSpacingUnit * 1.5,
          ),
          child: Text(
            helpText ?? 'Select the wallet you want to use.',
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}
