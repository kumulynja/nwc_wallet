import 'package:example/constants/app_sizes.dart';
import 'package:example/features/wallet_actions/receive/receive_controller.dart';
import 'package:example/features/wallet_actions/receive/receive_state.dart';
import 'package:example/services/lightning_wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ReceiveTab extends StatefulWidget {
  const ReceiveTab({required this.walletService, super.key});

  final LightningWalletService walletService;

  @override
  ReceiveTabState createState() => ReceiveTabState();
}

class ReceiveTabState extends State<ReceiveTab> {
  ReceiveState _state = const ReceiveState();
  late ReceiveController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ReceiveController(
      getState: () => _state,
      updateState: (ReceiveState state) => setState(() => _state = state),
      walletService: widget.walletService,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _state.isGeneratingInvoice
            ? const CircularProgressIndicator()
            : _state.bip21Uri == null || _state.bip21Uri!.isEmpty
                ? ReceiveTabInputFields(
                    hasWalletAvailable: widget.walletService.hasWallet,
                    amountChangeHandler: _controller.amountChangeHandler,
                    labelChangeHandler: _controller.labelChangeHandler,
                    messageChangeHandler: _controller.messageChangeHandler,
                    isInvalidAmount: _state.isInvalidAmount,
                    generateInvoiceHandler: _controller.generateInvoice,
                  )
                : ReceiveTabInvoice(
                    bip21Uri: _state.bip21Uri!,
                    editInvoiceHandler: _controller.editInvoice,
                  ),
      ],
    );
  }
}

class ReceiveTabInputFields extends StatelessWidget {
  const ReceiveTabInputFields({
    super.key,
    this.hasWalletAvailable = false,
    required this.amountChangeHandler,
    required this.labelChangeHandler,
    required this.messageChangeHandler,
    required this.isInvalidAmount,
    required this.generateInvoiceHandler,
  });

  final bool hasWalletAvailable;
  final Function(String?) amountChangeHandler;
  final Function(String?) labelChangeHandler;
  final Function(String?) messageChangeHandler;
  final bool isInvalidAmount;
  final Future<void> Function() generateInvoiceHandler;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: AppSizes.kSpacingUnit * 2),
        // Amount Field
        SizedBox(
          width: 250,
          child: TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Amount (optional)',
              hintText: '0',
              helperText: 'The amount of sats to receive.',
            ),
            onChanged: amountChangeHandler,
          ),
        ),
        const SizedBox(height: AppSizes.kSpacingUnit * 2),

        // Label Field
        SizedBox(
          width: 250,
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Label (optional)',
              hintText: 'Alice',
              helperText: 'A name the payer knows you by.',
            ),
            onChanged: labelChangeHandler,
          ),
        ),
        const SizedBox(height: AppSizes.kSpacingUnit * 2),

        // Message Field
        SizedBox(
          width: 250,
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Message (optional)',
              hintText: 'Payback for dinner.',
              helperText: 'A note to the payer.',
            ),
            onChanged: messageChangeHandler,
          ),
        ),
        const SizedBox(height: AppSizes.kSpacingUnit * 2),

        // Error message
        SizedBox(
          height: AppSizes.kSpacingUnit * 2,
          child: Text(
            isInvalidAmount ? 'Please enter a valid amount.' : '',
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.kSpacingUnit * 2),
        // Generate invoice Button
        ElevatedButton.icon(
          onPressed: !hasWalletAvailable || isInvalidAmount
              ? null
              : () async {
                  await generateInvoiceHandler();
                },
          label: const Text('Generate invoice'),
          icon: const Icon(Icons.qr_code),
        ),
      ],
    );
  }
}

class ReceiveTabInvoice extends StatelessWidget {
  const ReceiveTabInvoice({
    super.key,
    required this.bip21Uri,
    required this.editInvoiceHandler,
  });

  final String bip21Uri;
  final Function() editInvoiceHandler;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // QR Code
        QrImageView(
          data: bip21Uri,
        ),
        const SizedBox(height: AppSizes.kSpacingUnit * 2),
        // Invoice
        Text(
          bip21Uri,
          overflow: TextOverflow.ellipsis,
          maxLines: 4,
        ),
        const SizedBox(height: AppSizes.kSpacingUnit * 2),
        // Button Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Edit Button
            ElevatedButton.icon(
              onPressed: editInvoiceHandler,
              label: const Text('Edit'),
              icon: const Icon(Icons.edit),
            ),
            // Copy Button
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: bip21Uri)).then(
                  (_) {
                    // Optionally, show a confirmation message to the user.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Invoice copied to clipboard!'),
                      ),
                    );
                  },
                );
              },
              label: const Text('Copy'),
              icon: const Icon(Icons.copy),
            ),
          ],
        ),
      ],
    );
  }
}
