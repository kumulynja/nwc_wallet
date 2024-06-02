import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/constants/database_params.dart';
import 'package:nwc_wallet/enums/nwc_method_enum.dart';

@immutable
class NwcRequestModel extends Equatable {
  final int? id; // Add an id field for primary key in SQLite
  final int connectionId;
  final NwcMethod method;
  final int createdAt;
  final int updatedAt;

  const NwcRequestModel({
    this.id,
    required this.connectionId,
    required this.method,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert a NwcRequestModel into a Map.
  Map<String, dynamic> toMap() {
    var map = <String, Object?>{
      DatabaseParams.columnConnectionId: connectionId,
      DatabaseParams.columnMethod: method.plaintext,
      DatabaseParams.columnCreatedAt: createdAt,
      DatabaseParams.columnUpdatedAt: updatedAt,
    };

    // Include id only if it is not null
    // This ensures id is included for updates but omitted for inserts
    if (id != null) {
      map[DatabaseParams.columnId] = id;
    }

    return map;
  }

  // Convert a Map into a NwcRequestModel.
  factory NwcRequestModel.fromMap(Map<String, dynamic> map) {
    return NwcRequestModel(
      id: map[DatabaseParams.columnId],
      connectionId: map[DatabaseParams.columnConnectionId],
      method: NwcMethodX.fromPlaintext(map[DatabaseParams.columnMethod]),
      createdAt: map[DatabaseParams.columnCreatedAt],
      updatedAt: map[DatabaseParams.columnUpdatedAt],
    );
  }

  @override
  String toString() {
    return 'NwcRequestModel{'
        '${DatabaseParams.columnId}: $id, '
        '${DatabaseParams.columnConnectionId}: $connectionId, '
        '${DatabaseParams.columnMethod}: ${method.plaintext}, '
        '${DatabaseParams.columnCreatedAt}: $createdAt, '
        '${DatabaseParams.columnUpdatedAt}: $updatedAt}';
  }

  @override
  List<Object?> get props => [id, connectionId, method, createdAt, updatedAt];
}
