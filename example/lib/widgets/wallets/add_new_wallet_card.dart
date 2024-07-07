import 'package:example/constants/app_sizes.dart';
import 'package:flutter/material.dart';

class AddNewWalletCard extends StatelessWidget {
  const AddNewWalletCard({
    required this.onPressed,
    super.key,
  });

  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.kSpacingUnit),
        onTap: () => onPressed(),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
            ),
            Text('Add wallet'),
          ],
        ),
      ),
    );
  }
}
