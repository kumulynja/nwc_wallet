import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:nwc_wallet_app/constants/firestore_collections.dart';

abstract class WalletTokenRepository {
  Future<void> registerTokenForWallet({
    required String walletServicePublicKey,
  });
}

class FirestoreWalletTokenRepository implements WalletTokenRepository {
  FirestoreWalletTokenRepository(
      {required firestore, required firebaseMessaging})
      : _firestore = firestore,
        _firebaseMessaging = firebaseMessaging;

  final FirebaseFirestore _firestore;
  final FirebaseMessaging _firebaseMessaging;

  @override
  Future<void> registerTokenForWallet({
    required String walletServicePublicKey,
  }) async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    String? token;
    if (Platform.isIOS) {
      token = await _firebaseMessaging.getAPNSToken();
    } else {
      token = await _firebaseMessaging.getToken();
    }

    debugPrint('------>>>>>> Token: $token');

    if (token == null) {
      return;
    }

    await _saveWalletWithToken(walletServicePublicKey, token);

    // Start listening for token refreshes too
    _firebaseMessaging.onTokenRefresh.listen((String? newToken) async {
      if (newToken != null) {
        await _saveWalletWithToken(walletServicePublicKey, newToken);
      }
    });
  }

  Future<void> _saveWalletWithToken(String id, String token) async {
    final docRef =
        _firestore.collection(FirestoreCollections.walletTokens).doc(id);
    await docRef.set(<String, dynamic>{
      'token': token,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
