class NostrConstants {
  static const String npubPrefix = 'npub';
  static const String nsecPrefix = 'nsec';
  static const String uriProtocol = 'nostr+walletconnect';

  // Nostr client message type constants
  static const String clientMessageEventType = 'EVENT';
  static const String clientMessageRequestType = 'REQ';
  static const String clientMessageCloseType = 'CLOSE';

  // Nostr event kind constants
  static const int nip01UserMetadataKind = 0;
  static const int nip01TextNoteKind = 1;
  static const int nip47InfoEventKind = 13194;
  static const int nip47RequestKind = 23194;
  static const int nip47ResponseKind = 23195;

  // Nostr relay message type constants
  static const String relayMessageEventType = 'EVENT';
  static const String relayMessageOkType = 'OK';
  static const String relayMessageEoseType = 'EOSE';
  static const String relayMessageClosedType = 'CLOSED';
  static const String relayMessageNoticeType = 'NOTICE';

  // Nwc method constants
  static const String nwcPayInvoiceMethod = 'pay_invoice';
  static const String nwcMultiPayInvoiceMethod = 'multi_pay_invoice';
  static const String nwcPayKeysendMethod = 'pay_keysend';
  static const String nwcMultiPayKeysendMethod = 'multi_pay_keysend';
  static const String nwcMakeInvoiceMethod = 'make_invoice';
  static const String nwcLookupInvoiceMethod = 'lookup_invoice';
  static const String nwcListTransactionsMethod = 'list_transactions';
  static const String nwcGetBalanceMethod = 'get_balance';
  static const String nwcGetInfoMethod = 'get_info';
  static const String nwcUnknownMethod = 'unknown';

  // NWC error code constants
  static const String nwcRateLimitedErrorCode = 'RATE_LIMITED';
  static const String nwcNotImplementedErrorCode = 'NOT_IMPLEMENTED';
  static const String nwcInsufficientBalanceErrorCode = 'INSUFFICIENT_BALANCE';
  static const String nwcQuotaExceededErrorCode = 'QUOTA_EXCEEDED';
  static const String nwcRestrictedErrorCode = 'RESTRICTED';
  static const String nwcUnauthorizedErrorCode = 'UNAUTHORIZED';
  static const String nwcInternalErrorCode = 'INTERNAL';
  static const String nwcOtherErrorCode = 'OTHER';
}
