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
        return 'pay_invoice';
      case NwcMethod.multiPayInvoice:
        return 'multi_pay_invoice';
      case NwcMethod.payKeysend:
        return 'pay_keysend';
      case NwcMethod.multiPayKeysend:
        return 'multi_pay_keysend';
      case NwcMethod.makeInvoice:
        return 'make_invoice';
      case NwcMethod.lookupInvoice:
        return 'lookup_invoice';
      case NwcMethod.listTransactions:
        return 'list_transactions';
      case NwcMethod.getBalance:
        return 'get_balance';
      case NwcMethod.getInfo:
        return 'get_info';
    }
  }

  static NwcMethod fromPlaintext(String plaintext) {
    switch (plaintext) {
      case 'pay_invoice':
        return NwcMethod.payInvoice;
      case 'multi_pay_invoice':
        return NwcMethod.multiPayInvoice;
      case 'pay_keysend':
        return NwcMethod.payKeysend;
      case 'multi_pay_keysend':
        return NwcMethod.multiPayKeysend;
      case 'make_invoice':
        return NwcMethod.makeInvoice;
      case 'lookup_invoice':
        return NwcMethod.lookupInvoice;
      case 'list_transactions':
        return NwcMethod.listTransactions;
      case 'get_balance':
        return NwcMethod.getBalance;
      case 'get_info':
        return NwcMethod.getInfo;
      default:
        throw Exception('Unknown NWC method: $plaintext');
    }
  }
}
