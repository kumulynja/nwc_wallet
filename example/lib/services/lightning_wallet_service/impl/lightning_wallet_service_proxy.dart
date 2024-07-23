import 'dart:convert';

import 'package:example/entities/foreground_receive_data.dart';
import 'package:example/entities/payment_details_entity.dart';
import 'package:example/services/lightning_wallet_service/lightning_wallet_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nwc_wallet/enums/bitcoin_network.dart';

class LightningWalletServiceProxy implements LightningWalletService {
  LightningWalletServiceProxy();

  @override
  Future<void> init() async {}

  @override
  Future<void> addWallet() async {
    print('Adding wallet from proxy');
  }

  @override
  bool get hasWallet {
    FlutterForegroundTask.sendDataToTask(jsonEncode(const HasWallet().toMap()));
    return false;
  }

  @override
  String get alias {
    // Todo: get it from the foreground service
    return '';
  }

  @override
  String get color {
    // Todo: get it from the foreground service
    return '';
  }

  @override
  Future<String> get nodeId async {
    // Todo: get it from the foreground service
    return '';
  }

  @override
  BitcoinNetwork get network {
    // Todo: get it from the foreground service
    return BitcoinNetwork.signet;
  }

  @override
  Future<int> get blockHeight async {
    return 0;
  }

  @override
  Future<String> get blockHash async {
    return '';
  }

  @override
  Future<void> deleteWallet() async {}

  @override
  Future<void> sync() async {}

  @override
  Future<int> get spendableBalanceSat async {
    return 0;
  }

  @override
  Future<int> get inboundLiquiditySat async {
    return 0;
  }

  @override
  Future<(String?, String?)> generateInvoices({
    int? amountSat,
    int? expirySecs, // Default to 1 day
    String? description,
  }) async {
    return (null, null);
  }

  @override
  Future<int> get totalOnChainBalanceSat async {
    return 0;
  }

  @override
  Future<int> get spendableOnChainBalanceSat async {
    return 0;
  }

  @override
  Future<String> drainOnChainFunds(String address) async {
    return '';
  }

  @override
  Future<String> sendOnChainFunds(String address, int amountSat) async {
    return '';
  }

  @override
  Future<void> openChannel({
    required String host,
    required int port,
    required String nodeId,
    required int channelAmountSat,
    bool announceChannel = false,
  }) async {}

  @override
  Future<String> pay(
    String invoice, {
    int? amountSat,
    double? satPerVbyte, // Not used in Lightning
    int? absoluteFeeSat, // Not used in Lightning
  }) async {
    return '';
  }

  @override
  Future<List<PaymentDetailsEntity>> getTransactions() async {
    return [];
  }

  @override
  Future<PaymentDetailsEntity?> getTransactionById(String id) async {
    return null;
  }
}
