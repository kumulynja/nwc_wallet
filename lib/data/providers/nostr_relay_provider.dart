import 'dart:async';

import 'package:nwc_wallet/data/models/nostr_client_message.dart';
import 'package:nwc_wallet/data/models/nostr_relay_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

abstract class NostrRelayProvider {
  void connect();
  void disconnect();
  void sendMessage(NostrClientMessage message);
  Stream<NostrRelayMessage> get messages;
}

class NostrRelayProviderImpl implements NostrRelayProvider {
  final String relayUrl;
  WebSocketChannel? _channel;
  final StreamController<NostrRelayMessage> _messageController =
      StreamController.broadcast();

  NostrRelayProviderImpl(this.relayUrl);

  @override
  Stream<NostrRelayMessage> get messages => _messageController.stream;

  @override
  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(relayUrl));
    _channel?.stream.listen((data) {
      final message = NostrRelayMessage.fromSerialized(data);
      _messageController.add(message);
    }, onError: (error) {
      _messageController.addError(error);
    }, onDone: () {
      _messageController.close();
    });
  }

  @override
  void disconnect() {
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  @override
  void sendMessage(NostrClientMessage message) {
    final serializedMessage = message.serialized;
    _channel?.sink.add(serializedMessage);
  }
}
