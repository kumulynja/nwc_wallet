class DatabaseParams {
  static const String databaseName = 'nwc_wallet.db';
  static const int databaseVersion = 1;
  static const String nwcConnectionsTable = 'nwc_connections';
  static const String nwcRequestsTable = 'nwc_requests';
  static const String columnId = '_id';
  static const String columnName = 'name';
  static const String columnRelayUrl = 'relayUrl';
  static const String columnPermittedMethods = 'permittedMethods';
  static const String columnSecret = 'secret';
  static const String columnMonthlyLimitSat = 'monthlyLimitSat';
  static const String columnExpiry = 'expiry';
  static const String columnConnectionStatus = 'connectionStatus';
  static const String columnIsDeactivated = 'isDeactivated';
  static const String columnCreatedAt = 'createdAt';
  static const String columnUpdatedAt = 'updatedAt';
  static const String columnDeactivatedAt = 'deactivatedAt';
}
