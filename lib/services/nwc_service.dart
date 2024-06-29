import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/constants/nostr_constants.dart';
import 'package:nwc_wallet/data/models/nostr_event.dart';
import 'package:nwc_wallet/data/models/nostr_filters.dart';
import 'package:nwc_wallet/data/models/nostr_key_pair.dart';
import 'package:nwc_wallet/data/models/nwc_connection.dart';
import 'package:nwc_wallet/data/models/nwc_info_event.dart';
import 'package:nwc_wallet/data/models/nwc_request.dart';
import 'package:nwc_wallet/data/repositories/nostr_repository.dart';
import 'package:nwc_wallet/enums/nostr_event_kind.dart';
import 'package:nwc_wallet/enums/nwc_error_code.dart';
import 'package:nwc_wallet/enums/nwc_method.dart';
import 'package:nwc_wallet/nips/nip04.dart';
import 'package:nwc_wallet/utils/secret_generator.dart';

abstract class NwcService {
  Stream<NwcRequest> get nwcRequests;
  List<NwcConnection> get connections;
  void connect();
  void disconnect();
  Future<String> addConnection({
    required String name,
    required String relayUrl,
    required List<NwcMethod> permittedMethods,
  });
}

class NwcServiceImpl implements NwcService {
  final NostrKeyPair _walletNostrKeyPair;
  final NostrRepository _nostrRepository;
  final Map<String, NwcConnection> _connections = {};
  final String _subscriptionId = SecretGenerator.secretHex(64);
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
    // Request events for the wallet
    _nostrRepository.requestEvents(_subscriptionId, [
      NostrFilters.nwcRequests(
        walletPublicKey: _walletNostrKeyPair.publicKey,
        since: DateTime.now().millisecondsSinceEpoch ~/
            1000, // Todo: get last event timestamp if missed events are desired
      )
    ]);
  }

  @override
  Future<String> addConnection({
    required String name,
    required String relayUrl,
    required List<NwcMethod> permittedMethods,
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

    // Save the connection in memory (user of the package should persist it)
    _connections[connectionKeyPair.publicKey] = NwcConnection(
      name: name,
      connectionPubkey: connectionKeyPair.publicKey,
      permittedMethods: permittedMethods,
    );

    // Return the connection URI so the user can share it with apps to connect
    //  its wallet.
    return _buildConnectionUri(connectionKeyPair.privateKey, relayUrl);
  }

  @override
  List<NwcConnection> get connections => _connections.values.toList();

  @override
  void disconnect() {
    // Todo: CLOSE subscription to events
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
      // The wallet should only process NIP-47 request events
      return;
    }

    for (var tag in event.tags) {
      if (tag[0] == 'expiration') {
        final expirationTimestamp = int.tryParse(tag[1]);
        if (expirationTimestamp != null &&
            DateTime.now().millisecondsSinceEpoch ~/ 1000 >
                expirationTimestamp) {
          return; // Ignore expired requests
        }
      }
    }

    NwcRequest request;
    try {
      request = _extractRequest(event);
    } catch (e) {
      if (e is InternalException) {
      } else if (e is NotImplementedException) {}
      return;
    }

    // Check if the request is for a connection that the wallet has
    final connection = _connections[event.pubkey];
    if (connection == null) {
      // The wallet should only handle requests from connections it has
      // Todo: send Unauthorized error response, UnauthorizedException('Connection not found');
      return;
    }

    // Check if the request is for a method that the connection has
    if (!connection.permittedMethods.contains(request.method)) {
      // The wallet should only handle permitted methods
      // Todo: Send Restricted error response, RestrictedException('Not permitted method');
      return;
    }

    _requestController.add(request);
  }

  NwcRequest _extractRequest(
    NostrEvent event,
  ) {
    String decryptedContent;

    try {
      // Try to decrypt the content with the nip04 standard
      decryptedContent = Nip04.decrypt(
        event.content,
        _walletNostrKeyPair.privateKey,
        event.pubkey,
      );
      debugPrint('Decrypted content: $decryptedContent');
    } catch (e) {
      throw InternalException('Failed to decrypt content: $e');
    }

    try {
      return NwcRequest.fromDecryptedEventContent(jsonDecode(decryptedContent));
    } catch (e) {
      throw NotImplementedException('Error parsing request: $e');
    }
  }
}

class InternalException implements Exception {
  final String message;

  InternalException(this.message);

  @override
  String toString() => 'InternalException: $message';
}

class NotImplementedException implements Exception {
  final String message;

  NotImplementedException(this.message);

  @override
  String toString() => 'NotImplementedException: $message';
}
