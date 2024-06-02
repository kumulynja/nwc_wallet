import 'package:nwc_wallet/constants/nostr_constants.dart';

enum NwcMethod {
  payInvoice,
  multiPayInvoice,
  payKeysend,
  multiPayKeysend,
  makeInvoice,
  lookupInvoice,
  listTransactions,
  getBalance,
  getInfo,
}

extension NwcMethodX on NwcMethod {
  String get plaintext {
    switch (this) {
      case NwcMethod.payInvoice:
        return NostrConstants.nwcPayInvoiceMethod;
      case NwcMethod.multiPayInvoice:
        return NostrConstants.nwcMultiPayInvoiceMethod;
      case NwcMethod.payKeysend:
        return NostrConstants.nwcPayKeysendMethod;
      case NwcMethod.multiPayKeysend:
        return NostrConstants.nwcMultiPayKeysendMethod;
      case NwcMethod.makeInvoice:
        return NostrConstants.nwcMakeInvoiceMethod;
      case NwcMethod.lookupInvoice:
        return NostrConstants.nwcLookupInvoiceMethod;
      case NwcMethod.listTransactions:
        return NostrConstants.nwcListTransactionsMethod;
      case NwcMethod.getBalance:
        return NostrConstants.nwcGetBalanceMethod;
      case NwcMethod.getInfo:
        return NostrConstants.nwcGetInfoMethod;
    }
  }

  static NwcMethod fromPlaintext(String plaintext) {
    switch (plaintext) {
      case NostrConstants.nwcPayInvoiceMethod:
        return NwcMethod.payInvoice;
      case NostrConstants.nwcMultiPayInvoiceMethod:
        return NwcMethod.multiPayInvoice;
      case NostrConstants.nwcPayKeysendMethod:
        return NwcMethod.payKeysend;
      case NostrConstants.nwcMultiPayKeysendMethod:
        return NwcMethod.multiPayKeysend;
      case NostrConstants.nwcMakeInvoiceMethod:
        return NwcMethod.makeInvoice;
      case NostrConstants.nwcLookupInvoiceMethod:
        return NwcMethod.lookupInvoice;
      case NostrConstants.nwcListTransactionsMethod:
        return NwcMethod.listTransactions;
      case NostrConstants.nwcGetBalanceMethod:
        return NwcMethod.getBalance;
      case NostrConstants.nwcGetInfoMethod:
        return NwcMethod.getInfo;
      default:
        throw Exception('Unknown NWC method: $plaintext');
    }
  }
}
