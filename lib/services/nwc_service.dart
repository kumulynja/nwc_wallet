import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/constants/nostr_constants.dart';
import 'package:nwc_wallet/data/models/nostr_event.dart';
import 'package:nwc_wallet/data/models/nostr_filters.dart';
import 'package:nwc_wallet/data/models/nostr_key_pair.dart';
import 'package:nwc_wallet/data/models/nwc_connection.dart';
import 'package:nwc_wallet/data/models/nwc_info_event.dart';
import 'package:nwc_wallet/data/models/nwc_request.dart';
import 'package:nwc_wallet/data/models/nwc_response.dart';
import 'package:nwc_wallet/data/repositories/nostr_repository.dart';
import 'package:nwc_wallet/enums/nostr_event_kind.dart';
import 'package:nwc_wallet/enums/nwc_error_code.dart';
import 'package:nwc_wallet/enums/nwc_method.dart';
import 'package:nwc_wallet/utils/secret_generator.dart';

abstract class NwcService {
  List<NwcConnection> get connections;
  Stream<NwcRequest> get nwcRequests;
  void connect();
  Future<String> addConnection({
    required String name,
    required String relayUrl,
    required List<NwcMethod> permittedMethods,
  });
  void removeConnection(String pubkey);
  Future<void> handleResponse({
    required NwcResponse response,
    required NwcRequest request,
  });
  Future<void> disconnect();
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
      _connections[connection.pubkey] = connection;
    }
  }

  @override
  List<NwcConnection> get connections => _connections.values.toList();

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
    final signedEvent = nwcInfo.toSignedNostrEvent(
      creatorKeyPair: _walletNostrKeyPair,
      connectionPubkey: connectionKeyPair.publicKey,
      relayUrl: relayUrl,
    );

    final isPublished = await _nostrRepository.publishEvent(signedEvent);
    if (!isPublished) {
      throw Exception('Failed to publish event');
    }

    // Save the connection in memory (user of the package should persist it)
    _connections[connectionKeyPair.publicKey] = NwcConnection(
      name: name,
      pubkey: connectionKeyPair.publicKey,
      permittedMethods: permittedMethods,
    );

    // Return the connection URI so the user can share it with apps to connect
    //  its wallet.
    return _buildConnectionUri(connectionKeyPair.privateKey, relayUrl);
  }

  @override
  void removeConnection(String pubkey) {
    _connections.remove(pubkey);
  }

  @override
  Future<void> handleResponse({
    required NwcResponse response,
    required NwcRequest request,
  }) async {
    await _sendResponseForRequest(response: response, request: request);
  }

  @override
  Future<void> disconnect() async {
    final isSubscriptionClosed =
        await _nostrRepository.closeSubscription(_subscriptionId);
    if (!isSubscriptionClosed) {
      throw Exception('Failed to close subscription');
    }
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
    try {
      if (event.kind != NostrEventKind.nip47Request) {
        // The wallet should only process NIP-47 request event kinds
        return;
      }

      if (_isExpired(event)) return;

      NwcRequest request = NwcRequest.fromEvent(
        event,
        _walletNostrKeyPair.privateKey,
      );

      final errorResponse = validateRequest(request);

      if (errorResponse != null) {
        await _sendResponseForRequest(
          response: errorResponse,
          request: request,
        );
        return;
      }

      _requestController.add(request);
    } catch (e) {
      debugPrint('Error handling event: $e');
      return;
    }
  }

  bool _isExpired(NostrEvent event) {
    for (var tag in event.tags) {
      if (tag[0] == 'expiration') {
        final expirationTimestamp = int.tryParse(tag[1]);
        if (expirationTimestamp != null &&
            DateTime.now().millisecondsSinceEpoch ~/ 1000 >
                expirationTimestamp) {
          return true;
        }
      }
    }
    return false;
  }

  NwcErrorResponse? validateRequest(NwcRequest request) {
    // 1. First make sure the request is a known request
    if (request is NwcUnknownRequest) {
      // NotImplemented error response
      return NwcResponse.nwcErrorResponse(
        method: NwcMethod.unknown,
        error: NwcErrorCode.notImplemented,
        unknownMethod: request.unknownMethod,
      ) as NwcErrorResponse;
    }

    // 2. Check if the known request is coming from a trusted connection
    final connection = _connections[request.connectionPubkey];
    if (connection == null) {
      // Unauthorized error response
      return NwcResponse.nwcErrorResponse(
        method: request.method,
        error: NwcErrorCode.unauthorized,
      ) as NwcErrorResponse;
    }

    // 3. Check if the requested method is permitted for the known connection
    if (!connection.permittedMethods.contains(request.method)) {
      // Restricted error response
      return NwcResponse.nwcErrorResponse(
        method: request.method,
        error: NwcErrorCode.restricted,
      ) as NwcErrorResponse;
    }

    return null; // Request is valid
  }

  Future<void> _sendResponseForRequest({
    required NwcResponse response,
    required NwcRequest request,
  }) async {
    final signedResponseEvent = response.toSignedNostrEvent(
      creatorKeyPair: _walletNostrKeyPair,
      requestId: request.id,
      connectionPubkey: request.connectionPubkey,
    );
    final isPublished =
        await _nostrRepository.publishEvent(signedResponseEvent);

    if (!isPublished) {
      // Todo: use better logging and/or add a retry mechanism
      debugPrint(
        'Failed to publish response: $signedResponseEvent for request: $request',
      );
      throw Exception('Failed to publish response');
    }
  }
}
