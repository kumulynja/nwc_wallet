import 'package:example/constants/app_sizes.dart';
import 'package:example/features/home/home_controller.dart';
import 'package:example/features/home/home_state.dart';
import 'package:example/services/lightning_wallet_service.dart';
import 'package:example/widgets/reserved_amounts/reserved_amounts_list.dart';
import 'package:example/widgets/transactions/transactions_list.dart';
import 'package:example/widgets/wallets/wallet_cards_list.dart';
import 'package:example/features/wallet_actions/wallet_actions_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.walletServices,
    super.key,
  });

  final List<LightningWalletService> walletServices;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  HomeState _state = const HomeState();
  late HomeController _controller;

  @override
  void initState() {
    super.initState();

    _controller = HomeController(
      getState: () => _state,
      updateState: (HomeState state) => setState(() => _state = state),
      walletServices: widget.walletServices,
    );
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      endDrawer: const Drawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _controller.refresh();
        },
        child: ListView(
          children: [
            SizedBox(
              height: AppSizes.kSpacingUnit * 24,
              child: WalletCardsList(
                _state.walletBalances,
                onAddNewWallet: _controller.addNewWallet,
                onDeleteWallet: _controller.deleteWallet,
                onSelectWallet: _controller.selectWallet,
                selectedWalletIndex: _state.walletIndex,
              ),
            ),
            ReservedAmountsList(
              reservedAmounts: _state.reservedAmountsLists.isNotEmpty
                  ? _state.reservedAmountsLists[_state.walletIndex]
                  : null,
              walletService: widget.walletServices[_state.walletIndex],
            ),
            TransactionsList(
              transactions: _state.transactionLists.isNotEmpty
                  ? _state.transactionLists[_state.walletIndex]
                  : null,
              lightningNodeImplementation:
                  _state.selectedLightningNodeImplementation,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => WalletActionsBottomSheet(
            walletServices: widget.walletServices,
          ),
        ),
        child: SvgPicture.asset(
          'assets/icons/in_out_arrows.svg',
        ),
      ),
    );
  }
}
