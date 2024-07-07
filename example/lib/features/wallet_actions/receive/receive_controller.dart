import 'package:example/features/wallet_actions/receive/receive_state.dart';
import 'package:example/services/lightning_wallet_service.dart';

class ReceiveController {
  final ReceiveState Function() _getState;
  final Function(ReceiveState state) _updateState;
  final LightningWalletService _walletService;

  ReceiveController({
    required getState,
    required updateState,
    required walletService,
  })  : _getState = getState,
        _updateState = updateState,
        _walletService = walletService;

  void amountChangeHandler(String? amount) async {
    try {
      if (amount == null || amount.isEmpty) {
        _updateState(
            _getState().copyWith(amountSat: 0, isInvalidAmount: false));
      } else {
        final amountSat = int.parse(amount);
        _updateState(
            _getState().copyWith(amountSat: amountSat, isInvalidAmount: false));
      }
    } catch (e) {
      print(e);
      _updateState(_getState().copyWith(isInvalidAmount: true));
    }
  }

  void labelChangeHandler(String? label) async {
    if (label == null || label.isEmpty) {
      _updateState(_getState().copyWith(label: ''));
    } else {
      _updateState(_getState().copyWith(label: label));
    }
  }

  void messageChangeHandler(String? message) async {
    if (message == null || message.isEmpty) {
      _updateState(_getState().copyWith(message: ''));
    } else {
      _updateState(_getState().copyWith(message: message));
    }
  }

  Future<void> generateInvoice() async {
    try {
      final state = _getState();
      _updateState(state.copyWith(isGeneratingInvoice: true));

      final (bitcoinInvoice, lightningInvoice) =
          await _walletService.generateInvoices(
        amountSat: state.amountSat,
        description: '${state.label} - ${state.message}',
      );
      _updateState(_getState().copyWith(
        bitcoinInvoice: bitcoinInvoice,
        lightningInvoice: lightningInvoice,
      ));
    } catch (e) {
      print(e);
    } finally {
      _updateState(_getState().copyWith(isGeneratingInvoice: false));
    }
  }

  void editInvoice() {
    _updateState(
      const ReceiveState(),
    );
  }
}
