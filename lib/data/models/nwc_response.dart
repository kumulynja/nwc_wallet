import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/enums/bitcoin_network.dart';
import 'package:nwc_wallet/enums/nwc_error_code.dart';
import 'package:nwc_wallet/enums/nwc_method.dart';
import 'package:nwc_wallet/enums/transaction_type.dart';

@immutable
abstract class NwcResponse extends Equatable {
  final NwcMethod resultType;
  final NwcErrorCode? error;
  final Map<String, dynamic>? result;

  const NwcResponse(this.resultType, this.error, this.result);

  factory NwcResponse.nwcGetInfoResponse({
    required String alias,
    required String color,
    required String pubkey,
    required BitcoinNetwork network,
    required int blockHeight,
    required String blockHash,
    required List<NwcMethod> methods,
    NwcErrorCode? error,
  }) = NwcGetInfoResponse;
  factory NwcResponse.nwcGetBalanceResponse({
    required int balanceSat,
    NwcErrorCode? error,
  }) = NwcGetBalanceResponse;
  factory NwcResponse.nwcMakeInvoiceResponse({
    String? invoice,
    String? description,
    String? descriptionHash,
    String? preimage,
    required String paymentHash,
    required int amountSat,
    required int feesPaidSat,
    required int createdAt,
    required int expiresAt,
    required Map<dynamic, dynamic> metadata,
    NwcErrorCode? error,
  }) = NwcMakeInvoiceResponse;

  @override
  List<Object?> get props => [resultType, error, result];
}

// Subclass for the get_info response
@immutable
class NwcGetInfoResponse extends NwcResponse {
  final String alias;
  final String color;
  final String pubkey;
  final BitcoinNetwork network;
  final int blockHeight;
  final String blockHash;
  final List<NwcMethod> methods;

  NwcGetInfoResponse({
    required this.alias,
    required this.color,
    required this.pubkey,
    required this.network,
    required this.blockHeight,
    required this.blockHash,
    required this.methods,
    NwcErrorCode? error,
  }) : super(NwcMethod.getInfo, error, {
          'alias': alias,
          'color': color,
          'pubkey': pubkey,
          'network': network.name,
          'blockHeight': blockHeight,
          'blockHash': blockHash,
          'methods': methods.map((method) => method.plaintext).toList(),
        });

  @override
  List<Object?> get props => [
        resultType,
        error,
        alias,
        color,
        pubkey,
        network,
        blockHeight,
        blockHash,
        methods,
      ];
}

// Subclass for the get_balance response
@immutable
class NwcGetBalanceResponse extends NwcResponse {
  final int balanceSat;

  NwcGetBalanceResponse({
    required this.balanceSat,
    NwcErrorCode? error,
  }) : super(NwcMethod.getBalance, error, {
          'balance': balanceSat * 1000, // user's balance in msats
        });

  @override
  List<Object?> get props => [resultType, error, balanceSat];
}

// Subclass for the make_invoice response
@immutable
class NwcMakeInvoiceResponse extends NwcResponse {
  final String? invoice;
  final String? description;
  final String? descriptionHash;
  final String? preimage;
  final String paymentHash;
  final int amountSat;
  final int feesPaidSat;
  final int createdAt;
  final int expiresAt;
  final Map<dynamic, dynamic> metadata;

  NwcMakeInvoiceResponse({
    this.invoice,
    this.description,
    this.descriptionHash,
    this.preimage,
    required this.paymentHash,
    required this.amountSat,
    required this.feesPaidSat,
    required this.createdAt,
    required this.expiresAt,
    required this.metadata,
    NwcErrorCode? error,
  }) : super(NwcMethod.makeInvoice, error, {
          'type': TransactionType.incoming.name,
          if (invoice != null) 'invoice': invoice,
          if (description != null) 'description': description,
          if (descriptionHash != null) 'descriptionHash': descriptionHash,
          if (preimage != null) 'preimage': preimage,
          'paymentHash': paymentHash,
          'amount': amountSat,
          'feesPaid': feesPaidSat,
          'createdAt': createdAt,
          'expiresAt': expiresAt,
          'metadata': metadata,
        });

  @override
  List<Object?> get props => [resultType, error, invoice];
}
