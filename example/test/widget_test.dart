// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nwc_wallet_app/repositories/connection_repository.dart';
import 'package:nwc_wallet_app/repositories/mnemonic_repository.dart';
import 'package:nwc_wallet_app/repositories/wallet_token_repository.dart';
import 'package:nwc_wallet_app/services/lightning_wallet_service/impl/ldk_node_lightning_wallet_service.dart';
import 'package:nwc_wallet_app/services/nwc_wallet_service/nwc_wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nwc_wallet_app/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    final mnemonicRepository = SecureStorageMnemonicRepository();
    final pushTokenRepository = FirestoreWalletTokenRepository(
      firestore: FirebaseFirestore.instance,
      firebaseMessaging: FirebaseMessaging.instance,
    );
    final connectionRepository = SecureStorageConnectionRepository();
    final ldkNodeLightningWalletService = LdkNodeLightningWalletService(
      mnemonicRepository: mnemonicRepository,
    );
    await ldkNodeLightningWalletService.init();
    final nwcWalletService = NwcWalletServiceImpl(
      lightningWalletService: ldkNodeLightningWalletService,
      mnemonicRepository: mnemonicRepository,
      connectionRepository: connectionRepository,
      pushTokenRepository: pushTokenRepository,
    );
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      lightningWalletService: ldkNodeLightningWalletService,
      nwcWalletService: nwcWalletService,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
