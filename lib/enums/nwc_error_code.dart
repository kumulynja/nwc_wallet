import 'package:nwc_wallet/constants/nostr_constants.dart';

enum NwcErrorCode {
  rateLimited(
    NostrConstants.nwcRateLimitedErrorCode,
    'The client is sending commands too fast. It should retry in a few seconds.',
  ),
  notImplemented(
    NostrConstants.nwcNotImplementedErrorCode,
    'The command is not known or is intentionally not implemented.',
  ),
  insufficientBalance(
    NostrConstants.nwcInsufficientBalanceErrorCode,
    'The wallet does not have enough funds to cover a fee reserve or the payment amount.',
  ),
  quotaExceeded(
    NostrConstants.nwcQuotaExceededErrorCode,
    'The wallet has exceeded its spending quota.',
  ),
  restricted(
    NostrConstants.nwcRestrictedErrorCode,
    'This public key is not allowed to do this operation.',
  ),
  unauthorized(
    NostrConstants.nwcUnauthorizedErrorCode,
    'This public key has no wallet connected.',
  ),
  internal(
    NostrConstants.nwcInternalErrorCode,
    'An internal error.',
  ),
  other(NostrConstants.nwcOtherErrorCode, 'Other error.');

  final String code;
  final String message;

  const NwcErrorCode(this.code, this.message);

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
