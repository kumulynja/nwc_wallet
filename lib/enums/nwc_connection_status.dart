enum NwcConnectionStatus {
  connecting,
  connected,
  disconnecting,
  disconnected,
}

extension NwcConnectionStatusX on NwcConnectionStatus {
  static NwcConnectionStatus fromName(String name) {
    switch (name) {
      case 'connecting':
        return NwcConnectionStatus.connecting;
      case 'connected':
        return NwcConnectionStatus.connected;
      case 'disconnecting':
        return NwcConnectionStatus.disconnecting;
      case 'disconnected':
        return NwcConnectionStatus.disconnected;
      default:
        throw Exception('Unknown NWC connection status: $name');
    }
  }
}
