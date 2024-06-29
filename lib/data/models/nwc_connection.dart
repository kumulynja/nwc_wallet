import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/enums/nwc_method.dart';

@immutable
class NwcConnection extends Equatable {
  final String name;
  final String connectionPubkey;
  final List<NwcMethod> permittedMethods;

  const NwcConnection({
    required this.name,
    required this.connectionPubkey,
    required this.permittedMethods,
  });

  @override
  List<Object?> get props => [
        name,
        connectionPubkey,
        permittedMethods,
      ];
}
