import 'dart:async';
import 'dart:convert';

import 'package:nwc_wallet/constants/nostr_constants.dart';
import 'package:nwc_wallet/data/models/nostr_event.dart';
import 'package:nwc_wallet/data/models/nostr_key_pair.dart';
import 'package:nwc_wallet/data/models/nwc_request.dart';
import 'package:nwc_wallet/data/repositories/nostr_repository.dart';
import 'package:nwc_wallet/data/repositories/nwc_connection_repository.dart';
import 'package:nwc_wallet/enums/nostr_event_kind_enum.dart';
import 'package:nwc_wallet/enums/nwc_method_enum.dart';

abstract class NwcService {
  Stream<NwcRequest> get nwcRequests;
  void connect();
  void disconnect();
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
  Future<void> addConnection(
    String name,
    List<NwcMethod> permittedMethods,
    int monthlyLimit,
    int expiry,
  ) async {
    final connectionSecret = '';
    final connectionPublicKey = '';

    final uri =
        '${NostrConstants.uriProtocol}://${_walletNostrKeyPair.publicKey}?secret=${connectionSecret}&relay=${_nostrRepository};
  
    // Push permitted methods to relay with get info event

    // store connection in local database
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
