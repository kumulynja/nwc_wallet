import 'package:example/features/wallet_actions/send/send_state.dart';
import 'package:example/services/lightning_wallet_service.dart';

class SendController {
  final SendState Function() _getState;
  final Function(SendState state) _updateState;
  final LightningWalletService _walletService;

  SendController({
    required getState,
    required updateState,
    required walletService,
  })  : _getState = getState,
        _updateState = updateState,
        _walletService = walletService;

  void amountChangeHandler(String? amount) async {
    final state = _getState();
    try {
      if (amount == null || amount.isEmpty) {
        _updateState(state.copyWith(clearAmountSat: true, clearError: true));
      } else {
        final amountSat = int.parse(amount);
        if (amountSat > await _walletService.spendableBalanceSat) {
          _updateState(state.copyWith(
            error: NotEnoughFundsException(),
          ));
        } else {
          _updateState(state.copyWith(amountSat: amountSat, clearError: true));
        }
      }
    } catch (e) {
      print(e);
      _updateState(state.copyWith(
        error: InvalidAmountException(),
      ));
    }
  }

  void invoiceChangeHandler(String? invoice) async {
    if (invoice == null || invoice.isEmpty) {
      _updateState(_getState().copyWith(invoice: ''));
    } else {
      _updateState(_getState().copyWith(invoice: invoice));
    }
  }

  Future<void> makePayment() async {
    final state = _getState();
    try {
      _updateState(state.copyWith(isMakingPayment: true));

      final txId = await _walletService.pay(
        state.invoice!,
        amountSat: state.amountSat,
        satPerVbyte: state.satPerVbyte,
      );

      _updateState(state.copyWith(
        isMakingPayment: false,
        txId: txId,
      ));
    } catch (e) {
      print(e);
      _updateState(state.copyWith(
        isMakingPayment: false,
        error: PaymentException(),
      ));
    }
  }
}

class InvalidAmountException implements Exception {}

class NotEnoughFundsException implements Exception {}

class PaymentException implements Exception {}
