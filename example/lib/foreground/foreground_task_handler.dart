import 'dart:convert';

import 'package:nwc_wallet_app/entities/foreground_task_request.dart';
import 'package:nwc_wallet_app/entities/foreground_task_response.dart';
import 'package:nwc_wallet_app/enums/foreground_method.dart';
import 'package:nwc_wallet_app/repositories/mnemonic_repository.dart';
import 'package:nwc_wallet_app/services/lightning_wallet_service/impl/ldk_node_lightning_wallet_service.dart';
import 'package:nwc_wallet_app/services/lightning_wallet_service/lightning_wallet_service.dart';
import 'package:nwc_wallet_app/services/nwc_wallet_service/nwc_wallet_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundTaskHandler extends TaskHandler {
  final _mnemonicRepository = SecureStorageMnemonicRepository();
  late NwcWalletService _nwcWalletService;
  late LightningWalletService _lightningWalletService;
  int _nrOfConnections = 0;

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp) async {
    print('onStart');
  }

  // Called when data is sent using [FlutterForegroundTask.sendData].
  @override
  void onReceiveData(Object data) async {
    print('onReceiveData: $data');

    // Data to Map
    final dataMap = jsonDecode(data as String) as Map<String, dynamic>;
    final receiveData = ForegroundTaskRequest.fromMap(dataMap);

    // Handle requests for the nwc and wallet service here.
    switch (receiveData.method) {
      case ForegroundMethod.init:
        // Instantiate the wallet service in the main so
        // we can have one service instance for the entire app...
        _lightningWalletService = LdkNodeLightningWalletService(
          mnemonicRepository: _mnemonicRepository,
        );

        // Create and init an NwcWalletService instance here as well
        _nwcWalletService = NwcWalletServiceImpl(
          lightningWalletService: _lightningWalletService,
          mnemonicRepository: _mnemonicRepository,
        );

        await _lightningWalletService.init();
        await _nwcWalletService.init();
        final response = ForegroundTaskResponse.initResponse();
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.addConnection:
        final request = receiveData as AddConnectionRequest;
        final connection = await _nwcWalletService.addConnection(
          name: request.name,
          permittedMethods: request.permittedMethods,
        );
        FlutterForegroundTask.updateService(
          notificationText: '${++_nrOfConnections} active connections',
        );
        final response = ForegroundTaskResponse.addConnectionResponse(
          connection: connection,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.addWallet:
        await _lightningWalletService.addWallet();
        await _nwcWalletService.init();
        final response = ForegroundTaskResponse.addWalletResponse();
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.hasWallet:
        final hasWallet = _lightningWalletService.hasWallet;
        final response = ForegroundTaskResponse.hasWalletResponse(
          hasWallet: await hasWallet,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.alias:
        final alias = _lightningWalletService.alias;
        final response = ForegroundTaskResponse.aliasResponse(
          alias: await alias,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.color:
        final color = _lightningWalletService.color;
        final response = ForegroundTaskResponse.colorResponse(
          color: await color,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.nodeId:
        final nodeId = _lightningWalletService.nodeId;
        final response = ForegroundTaskResponse.nodeIdResponse(
          nodeId: await nodeId,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.network:
        final network = _lightningWalletService.network;
        final response = ForegroundTaskResponse.networkResponse(
          network: await network,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.blockHeight:
        final blockHeight = _lightningWalletService.blockHeight;
        final response = ForegroundTaskResponse.blockHeightResponse(
          blockHeight: await blockHeight,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.blockHash:
        final blockHash = _lightningWalletService.blockHash;
        final response = ForegroundTaskResponse.blockHashResponse(
          blockHash: await blockHash,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.deleteWallet:
        await _lightningWalletService.deleteWallet();
        final response = ForegroundTaskResponse.deleteWalletResponse();
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.sync:
        await _lightningWalletService.sync();
        final response = ForegroundTaskResponse.syncResponse();
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.spendableBalanceSat:
        final spendableBalanceSat = _lightningWalletService.spendableBalanceSat;
        final response = ForegroundTaskResponse.spendableBalanceSatResponse(
          spendableBalanceSat: await spendableBalanceSat,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.inboundLiquiditySat:
        final inboundLiquiditySat = _lightningWalletService.inboundLiquiditySat;
        final response = ForegroundTaskResponse.inboundLiquiditySatResponse(
          inboundLiquiditySat: await inboundLiquiditySat,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.totalOnChainBalanceSat:
        final totalOnChainBalanceSat =
            _lightningWalletService.totalOnChainBalanceSat;
        final response = ForegroundTaskResponse.totalOnChainBalanceSatResponse(
          totalOnChainBalanceSat: await totalOnChainBalanceSat,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.spendableOnChainBalanceSat:
        final spendableOnChainBalanceSat =
            _lightningWalletService.spendableOnChainBalanceSat;
        final response =
            ForegroundTaskResponse.spendableOnChainBalanceSatResponse(
          spendableOnChainBalanceSat: await spendableOnChainBalanceSat,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.drainOnChainFunds:
        final request = receiveData as DrainOnChainFundsRequest;
        final drainOnChainFunds =
            _lightningWalletService.drainOnChainFunds(request.address);
        final response = ForegroundTaskResponse.drainOnChainFundsResponse(
          txid: await drainOnChainFunds,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.sendOnChainFunds:
        final request = receiveData as SendOnChainFundsRequest;
        final sendOnChainFunds = _lightningWalletService.sendOnChainFunds(
          request.address,
          request.amountSat,
        );
        final response = ForegroundTaskResponse.sendOnChainFundsResponse(
          txid: await sendOnChainFunds,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.openChannel:
        final request = receiveData as OpenChannelRequest;
        await _lightningWalletService.openChannel(
          host: request.host,
          port: request.port,
          nodeId: request.nodeId,
          channelAmountSat: request.channelAmountSat,
          announceChannel: request.announceChannel,
        );
        final response = ForegroundTaskResponse.openChannelResponse();
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.pay:
        final request = receiveData as PayRequest;
        final id = await _lightningWalletService.pay(
          request.invoice,
          amountSat: request.amountSat,
          satPerVbyte: request.satPerVbyte,
          absoluteFeeSat: request.absoluteFeeSat,
        );
        final response = ForegroundTaskResponse.payResponse(id: id);
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.generateInvoices:
        final request = receiveData as GenerateInvoicesRequest;
        final (bitcoinInvoice, lightningInvoice) =
            await _lightningWalletService.generateInvoices(
          amountSat: request.amountSat,
          expirySecs: request.expirySecs,
          description: request.description,
        );
        final response = ForegroundTaskResponse.generateInvoicesResponse(
          bitcoinInvoice: bitcoinInvoice,
          lightningInvoice: lightningInvoice,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.getTransactions:
        final transactions = await _lightningWalletService.getTransactions();
        final response = ForegroundTaskResponse.getTransactionsResponse(
          transactions: transactions,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
      case ForegroundMethod.getTransactionById:
        final request = receiveData as GetTransactionByIdRequest;
        final transaction =
            await _lightningWalletService.getTransactionById(request.id);
        final response = ForegroundTaskResponse.getTransactionByIdResponse(
          transaction: transaction,
        );
        FlutterForegroundTask.sendDataToMain(jsonEncode(response.toMap()));
    }
    print('DATA PROCESSED: $dataMap');
  }

  // Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp) async {
    // Todo: You could sync the wallet here or any other data and send NWC notifications to main
    //  (once that proposal is accepted).
  }

  // Called when the task is destroyed.
  @override
  void onDestroy(DateTime timestamp) async {
    // Clean up resources.
    print('onDestroy');
  }

  // Called when the notification button on the Android platform is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    print('onNotificationButtonPressed >> $id');
  }

  // Called when the notification itself on the Android platform is pressed.
  //
  // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
  // this function to be called.
  @override
  void onNotificationPressed() {
    super.onNotificationPressed();
    print('onNotificationPressed');
  }

  // Called when the notification itself on the Android platform is dismissed
  // on Android 14 which allow this behaviour.
  @override
  void onNotificationDismissed() {
    print('onNotificationDismissed');
  }
}
