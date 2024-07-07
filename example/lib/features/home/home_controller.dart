import 'package:example/enums/lightning_node_implementation.dart';
import 'package:example/features/home/home_state.dart';
import 'package:example/services/lightning_wallet_service.dart';
import 'package:example/view_models/reserved_amounts_list_item_view_model.dart';
import 'package:example/view_models/transactions_list_item_view_model.dart';
import 'package:example/view_models/wallet_balance_view_model.dart';

class HomeController {
  final HomeState Function() _getState;
  final Function(HomeState state) _updateState;
  final List<LightningWalletService> _walletServices;

  HomeController({
    required getState,
    required updateState,
    required walletServices,
  })  : _getState = getState,
        _updateState = updateState,
        _walletServices = walletServices;

  Future<void> init() async {
    final walletBalances = <WalletBalanceViewModel>[];
    final transactionLists = <List<TransactionsListItemViewModel>?>[];
    final reservedAmountsLists = <List<ReservedAmountsListItemViewModel>?>[];
    for (int i = 0; i < _walletServices.length; i++) {
      final service = _walletServices[i];
      walletBalances.add(
        WalletBalanceViewModel(
          lightningNodeImplementation: service.lightningNodeImplementation,
          balanceSat:
              service.hasWallet ? await service.spendableBalanceSat : null,
        ),
      );
      transactionLists.add(
        service.hasWallet ? await _getTransactions(service) : null,
      );
      reservedAmountsLists.add(
        service.hasWallet ? await _getReservedAmounts(service) : null,
      );
    }

    _updateState(_getState().copyWith(
      walletBalances: walletBalances,
      transactionLists: transactionLists,
      reservedAmountsLists: reservedAmountsLists,
    ));
  }

  Future<void> addNewWallet(
      LightningNodeImplementation lightningNodeImplementation) async {
    final walletIndex = _walletServices.indexWhere(
      (service) =>
          service.lightningNodeImplementation == lightningNodeImplementation,
    );
    final walletService = _walletServices[walletIndex];
    final state = _getState();
    try {
      await walletService.addWallet();
      _updateState(
        state.copyWith(
          walletBalances: state.walletBalances
            ..[walletIndex] = WalletBalanceViewModel(
              lightningNodeImplementation:
                  walletService.lightningNodeImplementation,
              balanceSat: await walletService.spendableBalanceSat,
            ),
          walletIndex: walletIndex,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteWallet(int index) async {
    try {
      await _walletServices[index].deleteWallet();
      final state = _getState();
      _updateState(
        state.copyWith(
          walletBalances: state.walletBalances
            ..[index] = WalletBalanceViewModel(
              lightningNodeImplementation:
                  state.walletBalances[index].lightningNodeImplementation,
              balanceSat: null,
            ),
          transactionLists: state.transactionLists..[index] = null,
          reservedAmountsLists: state.reservedAmountsLists..[index] = null,
          walletIndex: index - 1 < 0 ? 0 : index - 1,
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> refresh() async {
    try {
      final state = _getState();
      final walletService = _walletServices[state.walletIndex];
      if (walletService.hasWallet) {
        await walletService.sync();
        final balance = await walletService.spendableBalanceSat;
        _updateState(
          state.copyWith(
            walletBalances: state.walletBalances
              ..[state.walletIndex] = WalletBalanceViewModel(
                lightningNodeImplementation: state
                    .walletBalances[state.walletIndex]
                    .lightningNodeImplementation,
                balanceSat: balance,
              ),
            transactionLists: state.transactionLists
              ..[state.walletIndex] = await _getTransactions(walletService),
            reservedAmountsLists: state.reservedAmountsLists
              ..[state.walletIndex] = await _getReservedAmounts(walletService),
          ),
        );
      }
    } catch (e) {
      print(e);
      // ToDo: handle and set error state
    }
  }

  void selectWallet(int index) {
    _updateState(_getState().copyWith(walletIndex: index));
  }

  Future<List<TransactionsListItemViewModel>> _getTransactions(
    LightningWalletService wallet,
  ) async {
    // Get transaction entities from the wallet
    final transactionEntities = await wallet.getTransactions();
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

  Future<List<ReservedAmountsListItemViewModel>> _getReservedAmounts(
    LightningWalletService wallet,
  ) async {
    final List<ReservedAmountsListItemViewModel> reservedAmounts = [];
    final spendableOnChainBalanceSat = await wallet.spendableOnChainBalanceSat;
    final totalOnChainBalanceSat = await wallet.totalOnChainBalanceSat;

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
