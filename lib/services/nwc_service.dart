import 'dart:async';
import 'dart:convert';

import 'package:nwc_wallet/constants/nostr_constants.dart';
import 'package:nwc_wallet/data/models/nostr_event.dart';
import 'package:nwc_wallet/data/models/nostr_key_pair.dart';
import 'package:nwc_wallet/data/models/nwc_info_event.dart';
import 'package:nwc_wallet/data/models/nwc_request.dart';
import 'package:nwc_wallet/data/repositories/nostr_repository.dart';
import 'package:nwc_wallet/data/repositories/nwc_connection_repository.dart';
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
  final NostrRepository _nostrRepository;
  final NwcConnectionRepository _connectionRepository;
  final NostrKeyPair _walletNostrKeyPair;
  final StreamController<NwcRequest> _requestController =
      StreamController.broadcast();

  NwcServiceImpl(
    this._walletNostrKeyPair,
    this._nostrRepository,
    this._connectionRepository,
  );

  @override
  Stream<NwcRequest> get nwcRequests => _requestController.stream;

  @override
  void connect() {
    _nostrRepository.connect();
    _nostrRepository.events.listen(_handleEvent);
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

    final uri = '${NostrConstants.uriProtocol}://'
        '${_walletNostrKeyPair.publicKey}?'
        'secret=${connectionKeyPair.privateKey}&'
        'relay=$relayUrl';

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
    // Listen to the relay to know when the event is acknowledged
    // Todo: Add timeout
    // Todo: use a completer
    final okMessagesSubscription =
        _nostrRepository.okMessages.listen((okMessage) {
      if (okMessage.eventId == signedEvent.id) {
        // The relay has acknowledged the published event
      }
    });

    _nostrRepository.publishEvent(signedEvent);

    // store connection in local database
    await _connectionRepository.addConnection(
      name: name,
      connectionPubkey: connectionKeyPair.publicKey,
      relayUrl: relayUrl,
      permittedMethods: permittedMethods,
      monthlyLimitSat: monthlyLimitSat,
      expiry: expiry,
    );

    return uri;
  }

  @override
  void disconnect() {
    _nostrRepository.disconnect();
    _requestController.close();
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
      print('Error handling event: $e');
    }
  }
}
