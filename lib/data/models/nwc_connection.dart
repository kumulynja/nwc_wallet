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

  @override
  List<Object?> get props => [
        pubkey,
        permittedMethods,
        uri,
      ];
}
