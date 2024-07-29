import 'package:nwc_wallet_app/features/home/home_screen.dart';
import 'package:nwc_wallet_app/foreground/foreground_task_services_proxy.dart';
import 'package:nwc_wallet_app/services/lightning_wallet_service/lightning_wallet_service.dart';
import 'package:nwc_wallet_app/services/nwc_wallet_service/nwc_wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize port for communication between TaskHandler and UI.
  FlutterForegroundTask.initCommunicationPort();

  // Instantiate proxy services for the lightning wallet and nwc wallet
  //  that run in the foreground task
  final foregroundProxy = ForegroundTaskServicesProxy();

  runApp(MyApp(
    lightningWalletService: foregroundProxy,
    nwcWalletService: foregroundProxy,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.lightningWalletService,
    required this.nwcWalletService,
    super.key,
  });

  final LightningWalletService lightningWalletService;
  final NwcWalletService nwcWalletService;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NWC Wallet Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(
        walletService: lightningWalletService,
        nwcWalletService: nwcWalletService,
      ),
    );
  }
}
