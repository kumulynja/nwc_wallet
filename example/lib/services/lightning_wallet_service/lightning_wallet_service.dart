import 'dart:async';
import 'package:example/entities/payment_details_entity.dart';
import 'package:nwc_wallet/nwc_wallet.dart';

abstract class LightningWalletService {
  bool get hasWallet;
  String get alias;
  String get color;
  Future<String> get nodeId;
  BitcoinNetwork get network;
  Future<int> get blockHeight;
  Future<String> get blockHash;
  Future<void> init();
  Future<void> addWallet();
  Future<void> deleteWallet();
  Future<void> sync();
  Future<int> get spendableBalanceSat;
  Future<int> get inboundLiquiditySat;
  Future<int> get totalOnChainBalanceSat;
  Future<int> get spendableOnChainBalanceSat;
  Future<String> drainOnChainFunds(String address);
  Future<String> sendOnChainFunds(String address, int amountSat);
  Future<void> openChannel({
    required String host,
    required int port,
    required String nodeId,
    required int channelAmountSat,
    bool announceChannel = false,
  });
  Future<(String? bitcoinInvoice, String? lightningInvoice)> generateInvoices({
    int? amountSat,
    int? expirySecs,
    String? description,
  });
  Future<List<PaymentDetailsEntity>> getTransactions();
  Future<PaymentDetailsEntity?> getTransactionById(String id);
  Future<String> pay(
    String invoice, {
    int? amountSat,
    double? satPerVbyte,
    int? absoluteFeeSat,
  });
}

class NoWalletException implements Exception {
  final String message;

  NoWalletException(this.message);
}
