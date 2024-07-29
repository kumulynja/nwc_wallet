import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/enums/nwc_method.dart';

@immutable
class NwcConnection extends Equatable {
  final String pubkey;
  final List<NwcMethod> permittedMethods;
  final String? uri;

  const NwcConnection({
    required this.pubkey,
    required this.permittedMethods,
    this.uri,
  });

  factory NwcConnection.fromMap(Map<String, dynamic> map) {
    return NwcConnection(
      pubkey: map['pubkey'] as String,
      permittedMethods: (map['permittedMethods'] as List)
          .map((e) => NwcMethod.fromPlaintext(e as String))
          .toList(),
      uri: map['uri'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pubkey': pubkey,
      'permittedMethods': permittedMethods.map((e) => e.plaintext).toList(),
      'uri': uri,
    };
  }

  @override
  List<Object?> get props => [
        pubkey,
        permittedMethods,
        uri,
      ];
}
