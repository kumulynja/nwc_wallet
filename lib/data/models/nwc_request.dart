import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/data/models/nostr_event.dart';
import 'package:nwc_wallet/data/models/tlv_record.dart';
import 'package:nwc_wallet/enums/nwc_method.dart';
import 'package:nwc_wallet/enums/transaction_type.dart';
import 'package:nwc_wallet/nips/nip04.dart';

// Abstract base class for messages from relay to client
@immutable
abstract class NwcRequest extends Equatable {
  final String id;
  final String connectionPubkey;
  final NwcMethod method;
  final int createdAt;

  const NwcRequest({
    required this.id,
    required this.connectionPubkey,
    required this.method,
    required this.createdAt,
  });

  factory NwcRequest.fromEvent(
    NostrEvent event,
    String contentDecryptionPrivateKey,
  ) {
    String connectionPubkey = event.pubkey;

    // Try to decrypt the content with the nip04 standard
    String decryptedContent = Nip04.decrypt(
      event.content,
      contentDecryptionPrivateKey,
      connectionPubkey,
    );
    debugPrint('Decrypted content: $decryptedContent');

    final content = jsonDecode(decryptedContent);
    final method = content['method'] as String;
    final params = content['params'] as Map<String, dynamic>? ?? {};

    switch (NwcMethod.fromPlaintext(method)) {
      case NwcMethod.getInfo:
        return NwcGetInfoRequest(
          id: event.id!,
          connectionPubkey: connectionPubkey,
          createdAt: event.createdAt,
        );
      case NwcMethod.getBalance:
        return NwcGetBalanceRequest(
          id: event.id!,
          connectionPubkey: connectionPubkey,
          createdAt: event.createdAt,
        );
      case NwcMethod.makeInvoice:
        return NwcMakeInvoiceRequest(
          id: event.id!,
          connectionPubkey: connectionPubkey,
          amountMsat: params['amount'] as int,
          description: params['description'] as String?,
          descriptionHash: params['descriptionHash'] as String?,
          expiry: params['expiry'] as int?,
          createdAt: event.createdAt,
        );
      case NwcMethod.payInvoice:
        return NwcPayInvoiceRequest(
          id: event.id!,
          connectionPubkey: connectionPubkey,
          invoice: params['invoice'] as String,
          createdAt: event.createdAt,
        );
      case NwcMethod.multiPayInvoice:
        final invoices = (params['invoices'] as List)
            .map((e) => NwcMultiPayInvoiceRequestInvoicesElement(
                  id: e['id'] as String?,
                  invoice: e['invoice'] as String,
                  amount: e['amount'] as int,
                ))
            .toList();
        return NwcMultiPayInvoiceRequest(
          id: event.id!,
          connectionPubkey: connectionPubkey,
          invoices: invoices,
          createdAt: event.createdAt,
        );
      case NwcMethod.payKeysend:
        return NwcPayKeysendRequest(
          id: event.id!,
          connectionPubkey: connectionPubkey,
          amount: params['amount'] as int,
          pubkey: params['pubkey'] as String,
          preimage: params['preimage'] as String?,
          tlvRecords: (params['tlvRecords'] as List)
              .map((e) => TlvRecord.fromMap(e as Map<String, dynamic>))
              .toList(),
          createdAt: event.createdAt,
        );
      case NwcMethod.multiPayKeysend:
        final keysends = (params['keysends'] as List)
            .map((e) => NwcMultiPayKeysendRequestInvoicesElement(
                  id: e['id'] as String?,
                  pubkey: e['pubkey'] as String,
                  amount: e['amount'] as int,
                  preimage: e['preimage'] as String?,
                  tlvRecords: (e['tlvRecords'] as List)
                      .map((e) => TlvRecord.fromMap(e as Map<String, dynamic>))
                      .toList(),
                ))
            .toList();
        return NwcMultiPayKeysendRequest(
          id: event.id!,
          connectionPubkey: connectionPubkey,
          keysends: keysends,
          createdAt: event.createdAt,
        );
      case NwcMethod.lookupInvoice:
        return NwcLookupInvoiceRequest(
          id: event.id!,
          connectionPubkey: connectionPubkey,
          paymentHash: params['paymentHash'] as String?,
          invoice: params['invoice'] as String?,
          createdAt: event.createdAt,
        );
      case NwcMethod.listTransactions:
        return NwcListTransactionsRequest(
          id: event.id!,
          connectionPubkey: connectionPubkey,
          from: params['from'] as int?,
          until: params['until'] as int?,
          limit: params['limit'] as int?,
          offset: params['offset'] as int?,
          unpaid: params['unpaid'] as bool,
          type: params['type'] == null
              ? null
              : TransactionType.fromName(
                  params['type'] as String,
                ),
          createdAt: event.createdAt,
        );
      default:
        return NwcUnknownRequest(
          id: event.id!,
          connectionPubkey: connectionPubkey,
          unknownMethod: method,
          params: params,
          createdAt: event.createdAt,
        );
    }
  }

  factory NwcRequest.fromMap(Map<String, dynamic> map) {
    final method = NwcMethod.fromPlaintext(map['method'] as String);
    switch (method) {
      case NwcMethod.getInfo:
        return NwcGetInfoRequest(
          id: map['id'] as String,
          connectionPubkey: map['connectionPubkey'] as String,
          createdAt: map['createdAt'] as int,
        );
      case NwcMethod.getBalance:
        return NwcGetBalanceRequest(
          id: map['id'] as String,
          connectionPubkey: map['connectionPubkey'] as String,
          createdAt: map['createdAt'] as int,
        );
      case NwcMethod.makeInvoice:
        return NwcMakeInvoiceRequest(
          id: map['id'] as String,
          connectionPubkey: map['connectionPubkey'] as String,
          amountMsat: map['amount'] as int,
          description: map['description'] as String?,
          descriptionHash: map['descriptionHash'] as String?,
          expiry: map['expiry'] as int?,
          createdAt: map['createdAt'] as int,
        );
      case NwcMethod.payInvoice:
        return NwcPayInvoiceRequest(
          id: map['id'] as String,
          connectionPubkey: map['connectionPubkey'] as String,
          invoice: map['invoice'] as String,
          createdAt: map['createdAt'] as int,
        );
      case NwcMethod.multiPayInvoice:
        final invoices = (map['invoices'] as List)
            .map((e) => NwcMultiPayInvoiceRequestInvoicesElement(
                  id: e['id'] as String?,
                  invoice: e['invoice'] as String,
                  amount: e['amount'] as int,
                ))
            .toList();
        return NwcMultiPayInvoiceRequest(
          id: map['id'] as String,
          connectionPubkey: map['connectionPubkey'] as String,
          invoices: invoices,
          createdAt: map['createdAt'] as int,
        );
      case NwcMethod.payKeysend:
        return NwcPayKeysendRequest(
          id: map['id'] as String,
          connectionPubkey: map['connectionPubkey'] as String,
          amount: map['amount'] as int,
          pubkey: map['pubkey'] as String,
          preimage: map['preimage'] as String?,
          tlvRecords: (map['tlvRecords'] as List)
              .map((e) => TlvRecord.fromMap(e as Map<String, dynamic>))
              .toList(),
          createdAt: map['createdAt'] as int,
        );
      case NwcMethod.multiPayKeysend:
        final keysends = (map['keysends'] as List)
            .map((e) => NwcMultiPayKeysendRequestInvoicesElement(
                  id: e['id'] as String?,
                  pubkey: e['pubkey'] as String,
                  amount: e['amount'] as int,
                  preimage: e['preimage'] as String?,
                  tlvRecords: (e['tlvRecords'] as List)
                      .map((e) => TlvRecord.fromMap(e as Map<String, dynamic>))
                      .toList(),
                ))
            .toList();
        return NwcMultiPayKeysendRequest(
          id: map['id'] as String,
          connectionPubkey: map['connectionPubkey'] as String,
          keysends: keysends,
          createdAt: map['createdAt'] as int,
        );
      case NwcMethod.lookupInvoice:
        return NwcLookupInvoiceRequest(
          id: map['id'] as String,
          connectionPubkey: map['connectionPubkey'] as String,
          paymentHash: map['paymentHash'] as String?,
          invoice: map['invoice'] as String?,
          createdAt: map['createdAt'] as int,
        );
      case NwcMethod.listTransactions:
        return NwcListTransactionsRequest(
          id: map['id'] as String,
          connectionPubkey: map['connectionPubkey'] as String,
          from: map['from'] as int?,
          until: map['until'] as int?,
          limit: map['limit'] as int?,
          offset: map['offset'] as int?,
          unpaid: map['unpaid'] as bool,
          type: map['type'] == null
              ? null
              : TransactionType.fromName(
                  map['type'] as String,
                ),
          createdAt: map['createdAt'] as int,
        );
      default:
        return NwcUnknownRequest(
          id: map['id'] as String,
          connectionPubkey: map['connectionPubkey'] as String,
          unknownMethod: map['unknownMethod'] as String,
          params: map['params'] as Map<String, dynamic>,
          createdAt: map['createdAt'] as int,
        );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'connectionPubkey': connectionPubkey,
      'method': method.plaintext,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [id, connectionPubkey, method, createdAt];
}

// Subclass for requests to get info like supported methods
@immutable
class NwcGetInfoRequest extends NwcRequest {
  const NwcGetInfoRequest({
    required super.id,
    required super.connectionPubkey,
    required super.createdAt,
  }) : super(method: NwcMethod.getInfo);

  @override
  List<Object?> get props => [...super.props];
}

// Subclass for requests to get balance
@immutable
class NwcGetBalanceRequest extends NwcRequest {
  const NwcGetBalanceRequest({
    required super.id,
    required super.connectionPubkey,
    required super.createdAt,
  }) : super(method: NwcMethod.getBalance);

  @override
  List<Object?> get props => [...super.props];
}

// Subclass for requests to make a bolt11 invoice
@immutable
class NwcMakeInvoiceRequest extends NwcRequest {
  final int amountSat;
  final String? description;
  final String? descriptionHash;
  final int? expiry;

  const NwcMakeInvoiceRequest({
    required amountMsat,
    this.description,
    this.descriptionHash,
    this.expiry,
    required super.id,
    required super.connectionPubkey,
    required super.createdAt,
  })  : amountSat = amountMsat ~/ 1000,
        super(method: NwcMethod.makeInvoice);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'amount': amountSat,
      'description': description,
      'descriptionHash': descriptionHash,
      'expiry': expiry,
    };
  }

  @override
  List<Object?> get props => [
        ...super.props,
        amountSat,
        description,
        descriptionHash,
        expiry,
      ];
}

// Subclass for requests to pay a bolt11 invoice
@immutable
class NwcPayInvoiceRequest extends NwcRequest {
  final String invoice;

  const NwcPayInvoiceRequest({
    required this.invoice,
    required super.id,
    required super.connectionPubkey,
    required super.createdAt,
  }) : super(method: NwcMethod.payInvoice);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'invoice': invoice,
    };
  }

  @override
  List<Object?> get props => [...super.props, invoice];
}

// Subclass for requests to pay multiple bolt11 invoices
@immutable
class NwcMultiPayInvoiceRequest extends NwcRequest {
  final List<NwcMultiPayInvoiceRequestInvoicesElement> invoices;

  const NwcMultiPayInvoiceRequest({
    required this.invoices,
    required super.id,
    required super.connectionPubkey,
    required super.createdAt,
  }) : super(method: NwcMethod.multiPayInvoice);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'invoices': invoices.map((e) => e.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [...super.props, invoices];
}

@immutable
class NwcMultiPayInvoiceRequestInvoicesElement {
  final String? id;
  final String invoice;
  final int amount;

  const NwcMultiPayInvoiceRequestInvoicesElement({
    this.id,
    required this.invoice,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice': invoice,
      'amount': amount,
    };
  }

  List<Object?> get props => [id, invoice, amount];
}

// Subclass for requests for a keysend payment
@immutable
class NwcPayKeysendRequest extends NwcRequest {
  final int amount;
  final String pubkey;
  final String? preimage;
  final List<TlvRecord>? tlvRecords;

  const NwcPayKeysendRequest({
    required this.amount,
    required this.pubkey,
    this.preimage,
    this.tlvRecords,
    required super.id,
    required super.connectionPubkey,
    required super.createdAt,
  }) : super(method: NwcMethod.payKeysend);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'amount': amount,
      'pubkey': pubkey,
      'preimage': preimage,
      'tlvRecords': tlvRecords?.map((e) => e.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props =>
      [...super.props, amount, pubkey, preimage, tlvRecords];
}

// Subclass for requests to pay multiple keysend payments
@immutable
class NwcMultiPayKeysendRequest extends NwcRequest {
  final List<NwcMultiPayKeysendRequestInvoicesElement> keysends;

  const NwcMultiPayKeysendRequest({
    required this.keysends,
    required super.id,
    required super.connectionPubkey,
    required super.createdAt,
  }) : super(method: NwcMethod.multiPayKeysend);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'keysends': keysends.map((e) => e.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [...super.props, keysends];
}

@immutable
class NwcMultiPayKeysendRequestInvoicesElement extends Equatable {
  final String? id;
  final String pubkey;
  final int amount;
  final String? preimage;
  final List<TlvRecord>? tlvRecords;

  const NwcMultiPayKeysendRequestInvoicesElement({
    this.id,
    required this.pubkey,
    required this.amount,
    this.preimage,
    this.tlvRecords,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'pubkey': pubkey,
      'amount': amount,
      'preimage': preimage,
      'tlvRecords': tlvRecords?.map((e) => e.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [id, pubkey, amount, preimage, tlvRecords];
}

// Subclass for requests to look up an invoice
@immutable
class NwcLookupInvoiceRequest extends NwcRequest {
  final String? paymentHash;
  final String? invoice;

  const NwcLookupInvoiceRequest({
    this.paymentHash,
    this.invoice,
    required super.id,
    required super.connectionPubkey,
    required super.createdAt,
  }) : super(method: NwcMethod.lookupInvoice);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'paymentHash': paymentHash,
      'invoice': invoice,
    };
  }

  @override
  List<Object?> get props => [...super.props, paymentHash, invoice];
}

// Subclass for requests to get a list of transactions
@immutable
class NwcListTransactionsRequest extends NwcRequest {
  final int? from;
  final int? until;
  final int? limit;
  final int? offset;
  final bool unpaid;
  final TransactionType? type;

  const NwcListTransactionsRequest({
    this.from,
    this.until,
    this.limit,
    this.offset,
    this.unpaid = false,
    this.type,
    required super.id,
    required super.connectionPubkey,
    required super.createdAt,
  }) : super(method: NwcMethod.listTransactions);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'from': from,
      'until': until,
      'limit': limit,
      'offset': offset,
      'unpaid': unpaid,
      'type': type?.name,
    };
  }

  @override
  List<Object?> get props =>
      [...super.props, from, until, limit, offset, unpaid, type];
}

// Subclass for requests with an unkown method
@immutable
class NwcUnknownRequest extends NwcRequest {
  final String unknownMethod;
  final Map<String, dynamic> params;

  const NwcUnknownRequest({
    required this.unknownMethod,
    required this.params,
    required super.id,
    required super.connectionPubkey,
    required super.createdAt,
  }) : super(method: NwcMethod.unknown);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'unknownMethod': unknownMethod,
      'params': params,
    };
  }

  @override
  List<Object?> get props => [...super.props, unknownMethod, params];
}
