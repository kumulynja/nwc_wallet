import 'package:nwc_wallet_app/constants/app_sizes.dart';
import 'package:nwc_wallet_app/features/wallet_actions/receive/receive_tab.dart';
import 'package:nwc_wallet_app/features/wallet_actions/send/send_tab.dart';
import 'package:nwc_wallet_app/services/lightning_wallet_service/lightning_wallet_service.dart';
import 'package:flutter/material.dart';

class WalletActionsBottomSheet extends StatelessWidget {
  const WalletActionsBottomSheet({
    required LightningWalletService walletService,
    super.key,
  }) : _walletService = walletService;

  final LightningWalletService _walletService;

  static const List<Tab> actionTabs = <Tab>[
    Tab(
      icon: Icon(Icons.arrow_downward),
      text: 'Receive funds',
    ),
    Tab(
      icon: Icon(Icons.arrow_upward),
      text: 'Send funds',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: actionTabs.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: const [
            CloseButton(),
          ],
          bottom: const TabBar(
            tabs: actionTabs,
          ),
        ),
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.all(AppSizes.kSpacingUnit * 4),
          child: TabBarView(
            children: [
              ReceiveTab(
                walletService: _walletService,
              ),
              SendTab(
                walletService: _walletService,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
