import 'package:example/features/home/home_state.dart';
import 'package:example/services/lightning_wallet_service/lightning_wallet_service.dart';
import 'package:example/services/nwc_wallet_service/nwc_wallet_service.dart';
import 'package:example/view_models/reserved_amounts_list_item_view_model.dart';
import 'package:example/view_models/transactions_list_item_view_model.dart';
import 'package:example/view_models/wallet_balance_view_model.dart';

class HomeController {
  final HomeState Function() _getState;
  final Function(HomeState state) _updateState;
  final LightningWalletService _walletService;
  final NwcWalletService _nwcWalletService;

  HomeController({
    required getState,
    required updateState,
    required walletService,
    required nwcWalletService,
  })  : _getState = getState,
        _updateState = updateState,
        _walletService = walletService,
        _nwcWalletService = nwcWalletService;

  Future<void> init() async {
    _updateState(_getState().copyWith(
      walletBalance: WalletBalanceViewModel(
        balanceSat: _walletService.hasWallet
            ? await _walletService.spendableBalanceSat
            : null,
      ),
      transactionList: _walletService.hasWallet ? await _getTransactions() : [],
      reservedAmountsList:
          _walletService.hasWallet ? await _getReservedAmounts() : null,
    ));
  }

  Future<void> addNewWallet() async {
    final state = _getState();
    try {
      await _walletService.addWallet();
      // Now that a lightning wallet is created,
      //  the Nwc wallet service can also be initialized
      await _nwcWalletService.init();
      _updateState(
        state.copyWith(
          walletBalance: WalletBalanceViewModel(
            balanceSat: await _walletService.spendableBalanceSat,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteWallet() async {
    try {
      await _walletService.deleteWallet();
      final state = _getState();
      _updateState(
        state.copyWith(
          walletBalance: const WalletBalanceViewModel(
            balanceSat: null,
          ),
          transactionList: null,
          reservedAmountsList: null,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> refresh() async {
    try {
      final state = _getState();
      if (_walletService.hasWallet) {
        await _walletService.sync();
        final balance = await _walletService.spendableBalanceSat;
        _updateState(
          state.copyWith(
            walletBalance: WalletBalanceViewModel(
              balanceSat: balance,
            ),
            transactionList: await _getTransactions(),
            reservedAmountsList: await _getReservedAmounts(),
          ),
        );
      }
    } catch (e) {
      print(e);
      // ToDo: handle and set error state
    }
  }

  Future<List<TransactionsListItemViewModel>> _getTransactions() async {
    // Get transaction entities from the wallet
    final transactionEntities = await _walletService.getTransactions();
    // Map transaction entities to view models
    final transactions = transactionEntities
        .map((entity) =>
            TransactionsListItemViewModel.fromTransactionEntity(entity))
        .toList();
    // Sort transactions by timestamp in descending order
    transactions.sort((t1, t2) {
      if (t1.timestamp == null && t2.timestamp == null) {
        return 0;
      }
      if (t1.timestamp == null) {
        return -1;
      }
      if (t2.timestamp == null) {
        return 1;
      }
      return t2.timestamp!.compareTo(t1.timestamp!);
    });
    return transactions;
  }

  Future<List<ReservedAmountsListItemViewModel>> _getReservedAmounts() async {
    final List<ReservedAmountsListItemViewModel> reservedAmounts = [];
    final spendableOnChainBalanceSat =
        await _walletService.spendableOnChainBalanceSat;
    final totalOnChainBalanceSat = await _walletService.totalOnChainBalanceSat;

    if (spendableOnChainBalanceSat > 0) {
      reservedAmounts.add(
        ReservedAmountsListItemViewModel(
          amountSat: spendableOnChainBalanceSat,
          isActionRequired: true,
        ),
      );
    }
    if (totalOnChainBalanceSat > spendableOnChainBalanceSat) {
      reservedAmounts.add(
        ReservedAmountsListItemViewModel(
          amountSat: totalOnChainBalanceSat - spendableOnChainBalanceSat,
          isActionRequired: false,
        ),
      );
    }
    return reservedAmounts;
  }
}
