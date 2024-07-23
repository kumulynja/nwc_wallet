import 'dart:async';

import 'package:example/repositories/mnemonic_repository.dart';
import 'package:example/services/nwc_wallet_foreground_service.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:nwc_wallet/nwc_wallet.dart';

// The callback function should always be a top-level function.
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(ForegroundTaskHandler());
}

class ForegroundTaskHandler extends TaskHandler {
  NwcWalletForegroundService nwcWalletForegroundService =
      NwcWalletForegroundServiceImpl(
    mnemonicRepository: SecureStorageMnemonicRepository(),
  );
  StreamSubscription<NwcRequest>? _nwcRequestSubscription;

  // Called when the task is started.
  @override
  void onStart(DateTime timestamp) async {
    print('onStart');

    await nwcWalletForegroundService.init();
    _nwcRequestSubscription =
        nwcWalletForegroundService.nwcRequests.listen((NwcRequest request) {
      print('NwcRequest: $request');
      FlutterForegroundTask.sendDataToMain(request.toMap());
    });
  }

  // Called every [interval] milliseconds in [ForegroundTaskOptions].
  @override
  void onRepeatEvent(DateTime timestamp) async {
    // Send data to the main isolate.
    final Map<String, dynamic> data = {
      "timestampMillis": timestamp.millisecondsSinceEpoch,
    };
    FlutterForegroundTask.sendDataToMain(data);

    // Todo: You could sync the wallet here or any other data and send NWC notifications (once that proposal is accepted).
  }

  // Called when the task is destroyed.
  @override
  void onDestroy(DateTime timestamp) async {
    // Clean up resources.
    print('onDestroy');
    await _nwcRequestSubscription?.cancel();
    await nwcWalletForegroundService.dispose();
  }

  // Called when data is sent using [FlutterForegroundTask.sendData].
  @override
  void onReceiveData(Object data) {
    print('onReceiveData: $data');

    // Handle requests for the nwc and wallet service here.
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
