import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/data/models/nostr_client_message.dart';
import 'package:nwc_wallet/data/models/nostr_relay_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

abstract class NostrRelayProvider {
  Stream<NostrRelayMessage> get messages;
  Future<void> connect();
  void sendMessage(NostrClientMessage message);
  Future<void> disconnect();
  Future<void> dispose();
}

class NostrRelayProviderImpl implements NostrRelayProvider {
  final String _relayUrl;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final StreamController<NostrRelayMessage> _messageController =
      StreamController.broadcast();

  NostrRelayProviderImpl(
    this._relayUrl,
  );

  @override
  Stream<NostrRelayMessage> get messages => _messageController.stream;

  @override
  Future<void> connect() async {
    final wsUrl = Uri.parse(_relayUrl);
    _channel = WebSocketChannel.connect(wsUrl);
    await _channel?.ready;

    _subscription = _channel?.stream.listen((data) {
      final message = NostrRelayMessage.fromSerialized(data);
      _messageController.add(message);
    }, onError: (error) {
      _messageController.addError(error);
    }, onDone: () {
      // Todo: Make custom error for this
      _messageController.addError('Connection lost');
    });
  }

  @override
  void sendMessage(NostrClientMessage message) {
    final serializedMessage = message.serialized;
    debugPrint('Sending message: $serializedMessage');
    _channel?.sink.add(serializedMessage);
  }

  @override
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await _messageController.close();
  }
}
