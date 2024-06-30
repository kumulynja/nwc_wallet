import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/data/models/nostr_event.dart';
import 'package:nwc_wallet/data/models/nostr_key_pair.dart';
import 'package:nwc_wallet/data/models/transaction.dart';
import 'package:nwc_wallet/enums/bitcoin_network.dart';
import 'package:nwc_wallet/enums/nostr_event_kind.dart';
import 'package:nwc_wallet/enums/nwc_error_code.dart';
import 'package:nwc_wallet/enums/nwc_method.dart';
import 'package:nwc_wallet/enums/transaction_type.dart';
import 'package:nwc_wallet/nips/nip04.dart';

@immutable
abstract class NwcResponse extends Equatable {
  final String resultType;
  final NwcErrorCode? error;
  final Map<String, dynamic>? result;

  const NwcResponse({
    required this.resultType,
    this.error,
    this.result,
  });

  factory NwcResponse.nwcGetInfoResponse({
    required String alias,
    required String color,
    required String pubkey,
    required BitcoinNetwork network,
    required int blockHeight,
    required String blockHash,
    required List<NwcMethod> methods,
  }) = NwcGetInfoResponse;

  factory NwcResponse.nwcGetBalanceResponse({
    required int balanceSat,
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
  }) = NwcMakeInvoiceResponse;

  factory NwcResponse.nwcPayInvoiceResponse({
    required String preimage,
  }) = NwcPayInvoiceResponse;

  factory NwcResponse.nwcMultiPayInvoiceResponse({
    required String preimage,
  }) = NwcMultiPayInvoiceResponse;

  factory NwcResponse.nwcPayKeysend({
    required String preimage,
  }) = NwcPayKeysend;

  factory NwcResponse.nwcLookupInvoiceResponse({
    String? invoice,
    String? description,
    String? descriptionHash,
    String? preimage,
    required String paymentHash,
    required int amountSat,
    required int feesPaidSat,
    required int createdAt,
    required int expiresAt,
    required int settledAt,
    required Map<dynamic, dynamic> metadata,
  }) = NwcLookupInvoiceResponse;

  factory NwcResponse.nwcListTransactionsResponse({
    required List<Transaction> transactions,
  }) = NwcListTransactionsResponse;

  factory NwcResponse.nwcErrorResponse({
    required NwcMethod method,
    required NwcErrorCode error,
    String unknownMethod,
  }) = NwcErrorResponse;

  NostrEvent toSignedNostrEvent({
    required NostrKeyPair creatorKeyPair,
    required String requestId,
    required String connectionPubkey,
  }) {
    final content = jsonEncode(
      {
        'resultType': resultType,
        if (error != null)
          'error': {
            'code': error!.code,
            'message': error!.message,
          },
        if (result != null) 'result': result,
      },
    );
    final encryptedContent = Nip04.encrypt(
      content,
      creatorKeyPair.privateKey,
      connectionPubkey,
    );
    final partialNostrEvent = NostrEvent(
      pubkey: creatorKeyPair.publicKey,
      createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      kind: NostrEventKind.nip47Response,
      tags: [
        ['e', requestId],
        ['p', connectionPubkey]
      ],
      content: encryptedContent,
    );

    final id = partialNostrEvent.calculatedId;
    final signedNostrEvent = partialNostrEvent.copyWith(
      id: id,
      sig: creatorKeyPair.sign(id),
    );

    return signedNostrEvent;
  }

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
  }) : super(
          resultType: NwcMethod.getInfo.plaintext,
          result: {
            'alias': alias,
            'color': color,
            'pubkey': pubkey,
            'network': network.name,
            'blockHeight': blockHeight,
            'blockHash': blockHash,
            'methods': methods.map((method) => method.plaintext).toList(),
          },
        );

  @override
  List<Object?> get props => [
        ...super.props,
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
  }) : super(resultType: NwcMethod.getBalance.plaintext, result: {
          'balance': balanceSat * 1000, // user's balance in msats
        });

  @override
  List<Object?> get props => [...super.props, balanceSat];
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
  final int? expiresAt;
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
    this.expiresAt,
    required this.metadata,
  }) : super(
          resultType: NwcMethod.makeInvoice.plaintext,
          result: {
            'type': TransactionType.incoming.name,
            if (invoice != null) 'invoice': invoice,
            if (description != null) 'description': description,
            if (descriptionHash != null) 'descriptionHash': descriptionHash,
            if (preimage != null) 'preimage': preimage,
            'paymentHash': paymentHash,
            'amount': amountSat * 1000, // invoice amount in msats
            'feesPaid': feesPaidSat * 1000, // fees paid in msats
            'createdAt': createdAt,
            if (expiresAt != null) 'expiresAt': expiresAt,
            'metadata': metadata,
          },
        );

  @override
  List<Object?> get props => [
        ...super.props,
        invoice,
        description,
        descriptionHash,
        preimage,
        paymentHash,
        amountSat,
        feesPaidSat,
        createdAt,
        expiresAt,
        metadata,
      ];
}

@immutable
class NwcPayInvoiceResponse extends NwcResponse {
  final String preimage;

  NwcPayInvoiceResponse({
    required this.preimage,
  }) : super(
          resultType: NwcMethod.payInvoice.plaintext,
          result: {
            'preimage': preimage,
          },
        );

  @override
  List<Object?> get props => [...super.props, preimage];
}

@immutable
class NwcMultiPayInvoiceResponse extends NwcResponse {
  final String preimage;

  NwcMultiPayInvoiceResponse({
    required this.preimage,
  }) : super(
          resultType: NwcMethod.multiPayInvoice.plaintext,
          result: {
            'preimage': preimage,
          },
        );

  @override
  List<Object?> get props => [...super.props, preimage];
}

@immutable
class NwcPayKeysend extends NwcResponse {
  final String preimage;

  NwcPayKeysend({
    required this.preimage,
  }) : super(
          resultType: NwcMethod.payKeysend.plaintext,
          result: {
            'preimage': preimage,
          },
        );

  @override
  List<Object?> get props => [...super.props, preimage];
}

@immutable
class NwcLookupInvoiceResponse extends NwcResponse {
  final String? invoice;
  final String? description;
  final String? descriptionHash;
  final String? preimage;
  final String paymentHash;
  final int amountSat;
  final int feesPaidSat;
  final int createdAt;
  final int? expiresAt;
  final int? settledAt;
  final Map<dynamic, dynamic> metadata;

  NwcLookupInvoiceResponse({
    this.invoice,
    this.description,
    this.descriptionHash,
    this.preimage,
    required this.paymentHash,
    required this.amountSat,
    required this.feesPaidSat,
    required this.createdAt,
    this.expiresAt,
    this.settledAt,
    required this.metadata,
  }) : super(
          resultType: NwcMethod.lookupInvoice.plaintext,
          result: {
            'type': TransactionType.incoming.name,
            if (invoice != null) 'invoice': invoice,
            if (description != null) 'description': description,
            if (descriptionHash != null) 'descriptionHash': descriptionHash,
            if (preimage != null) 'preimage': preimage,
            'paymentHash': paymentHash,
            'amount': amountSat * 1000, // invoice amount in msats
            'feesPaid': feesPaidSat * 1000, // fees paid in msats
            'createdAt': createdAt,
            if (expiresAt != null) 'expiresAt': expiresAt,
            if (settledAt != null) 'settledAt': settledAt,
            'metadata': metadata,
          },
        );

  @override
  List<Object?> get props => [
        ...super.props,
        invoice,
        description,
        descriptionHash,
        preimage,
        paymentHash,
        amountSat,
        feesPaidSat,
        createdAt,
        expiresAt,
        settledAt,
        metadata,
      ];
}

@immutable
class NwcListTransactionsResponse extends NwcResponse {
  final List<Transaction> transactions;

  NwcListTransactionsResponse({
    required this.transactions,
  }) : super(
          resultType: NwcMethod.listTransactions.plaintext,
          result: {
            'transactions': transactions
              ..sort((a, b) =>
                  a.createdAt -
                  b.createdAt) // Ensure transactions are in descending order
              ..map((transaction) => {
                    'type': transaction.type.name,
                    if (transaction.invoice != null)
                      'invoice': transaction.invoice,
                    if (transaction.description != null)
                      'description': transaction.description,
                    if (transaction.descriptionHash != null)
                      'descriptionHash': transaction.descriptionHash,
                    if (transaction.preimage != null)
                      'preimage': transaction.preimage,
                    'paymentHash': transaction.paymentHash,
                    'amount':
                        transaction.amountSat * 1000, // invoice amount in msats
                    'feesPaid':
                        transaction.feesPaidSat * 1000, // fees paid in msats
                    'createdAt': transaction.createdAt,
                    if (transaction.expiresAt != null)
                      'expiresAt': transaction.expiresAt,
                    if (transaction.settledAt != null)
                      'settledAt': transaction.settledAt,
                    'metadata': transaction.metadata,
                  }).toList(),
          },
        );

  @override
  List<Object?> get props => [...super.props, transactions];
}

@immutable
class NwcErrorResponse extends NwcResponse {
  final String unknownMethod;

  NwcErrorResponse({
    required NwcMethod method,
    required NwcErrorCode error,
    this.unknownMethod = '',
  }) : super(
          resultType:
              method == NwcMethod.unknown ? unknownMethod : method.plaintext,
          error: NwcErrorCode.notImplemented,
        );

  @override
  List<Object?> get props => [...super.props, unknownMethod];
}
