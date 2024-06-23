import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/constants/database_params.dart';
import 'package:nwc_wallet/enums/nwc_connection_status.dart';
import 'package:nwc_wallet/enums/nwc_method_enum.dart';

@immutable
class NwcConnectionModel extends Equatable {
  final int? id; // Add an id field for primary key in SQLite
  final String name;
  final String connectionPubkey;
  final String relayUrl;
  final List<NwcMethod> permittedMethods;
  final int? monthlyLimitSat;
  final int? expiry;
  final NwcConnectionStatus connectionStatus;
  final bool? isDeactivated;
  final int createdAt;
  final int updatedAt;
  final int? deactivatedAt;

  const NwcConnectionModel({
    this.id,
    required this.name,
    required this.connectionPubkey,
    required this.relayUrl,
    required this.permittedMethods,
    this.monthlyLimitSat,
    this.expiry,
    this.connectionStatus = NwcConnectionStatus.disconnected,
    this.isDeactivated,
    required this.createdAt,
    required this.updatedAt,
    this.deactivatedAt,
  });

  NwcConnectionModel copyWith({
    int? id,
    String? name,
    String? connectionPubkey,
    String? relayUrl,
    List<NwcMethod>? permittedMethods,
    int? monthlyLimitSat,
    int? expiry,
    NwcConnectionStatus? connectionStatus,
    bool? isDeactivated,
    int? createdAt,
    int? updatedAt,
    int? deactivatedAt,
  }) {
    return NwcConnectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      connectionPubkey: connectionPubkey ?? this.connectionPubkey,
      relayUrl: relayUrl ?? this.relayUrl,
      permittedMethods: permittedMethods ?? this.permittedMethods,
      monthlyLimitSat: monthlyLimitSat ?? this.monthlyLimitSat,
      expiry: expiry ?? this.expiry,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      isDeactivated: isDeactivated ?? this.isDeactivated,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deactivatedAt: deactivatedAt ?? this.deactivatedAt,
    );
  }

  // Convert a NwcConnectionModel into a Map.
  Map<String, dynamic> toMap() {
    var map = <String, Object?>{
      DatabaseParams.columnName: name,
      DatabaseParams.columnConnectionPubkey: connectionPubkey,
      DatabaseParams.columnRelayUrl: relayUrl,
      DatabaseParams.columnPermittedMethods: permittedMethods
          .map((m) => m.plaintext)
          .toList()
          .join(','), // Serialize list to comma-separated string
      DatabaseParams.columnMonthlyLimitSat: monthlyLimitSat,
      DatabaseParams.columnExpiry: expiry,
      DatabaseParams.columnConnectionStatus: connectionStatus.name,
      DatabaseParams.columnIsDeactivated: isDeactivated == true ? 1 : 0,
      DatabaseParams.columnCreatedAt: createdAt,
      DatabaseParams.columnUpdatedAt: updatedAt,
      DatabaseParams.columnDeactivatedAt: deactivatedAt,
    };

    // Include id only if it is not null
    // This ensures id is included for updates but omitted for inserts
    if (id != null) {
      map[DatabaseParams.columnId] = id;
    }
    return map;
  }

  // Convert a Map into a NwcConnectionModel.
  factory NwcConnectionModel.fromMap(Map<String, dynamic> map) {
    return NwcConnectionModel(
      id: map[DatabaseParams.columnId],
      name: map[DatabaseParams.columnName],
      connectionPubkey: map[DatabaseParams.columnConnectionPubkey],
      relayUrl: map[DatabaseParams.columnRelayUrl],
      permittedMethods: (map[DatabaseParams.columnPermittedMethods] as String)
          .split(',')
          .map(
            (method) => NwcMethod.fromPlaintext(method),
          ) // Deserialize string to list
          .toList(), // Deserialize string to list
      monthlyLimitSat: map[DatabaseParams.columnMonthlyLimitSat],
      expiry: map[DatabaseParams.columnExpiry],
      connectionStatus: NwcConnectionStatus.fromValue(
        map[DatabaseParams.columnConnectionStatus],
      ),
      isDeactivated: map[DatabaseParams.columnIsDeactivated] == 1,
      createdAt: map[DatabaseParams.columnCreatedAt],
      updatedAt: map[DatabaseParams.columnUpdatedAt],
      deactivatedAt: map[DatabaseParams.columnDeactivatedAt],
    );
  }

  @override
  String toString() {
    return 'NwcConnectionModel{'
        '${DatabaseParams.columnId}: $id,'
        '${DatabaseParams.columnName}: $name,'
        '${DatabaseParams.columnConnectionPubkey}: $connectionPubkey,'
        '${DatabaseParams.columnRelayUrl}: $relayUrl,'
        '${DatabaseParams.columnPermittedMethods}: ${permittedMethods.map((m) => m.plaintext).toList()},'
        '${DatabaseParams.columnMonthlyLimitSat}: $monthlyLimitSat,'
        '${DatabaseParams.columnExpiry}: $expiry,'
        '${DatabaseParams.columnConnectionStatus}: $connectionStatus,'
        '${DatabaseParams.columnIsDeactivated}: $isDeactivated,'
        '${DatabaseParams.columnCreatedAt}: $createdAt,'
        '${DatabaseParams.columnUpdatedAt}: $updatedAt,'
        '${DatabaseParams.columnDeactivatedAt}: $deactivatedAt}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        connectionPubkey,
        relayUrl,
        permittedMethods,
        monthlyLimitSat,
        expiry,
        connectionStatus,
        isDeactivated,
        createdAt,
        updatedAt,
        deactivatedAt,
      ];
}
