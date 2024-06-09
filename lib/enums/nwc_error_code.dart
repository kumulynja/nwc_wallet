enum NwcErrorCode {
  rateLimited,
  notImplemented,
  insufficientBalance,
  quotaExceeded,
  restricted,
  unauthorized,
  internal,
  other,
}

extension NwcErrorCodeX on NwcErrorCode {
  static NwcErrorCode fromValue(String value) {
    switch (value) {
      case 'RATE_LIMITED':
        return NwcErrorCode.rateLimited;
      case 'NOT_IMPLEMENTED':
        return NwcErrorCode.notImplemented;
      case 'INSUFFICIENT_BALANCE':
        return NwcErrorCode.insufficientBalance;
      case 'QUOTA_EXCEEDED':
        return NwcErrorCode.quotaExceeded;
      case 'RESTRICTED':
        return NwcErrorCode.restricted;
      case 'UNAUTHORIZED':
        return NwcErrorCode.unauthorized;
      case 'INTERNAL':
        return NwcErrorCode.internal;
      case 'OTHER':
        return NwcErrorCode.other;
      default:
        throw Exception('Unknown NWC error code: $value');
    }
  }
}
