import 'dart:async';
import 'dart:convert';

import 'package:nwc_wallet_app/entities/foreground_task_request.dart';
import 'package:nwc_wallet_app/entities/foreground_task_response.dart';
import 'package:nwc_wallet_app/entities/nwc_connection_entity.dart';
import 'package:nwc_wallet_app/entities/payment_details_entity.dart';
import 'package:nwc_wallet_app/services/lightning_wallet_service/lightning_wallet_service.dart';
import 'package:nwc_wallet_app/services/nwc_wallet_service/nwc_wallet_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nwc_wallet/nwc_wallet.dart';

class ForegroundTaskServicesProxy
    implements LightningWalletService, NwcWalletService {
  final _completers = <String, Completer<dynamic>>{};

  ForegroundTaskServicesProxy() {
    FlutterForegroundTask.addTaskDataCallback(_handleForegroundTaskResponse);
  }

  @override
  Future<void> init() async {
    const request = InitRequest();
    await _sendRequestToForegroundTask(request);
  }

  @override
  Future<NwcConnection> addConnection({
    required String name,
    required List<NwcMethod> permittedMethods,
  }) async {
    final request = AddConnectionRequest(
      name: name,
      permittedMethods: permittedMethods,
    );
    final result = await _sendRequestToForegroundTask(request);
    final response = result as AddConnectionResponse;
    return response.connection;
  }

  @override
  Future<List<NwcConnectionEntity>> getSavedConnections() {
    return Future.value([]); // Todo: get stored connections from repository
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> addWallet() async {
    const request = AddWalletRequest();
    await _sendRequestToForegroundTask(request);
  }

  @override
  Future<bool> get hasWallet async {
    const request = HasWalletRequest();
    final result = await _sendRequestToForegroundTask(request);
    final response = result as HasWalletResponse;
    return response.hasWallet;
  }

  @override
  Future<String> get alias async {
    const request = AliasRequest();
    final result = await _sendRequestToForegroundTask(request);
    final response = result as AliasResponse;
    return response.alias;
  }

  @override
  Future<String> get color async {
    const request = ColorRequest();
    final result = await _sendRequestToForegroundTask(request);
    final response = result as ColorResponse;
    return response.color;
  }

  @override
  Future<String> get nodeId async {
    const request = NodeIdRequest();
    final result = await _sendRequestToForegroundTask(request);
    final response = result as NodeIdResponse;
    return response.nodeId;
  }

  @override
  Future<BitcoinNetwork> get network async {
    const request = NetworkRequest();
    final result = await _sendRequestToForegroundTask(request);
    final response = result as NetworkResponse;
    return response.network;
  }

  @override
  Future<int> get blockHeight async {
    const request = BlockHeightRequest();
    final result = await _sendRequestToForegroundTask(request);
    final response = result as BlockHeightResponse;
    return response.blockHeight;
  }

  @override
  Future<String> get blockHash async {
    const request = BlockHashRequest();
    final result = await _sendRequestToForegroundTask(request);
    final response = result as BlockHashResponse;
    return response.blockHash;
  }

  @override
  Future<void> deleteWallet() async {
    const request = DeleteWalletRequest();
    await _sendRequestToForegroundTask(request);
  }

  @override
  Future<void> sync() async {
    const request = SyncRequest();
    await _sendRequestToForegroundTask(request);
  }

  @override
  Future<int> get spendableBalanceSat async {
    const request = SpendableBalanceSatRequest();
    final result = await _sendRequestToForegroundTask(request);
    final response = result as SpendableBalanceSatResponse;
    return response.spendableBalanceSat;
  }

  @override
  Future<int> get inboundLiquiditySat async {
    const request = InboundLiquiditySatRequest();
    final result = await _sendRequestToForegroundTask(request);
    final response = result as InboundLiquiditySatResponse;
    return response.inboundLiquiditySat;
  }

  @override
  Future<(String?, String?)> generateInvoices({
    int? amountSat,
    int? expirySecs, // Default to 1 day
    String? description,
  }) async {
    final request = GenerateInvoicesRequest(
      amountSat: amountSat,
      expirySecs: expirySecs,
      description: description,
    );
    final result = await _sendRequestToForegroundTask(request);
    final response = result as GenerateInvoicesResponse;
    return (response.bitcoinInvoice, response.lightningInvoice);
  }

  @override
  Future<int> get totalOnChainBalanceSat async {
    const request = TotalOnChainBalanceSatRequest();
    final result = await _sendRequestToForegroundTask(request);
    final response = result as TotalOnChainBalanceSatResponse;
    return response.totalOnChainBalanceSat;
  }

  @override
  Future<int> get spendableOnChainBalanceSat async {
    const request = SpendableOnChainBalanceSatRequest();
    final result = await _sendRequestToForegroundTask(request);
    final response = result as SpendableOnChainBalanceSatResponse;
    return response.spendableOnChainBalanceSat;
  }

  @override
  Future<String> drainOnChainFunds(String address) async {
    final request = DrainOnChainFundsRequest(address: address);
    final result = await _sendRequestToForegroundTask(request);
    final response = result as DrainOnChainFundsResponse;
    return response.txid;
  }

  @override
  Future<String> sendOnChainFunds(String address, int amountSat) async {
    final request = SendOnChainFundsRequest(
      address: address,
      amountSat: amountSat,
    );
    final result = await _sendRequestToForegroundTask(request);
    final response = result as SendOnChainFundsResponse;
    return response.txid;
  }

  @override
  Future<void> openChannel({
    required String host,
    required int port,
    required String nodeId,
    required int channelAmountSat,
    bool announceChannel = false,
  }) async {
    final request = OpenChannelRequest(
      host: host,
      port: port,
      nodeId: nodeId,
      channelAmountSat: channelAmountSat,
      announceChannel: announceChannel,
    );
    await _sendRequestToForegroundTask(request);
  }

  @override
  Future<String> pay(
    String invoice, {
    int? amountSat,
    double? satPerVbyte, // Not used in Lightning
    int? absoluteFeeSat, // Not used in Lightning
  }) async {
    final request = PayRequest(
      invoice,
      amountSat: amountSat,
    );
    final result = await _sendRequestToForegroundTask(request);
    final response = result as PayResponse;
    return response.id;
  }

  @override
  Future<List<PaymentDetailsEntity>> getTransactions() async {
    const request = GetTransactionsRequest();
    final result = await _sendRequestToForegroundTask(request);
    final response = result as GetTransactionsResponse;
    return response.transactions;
  }

  @override
  Future<PaymentDetailsEntity?> getTransactionById(String id) async {
    final request = GetTransactionByIdRequest(id);
    final result = await _sendRequestToForegroundTask(request);
    final response = result as GetTransactionByIdResponse;
    return response.transaction;
  }

  void _handleForegroundTaskResponse(dynamic data) {
    final dataMap = jsonDecode(data) as Map<String, dynamic>;
    final response = ForegroundTaskResponse.fromMap(dataMap);

    final completer = _completers[response.method.plaintext];
    if (completer != null) {
      completer.complete(response);
      _completers.remove(response.method.plaintext);
    }
  }

  Future<ForegroundTaskResponse> _sendRequestToForegroundTask(
    ForegroundTaskRequest request, {
    int timeoutSec = 60,
  }) async {
    final completer = Completer<ForegroundTaskResponse>();
    _completers[request.method.plaintext] = completer;
    FlutterForegroundTask.sendDataToTask(jsonEncode(request.toMap()));
    return completer.future.timeout(
      Duration(seconds: timeoutSec),
      onTimeout: () {
        _completers.remove(request.method.plaintext);
        throw TimeoutException('Timeout waiting for response');
      },
    );
  }
}
