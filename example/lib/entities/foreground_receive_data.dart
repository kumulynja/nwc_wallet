import 'package:equatable/equatable.dart';
import 'package:example/enums/foreground_method.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ForegroundReceiveData extends Equatable {
  final ForegroundMethod method;

  const ForegroundReceiveData({
    required this.method,
  });

  const factory ForegroundReceiveData.hasWallet() = HasWallet;

  factory ForegroundReceiveData.fromMap(Map<String, dynamic> map) {
    final ForegroundMethod method =
        ForegroundMethod.fromPlaintext(map['method']);
    switch (method) {
      case ForegroundMethod.hasWallet:
        return const HasWallet();
      default:
        throw Exception('Unknown method: $method');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'method': method.plaintext,
    };
  }

  @override
  List<Object?> get props => [method];
}

class HasWallet extends ForegroundReceiveData {
  const HasWallet() : super(method: ForegroundMethod.hasWallet);
}
