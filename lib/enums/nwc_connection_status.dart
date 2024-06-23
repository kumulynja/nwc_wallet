enum NwcConnectionStatus {
  connecting('connecting'),
  connected('connected'),
  disconnecting('disconnecting'),
  disconnected('disconnected');

  final String value;

  const NwcConnectionStatus(this.value);

  factory NwcConnectionStatus.fromValue(String value) {
    switch (value) {
      case 'connecting':
        return NwcConnectionStatus.connecting;
      case 'connected':
        return NwcConnectionStatus.connected;
      case 'disconnecting':
        return NwcConnectionStatus.disconnecting;
      case 'disconnected':
        return NwcConnectionStatus.disconnected;
      default:
        throw ArgumentError('Invalid connection status value: $value');
    }
  }
}
