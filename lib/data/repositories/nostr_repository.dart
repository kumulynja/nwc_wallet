import 'package:nwc_wallet/data/models/nostr_client_message.dart';
import 'package:nwc_wallet/data/models/nostr_event.dart';
import 'package:nwc_wallet/data/models/nostr_filters.dart';
import 'package:nwc_wallet/data/models/nostr_relay_message.dart';
import 'package:nwc_wallet/data/providers/nostr_relay_provider.dart';

class NostrRepository {
  final NostrRelayProvider relayProvider;

  NostrRepository(this.relayProvider) {
    relayProvider.messages.listen(_handleRelayMessage);
  }

  void connect() {
    relayProvider.connect();
  }

  void disconnect() {
    relayProvider.disconnect();
  }

  void publishEvent(NostrEvent event) {
    final message = ClientEventMessage(event: event);
    relayProvider.sendMessage(message);
  }

  void requestEvents(String subscriptionId, List<NostrFilters> filters) {
    final message =
        ClientRequestMessage(subscriptionId: subscriptionId, filters: filters);
    relayProvider.sendMessage(message);
  }

  void closeSubscription(String subscriptionId) {
    final message = ClientCloseMessage(subscriptionId: subscriptionId);
    relayProvider.sendMessage(message);
  }

  void _handleRelayMessage(NostrRelayMessage message) {
    if (message is RelayEventMessage) {
      // Handle event message
      print('Received event: ${message.event.content}');
    } else if (message is RelayNoticeMessage) {
      // Handle notice message
      print('Received notice: ${message.message}');
    } else if (message is RelayEndOfStreamMessage) {
      // Handle end of stream message
      print('End of stored events for subscription: ${message.subscriptionId}');
    } else if (message is RelayClosedMessage) {
      // Handle closed message
      print(
          'Subscription closed: ${message.subscriptionId} with message: ${message.message}');
    } else if (message is RelayOkMessage) {
      // Handle OK message
      print(
          'OK message: Event ${message.eventId} accepted: ${message.accepted}, message: ${message.message}');
    }
  }
}
