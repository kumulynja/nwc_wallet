import 'package:nwc_wallet/constants/nostr_constants.dart';

enum NwcErrorCode {
  rateLimited(NostrConstants.nwcRateLimitedErrorCode),
  notImplemented(NostrConstants.nwcNotImplementedErrorCode),
  insufficientBalance(NostrConstants.nwcInsufficientBalanceErrorCode),
  quotaExceeded(NostrConstants.nwcQuotaExceededErrorCode),
  restricted(NostrConstants.nwcRestrictedErrorCode),
  unauthorized(NostrConstants.nwcUnauthorizedErrorCode),
  internal(NostrConstants.nwcInternalErrorCode),
  other(NostrConstants.nwcOtherErrorCode);

  final String code;

  const NwcErrorCode(this.code);

  factory NwcErrorCode.fromCode(String code) {
    switch (code) {
      case NostrConstants.nwcRateLimitedErrorCode:
        return NwcErrorCode.rateLimited;
      case NostrConstants.nwcNotImplementedErrorCode:
        return NwcErrorCode.notImplemented;
      case NostrConstants.nwcInsufficientBalanceErrorCode:
        return NwcErrorCode.insufficientBalance;
      case NostrConstants.nwcQuotaExceededErrorCode:
        return NwcErrorCode.quotaExceeded;
      case NostrConstants.nwcRestrictedErrorCode:
        return NwcErrorCode.restricted;
      case NostrConstants.nwcUnauthorizedErrorCode:
        return NwcErrorCode.unauthorized;
      case NostrConstants.nwcInternalErrorCode:
        return NwcErrorCode.internal;
      case NostrConstants.nwcOtherErrorCode:
        return NwcErrorCode.other;
      default:
        throw ArgumentError('Invalid error code: $code');
    }
  }
}
