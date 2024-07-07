import 'package:example/features/home/home_screen.dart';
import 'package:example/repositories/mnemonic_repository.dart';
import 'package:example/services/lightning_wallet_service.dart';
import 'package:example/services/nwc_wallet_service.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final mnemonicRepository = SecureStorageMnemonicRepository();
  // Instantiate the wallet service in the main so
  // we can have one service instance for the entire app...
  final ldkNodeLightningWalletService = LdkNodeLightningWalletService(
    mnemonicRepository: mnemonicRepository,
  );
  // ...and have it initialized before the app starts.
  await ldkNodeLightningWalletService.init();

  // Create and init an NwcWalletService instance here as well
  final nwcWalletService = NwcWalletServiceImpl(
    lightningWalletService: ldkNodeLightningWalletService,
    mnemonicRepository: mnemonicRepository,
  );
  await nwcWalletService.init();

  runApp(MyApp(
    ldkNodeLightningWalletService: ldkNodeLightningWalletService,
    nwcWalletService: nwcWalletService,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.ldkNodeLightningWalletService,
    required this.nwcWalletService,
    super.key,
  });

  final LdkNodeLightningWalletService ldkNodeLightningWalletService;
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
        walletService: ldkNodeLightningWalletService,
        nwcWalletService: nwcWalletService,
      ),
    );
  }
}
