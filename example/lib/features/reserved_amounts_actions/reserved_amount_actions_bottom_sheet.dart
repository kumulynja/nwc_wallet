import 'package:nwc_wallet_app/constants/app_sizes.dart';
import 'package:nwc_wallet_app/features/reserved_amounts_actions/open_channel/open_channel_tab.dart';
import 'package:nwc_wallet_app/services/lightning_wallet_service/lightning_wallet_service.dart';
import 'package:flutter/material.dart';

class ReservedAmountActionsBottomSheet extends StatelessWidget {
  const ReservedAmountActionsBottomSheet({
    required LightningWalletService walletService,
    super.key,
  }) : _walletService = walletService;

  final LightningWalletService _walletService;

  static const List<Tab> actionTabs = <Tab>[
    Tab(
      icon: Icon(Icons.flash_on),
      text: 'Instant Spending',
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
              OpenChannelTab(walletService: _walletService),
            ],
          ),
        ),
      ),
    );
  }
}
