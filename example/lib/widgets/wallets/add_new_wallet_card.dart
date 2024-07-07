import 'package:example/enums/lightning_node_implementation.dart';
import 'package:example/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class AddNewWalletCard extends StatelessWidget {
  const AddNewWalletCard({
    required this.lightningNodeImplementation,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final LightningNodeImplementation lightningNodeImplementation;
  final Function(LightningNodeImplementation) onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.kSpacingUnit),
        onTap: () => onPressed(lightningNodeImplementation),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add,
            ),
            Text('Add wallet: ${lightningNodeImplementation.label}'),
          ],
        ),
      ),
    );
  }
}
