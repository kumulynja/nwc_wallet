import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/data/models/tlv_record.dart';
import 'package:nwc_wallet/enums/nwc_method_enum.dart';
import 'package:nwc_wallet/enums/transaction_type.dart';

// Abstract base class for messages from relay to client
@immutable
abstract class NwcRequest extends Equatable {
  const NwcRequest();

  factory NwcRequest.fromDecryptedEventContent(Map<String, dynamic> content) {
    final method = content['method'] as String;
    final params = content['params'] as Map<String, dynamic>;

    switch (NwcMethodX.fromPlaintext(method)) {
      case NwcMethod.getInfo:
        return const NwcGetInfoRequest();
      case NwcMethod.getBalance:
        return const NwcGetBalanceRequest();
      case NwcMethod.makeInvoice:
        return NwcMakeInvoiceRequest(
          amount: params['amount'] as int,
          description: params['description'] as String?,
          descriptionHash: params['descriptionHash'] as String?,
          expiry: params['expiry'] as int?,
        );
      case NwcMethod.payInvoice:
        return NwcPayInvoiceRequest(
          invoice: params['invoice'] as String,
        );
      case NwcMethod.multiPayInvoice:
        final invoices = (params['invoices'] as List)
            .map((e) => NwcMultiPayInvoiceRequestInvoicesElement(
                  invoice: e['invoice'] as String,
                  amount: e['amount'] as int,
                ))
            .toList();
        return NwcMultiPayInvoiceRequest(invoices: invoices);
      case NwcMethod.payKeysend:
        return NwcPayKeysendRequest(
          amount: params['amount'] as int,
          pubkey: params['pubkey'] as String,
          preimage: params['preimage'] as String?,
          tlvRecords: (params['tlvRecords'] as List)
              .map((e) => TlvRecord.fromMap(e as Map<String, dynamic>))
              .toList(),
        );
      case NwcMethod.lookupInvoice:
        return NwcLookupInvoiceRequest(
          paymentHash: params['paymentHash'] as String?,
          invoice: params['invoice'] as String?,
        );
      case NwcMethod.listTransactions:
        return NwcListTransactionsRequest(
          from: params['from'] as int?,
          until: params['until'] as int?,
          limit: params['limit'] as int?,
          offset: params['offset'] as int?,
          unpaid: params['unpaid'] as bool,
          type: params['type'] == null
              ? null
              : TransactionTypeX.fromName(params['type'] as String),
        );
      default:
        throw ArgumentError('Unknown method: $method');
    }
  }

  @override
  List<Object?> get props => [];
}

// Subclass for requests to get info like supported methods
@immutable
class NwcGetInfoRequest extends NwcRequest {
  const NwcGetInfoRequest();

  @override
  List<Object?> get props => [];
}

// Subclass for requests to get balance
@immutable
class NwcGetBalanceRequest extends NwcRequest {
  const NwcGetBalanceRequest();

  @override
  List<Object?> get props => [];
}

// Subclass for requests to make a bolt11 invoice
@immutable
class NwcMakeInvoiceRequest extends NwcRequest {
  final int amount;
  final String? description;
  final String? descriptionHash;
  final int? expiry;

  const NwcMakeInvoiceRequest({
    required this.amount,
    this.description,
    this.descriptionHash,
    this.expiry,
  });

  @override
  List<Object?> get props => [amount, description, descriptionHash, expiry];
}

// Subclass for requests to pay a bolt11 invoice
@immutable
class NwcPayInvoiceRequest extends NwcRequest {
  final String invoice;

  const NwcPayInvoiceRequest({
    required this.invoice,
  });

  @override
  List<Object?> get props => [invoice];
}

// Subclass for requests to pay multiple bolt11 invoices
@immutable
class NwcMultiPayInvoiceRequest extends NwcRequest {
  final List<NwcMultiPayInvoiceRequestInvoicesElement> invoices;

  const NwcMultiPayInvoiceRequest({
    required this.invoices,
  });

  @override
  List<Object?> get props => [invoices];
}

@immutable
class NwcMultiPayInvoiceRequestInvoicesElement extends Equatable {
  final String invoice;
  final int amount;

  const NwcMultiPayInvoiceRequestInvoicesElement({
    required this.invoice,
    required this.amount,
  });

  @override
  List<Object?> get props => [invoice, amount];
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
  });

  @override
  List<Object?> get props => [amount, pubkey, preimage, tlvRecords];
}

// Subclass for requests to look up an invoice
@immutable
class NwcLookupInvoiceRequest extends NwcRequest {
  final String? paymentHash;
  final String? invoice;

  const NwcLookupInvoiceRequest({
    this.paymentHash,
    this.invoice,
  });

  @override
  List<Object?> get props => [paymentHash, invoice];
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
  });

  @override
  List<Object?> get props => [from, until, limit, offset, unpaid, type];
}
