import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nwc_wallet_app/repositories/connection_repository.dart';
import 'package:nwc_wallet_app/repositories/last_seen_request_timestamp_repository.dart';
import 'package:nwc_wallet_app/repositories/mnemonic_repository.dart';
import 'package:nwc_wallet_app/services/lightning_wallet_service/impl/ldk_node_lightning_wallet_service.dart';
import 'package:nwc_wallet_app/services/nwc_wallet_service/nwc_wallet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");

  final mnemonicRepository = SecureStorageMnemonicRepository();
  // Start the node as soon as possible
  final lightningWalletService = LdkNodeLightningWalletService(
    mnemonicRepository: mnemonicRepository,
  );
  await lightningWalletService.init();

  // Now start NWC wallet service
  final connectionRepository = SecureStorageConnectionRepository();
  final lastSeenRequestTimestampRepository =
      SharedPreferencesLastSeenRequestTimestampRepository(
    sharedPreferences: await SharedPreferences.getInstance(),
  );
  final nwcWalletService = NwcWalletServiceImpl(
    lightningWalletService: lightningWalletService,
    mnemonicRepository: mnemonicRepository,
    connectionRepository: connectionRepository,
    lastSeenRequestTimestampRepository: lastSeenRequestTimestampRepository,
  );
  await nwcWalletService.init();
}
