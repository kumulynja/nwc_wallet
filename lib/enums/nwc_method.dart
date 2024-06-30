import 'package:nwc_wallet/constants/nostr_constants.dart';

enum NwcMethod {
  payInvoice(NostrConstants.nwcPayInvoiceMethod),
  multiPayInvoice(NostrConstants.nwcMultiPayInvoiceMethod),
  payKeysend(NostrConstants.nwcPayKeysendMethod),
  multiPayKeysend(NostrConstants.nwcMultiPayKeysendMethod),
  makeInvoice(NostrConstants.nwcMakeInvoiceMethod),
  lookupInvoice(NostrConstants.nwcLookupInvoiceMethod),
  listTransactions(NostrConstants.nwcListTransactionsMethod),
  getBalance(NostrConstants.nwcGetBalanceMethod),
  getInfo(NostrConstants.nwcGetInfoMethod),
  unknown(NostrConstants.nwcUnknownMethod);

  final String plaintext;

  const NwcMethod(this.plaintext);

  factory NwcMethod.fromPlaintext(String plaintext) {
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
        return NwcMethod.unknown;
    }
  }
}
