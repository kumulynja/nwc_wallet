import 'package:example/constants/app_sizes.dart';
import 'package:example/features/home/home_controller.dart';
import 'package:example/features/home/home_state.dart';
import 'package:example/features/nwc/connections/nwc_connections_bottom_sheet.dart';
import 'package:example/services/lightning_wallet_service.dart';
import 'package:example/services/nwc_wallet_service.dart';
import 'package:example/widgets/reserved_amounts/reserved_amounts_list.dart';
import 'package:example/widgets/transactions/transactions_list.dart';
import 'package:example/widgets/wallets/wallet_cards_list.dart';
import 'package:example/features/wallet_actions/wallet_actions_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.walletService,
    required this.nwcWalletService,
    super.key,
  });

  final LightningWalletService walletService;
  final NwcWalletService nwcWalletService;

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
      walletService: widget.walletService,
      nwcWalletService: widget.nwcWalletService,
    );
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(),
      drawer: SafeArea(
        bottom: false,
        maintainBottomViewPadding: true,
        child: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: ListTile(
                  leading: Image.asset(
                    'assets/logos/nwc.png',
                    height: 48,
                  ),
                  title: Text(
                    'Nostr Wallet Connect',
                    style: TextStyle(
                        fontSize: 24,
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.apps),
                title: const Text('App connections'),
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => NwcConnectionsBottomSheet(
                    nwcWalletService: widget.nwcWalletService,
                  ),
                ),
              ),
              const ListTile(
                leading: Icon(Icons.request_page),
                title: Text('Payment requests'),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _controller.refresh();
        },
        child: ListView(
          children: [
            SizedBox(
              height: AppSizes.kSpacingUnit * 24,
              child: WalletCardsList(
                _state.walletBalance != null ? [_state.walletBalance!] : [],
                onAddNewWallet: _controller.addNewWallet,
                onDeleteWallet: _controller.deleteWallet,
              ),
            ),
            ReservedAmountsList(
              reservedAmounts: _state.reservedAmountsList,
              walletService: widget.walletService,
            ),
            TransactionsList(
              transactions: _state.transactionList,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => WalletActionsBottomSheet(
            walletService: widget.walletService,
          ),
        ),
        child: SvgPicture.asset(
          'assets/icons/in_out_arrows.svg',
        ),
      ),
    );
  }
}

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Image.asset('assets/logos/nwc.png'),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
