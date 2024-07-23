import 'dart:convert';

import 'package:example/entities/foreground_receive_data.dart';
import 'package:example/enums/foreground_method.dart';
import 'package:example/repositories/mnemonic_repository.dart';
import 'package:example/services/lightning_wallet_service/impl/ldk_node_lightning_wallet_service.dart';
import 'package:example/services/lightning_wallet_service/lightning_wallet_service.dart';
import 'package:example/services/nwc_wallet_service/nwc_wallet_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundTaskHandler extends TaskHandler {
  late NwcWalletService _nwcWalletService;
  late LightningWalletService _lightningWalletService;

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp) async {
    print('onStart');

    final mnemonicRepository = SecureStorageMnemonicRepository();
    // Instantiate the wallet service in the main so
    // we can have one service instance for the entire app...
    _lightningWalletService = LdkNodeLightningWalletService(
      mnemonicRepository: mnemonicRepository,
    );
    // ...and have it initialized before the app starts.
    await _lightningWalletService.init();

    // Create and init an NwcWalletService instance here as well
    _nwcWalletService = NwcWalletServiceImpl(
      lightningWalletService: _lightningWalletService,
      mnemonicRepository: mnemonicRepository,
    );
    await _nwcWalletService.init();
  }

  // Called when data is sent using [FlutterForegroundTask.sendData].
  @override
  void onReceiveData(Object data) async {
    print('onReceiveData: $data');

    // Data to Map
    final dataMap = jsonDecode(data as String) as Map<String, dynamic>;
    final receiveData = ForegroundReceiveData.fromMap(dataMap);

    // Handle requests for the nwc and wallet service here.
    switch (receiveData.method) {
      case ForegroundMethod.hasWallet:
        final hasWallet = _lightningWalletService.hasWallet;
        print('hasWallet: $hasWallet');
        break;
    }
    print('DATA RECEIVED: $dataMap');
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
    await _nwcWalletService.dispose();
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
