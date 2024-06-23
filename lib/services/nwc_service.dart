import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/constants/nostr_constants.dart';
import 'package:nwc_wallet/data/models/nostr_event.dart';
import 'package:nwc_wallet/data/models/nostr_key_pair.dart';
import 'package:nwc_wallet/data/models/nwc_connection.dart';
import 'package:nwc_wallet/data/models/nwc_info_event.dart';
import 'package:nwc_wallet/data/models/nwc_request.dart';
import 'package:nwc_wallet/data/repositories/nostr_repository.dart';
import 'package:nwc_wallet/enums/nostr_event_kind_enum.dart';
import 'package:nwc_wallet/enums/nwc_method_enum.dart';

abstract class NwcService {
  Stream<NwcRequest> get nwcRequests;
  void connect();
  void disconnect();
  Future<String> addConnection({
    required String name,
    required String relayUrl,
    required List<NwcMethod> permittedMethods,
    int? monthlyLimitSat,
    int? expiry,
  });
}

class NwcServiceImpl implements NwcService {
  final NostrKeyPair _walletNostrKeyPair;
  final NostrRepository _nostrRepository;
  final Map<String, NwcConnection> _connections = {};
  final StreamController<NwcRequest> _requestController =
      StreamController.broadcast();

  NwcServiceImpl(
    this._walletNostrKeyPair,
    this._nostrRepository,
    List<NwcConnection> connections,
  ) {
    for (final connection in connections) {
      _connections[connection.connectionPubkey] = connection;
    }
  }

  @override
  Stream<NwcRequest> get nwcRequests => _requestController.stream;

  @override
  void connect() {
    _nostrRepository.connect();
    _nostrRepository.events.listen(_handleEvent);
    // Todo: Subscribe to all existing connections' events
  }

  @override
  Future<String> addConnection({
    required String name,
    required String relayUrl,
    required List<NwcMethod> permittedMethods,
    int? monthlyLimitSat,
    int? expiry,
  }) async {
    final connectionKeyPair = NostrKeyPair.generate();

    // Push permitted methods to relay with get info event
    final nwcInfo = NwcInfoEvent(permittedMethods: permittedMethods);
    final partialEvent = nwcInfo.toUnsignedNostrEvent(
      creatorPubkey: _walletNostrKeyPair.publicKey,
      connectionPubkey: connectionKeyPair.publicKey,
      relayUrl: relayUrl,
    );
    final signedEvent = partialEvent.copyWith(
      sig: _walletNostrKeyPair.sign(partialEvent.id!),
    );

    final isPublished = await _nostrRepository.publishEvent(signedEvent);
    if (!isPublished) {
      throw Exception('Failed to publish event');
    }

    // Todo: Subscribe to the connection's events

    // Save the connection in memory (user of the package should persist it)
    final connection = NwcConnection(
      name: name,
      connectionPubkey: connectionKeyPair.publicKey,
      relayUrl: relayUrl,
      permittedMethods: permittedMethods,
      monthlyLimitSat: monthlyLimitSat,
      expiry: expiry,
    );
    _connections[connectionKeyPair.publicKey] = connection;

    // Return the connection URI so the user can share it with apps to connect
    //  its wallet.
    return _buildConnectionUri(connectionKeyPair.privateKey, relayUrl);
  }

  @override
  void disconnect() {
    _nostrRepository.disconnect();
    _requestController.close();
  }

  String _buildConnectionUri(String secret, String relayUrl) {
    return '${NostrConstants.uriProtocol}://'
        '${_walletNostrKeyPair.publicKey}?'
        'secret=$secret&'
        'relay=$relayUrl';
  }

  void _handleEvent(NostrEvent event) async {
    if (event.kind != NostrEventKind.nip47Request) {
      // The wallet should only handle NIP-47 requests
      return;
    }

    try {
      // Todo: decrypt event content
      final decryptedContent = ''; // from event.content
      final request =
          NwcRequest.fromDecryptedEventContent(jsonDecode(decryptedContent));

      _requestController.add(request);
    } catch (e) {
      debugPrint('Error handling event: $e');
    }
  }
}
