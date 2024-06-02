import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/constants/database_params.dart';
import 'package:nwc_wallet/enums/nwc_method_enum.dart';

@immutable
class NwcConnectionModel extends Equatable {
  final int? id; // Add an id field for primary key in SQLite
  final String name;
  final String relayUrl;
  final List<NwcMethod> permittedMethods;
  final String secret;
  final int? monthlyLimitSat;
  final int? expiry;
  final bool? isDeactivated;
  final int createdAt;
  final int updatedAt;
  final int? deactivatedAt;

  const NwcConnectionModel({
    this.id,
    required this.name,
    required this.relayUrl,
    required this.permittedMethods,
    required this.secret,
    this.monthlyLimitSat,
    this.expiry,
    this.isDeactivated,
    required this.createdAt,
    required this.updatedAt,
    this.deactivatedAt,
  });

  NwcConnectionModel copyWith({
    int? id,
    String? name,
    String? relayUrl,
    List<NwcMethod>? permittedMethods,
    String? secret,
    int? monthlyLimitSat,
    int? expiry,
    bool? isDeactivated,
    int? createdAt,
    int? updatedAt,
    int? deactivatedAt,
  }) {
    return NwcConnectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      relayUrl: relayUrl ?? this.relayUrl,
      permittedMethods: permittedMethods ?? this.permittedMethods,
      secret: secret ?? this.secret,
      monthlyLimitSat: monthlyLimitSat ?? this.monthlyLimitSat,
      expiry: expiry ?? this.expiry,
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
      DatabaseParams.columnRelayUrl: relayUrl,
      DatabaseParams.columnPermittedMethods: permittedMethods
          .map((m) => m.plaintext)
          .toList()
          .join(','), // Serialize list to comma-separated string
      DatabaseParams.columnSecret: secret,
      DatabaseParams.columnMonthlyLimitSat: monthlyLimitSat,
      DatabaseParams.columnExpiry: expiry,
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
      relayUrl: map[DatabaseParams.columnRelayUrl],
      permittedMethods: (map[DatabaseParams.columnPermittedMethods] as String)
          .split(',')
          .map(
            (method) => NwcMethodX.fromPlaintext(method),
          ) // Deserialize string to list
          .toList(), // Deserialize string to list
      secret: map[DatabaseParams.columnSecret],
      monthlyLimitSat: map[DatabaseParams.columnMonthlyLimitSat],
      expiry: map[DatabaseParams.columnExpiry],
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
        '${DatabaseParams.columnRelayUrl}: $relayUrl,'
        '${DatabaseParams.columnPermittedMethods}: ${permittedMethods.map((m) => m.plaintext).toList()},'
        '${DatabaseParams.columnSecret}: $secret,'
        '${DatabaseParams.columnMonthlyLimitSat}: $monthlyLimitSat,'
        '${DatabaseParams.columnExpiry}: $expiry,'
        '${DatabaseParams.columnIsDeactivated}: $isDeactivated,'
        '${DatabaseParams.columnCreatedAt}: $createdAt,'
        '${DatabaseParams.columnUpdatedAt}: $updatedAt,'
        '${DatabaseParams.columnDeactivatedAt}: $deactivatedAt}';
  }

  @override
  List<Object?> get props => [
        id,
        name,
        relayUrl,
        permittedMethods,
        secret,
        monthlyLimitSat,
        expiry,
        isDeactivated,
        createdAt,
        updatedAt,
        deactivatedAt,
      ];
}
