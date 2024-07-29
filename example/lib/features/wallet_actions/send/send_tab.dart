import 'package:nwc_wallet_app/constants/app_sizes.dart';
import 'package:nwc_wallet_app/features/wallet_actions/send/send_controller.dart';
import 'package:nwc_wallet_app/features/wallet_actions/send/send_state.dart';
import 'package:nwc_wallet_app/services/lightning_wallet_service/lightning_wallet_service.dart';
import 'package:flutter/material.dart';

class SendTab extends StatefulWidget {
  const SendTab({required this.walletService, super.key});

  final LightningWalletService walletService;

  @override
  SendTabState createState() => SendTabState();
}

class SendTabState extends State<SendTab> {
  SendState _state = const SendState();
  late SendController _controller;

  @override
  void initState() {
    super.initState();

    _controller = SendController(
      getState: () => _state,
      updateState: (SendState state) => setState(() => _state = state),
      walletService: widget.walletService,
    );
  }

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
              helperText: 'The amount of sats to send.',
            ),
            onChanged: _controller.amountChangeHandler,
          ),
        ),
        const SizedBox(height: AppSizes.kSpacingUnit * 2),
        // Invoice Field
        SizedBox(
          width: 250,
          child: TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Invoice',
              hintText: '1bc1q2c3...',
              helperText: 'The invoice to pay.',
            ),
            onChanged: _controller.invoiceChangeHandler,
          ),
        ),
        const SizedBox(height: AppSizes.kSpacingUnit * 2),
        // Error message
        SizedBox(
          height: AppSizes.kSpacingUnit * 2,
          child: Text(
            _state.error is InvalidAmountException
                ? 'Please enter a valid amount.'
                : _state.error is NotEnoughFundsException
                    ? 'Not enough funds available.'
                    : _state.error is PaymentException
                        ? 'Failed to make payment. Please try again.'
                        : '',
            style: const TextStyle(
              color: Colors.red,
            ),
          ),
        ),
        const SizedBox(height: AppSizes.kSpacingUnit * 2),
        // Send funds Button
        ElevatedButton.icon(
          onPressed: _state.invoice == null ||
                  _state.invoice!.isEmpty ||
                  _state.error is InvalidAmountException ||
                  _state.error is NotEnoughFundsException ||
                  _state.isMakingPayment
              ? null
              : () async {
                  await _controller.makePayment();

                  if (_state.txId != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Payment successful. Tx ID: ${_state.partialTxId}'),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
          label: const Text('Send funds'),
          icon: _state.isMakingPayment
              ? const CircularProgressIndicator()
              : const Icon(Icons.send),
        ),
      ],
    );
  }
}
