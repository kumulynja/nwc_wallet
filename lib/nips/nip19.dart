import 'package:bech32/bech32.dart';
import 'package:nwc_wallet/constants/nostr_constants.dart';
import 'package:convert/convert.dart' as convert;

class Nip19 {
  static String nsecFromHex(String hex) {
    return _bech32Encode(hex, NostrConstants.nsecPrefix);
  }

  static String nsecToHex(String nsec) {
    final (hex, hrp) = _bech32Decode(nsec);

    if (hrp != NostrConstants.nsecPrefix) {
      throw ArgumentError('Invalid nsec prefix');
    }

    return hex;
  }

  static String npubFromHex(String hex) {
    return _bech32Encode(hex, NostrConstants.npubPrefix);
  }

  static String npubToHex(String npub) {
    final (hex, hrp) = _bech32Decode(npub);

    if (hrp != NostrConstants.npubPrefix) {
      throw ArgumentError('Invalid npub prefix');
    }

    return hex;
  }

  static String _bech32Encode(String hex, String hrp) {
    final bytes = convert.hex.decode(hex);
    final fiveBitWords = _convertBits(bytes, 8, 5, true);

    return bech32.encode(Bech32(hrp, fiveBitWords), hrp.length + hex.length);
  }

  static (String hex, String hrp) _bech32Decode(String bech32String) {
    const codec = Bech32Codec();
    final bech32 = codec.decode(bech32String, bech32String.length);
    final eightBitWords = _convertBits(bech32.data, 5, 8, false);
    return (convert.hex.encode(eightBitWords), bech32.hrp);
  }

  /// Convert bits from one base to another
  /// [data] - the data to convert
  /// [fromBits] - the number of bits per input value
  /// [toBits] - the number of bits per output value
  /// [pad] - whether to pad the output if there are not enough bits
  /// If pad is true, and there are remaining bits after the conversion, then the remaining bits are left-shifted and added to the result
  /// [return] - the converted data
  static List<int> _convertBits(
    List<int> data,
    int fromBits,
    int toBits,
    bool pad,
  ) {
    var acc = 0;
    var bits = 0;
    final result = <int>[];

    for (final value in data) {
      acc = (acc << fromBits) | value;
      bits += fromBits;

      while (bits >= toBits) {
        bits -= toBits;
        result.add((acc >> bits) & ((1 << toBits) - 1));
      }
    }

    if (pad) {
      if (bits > 0) {
        result.add((acc << (toBits - bits)) & ((1 << toBits) - 1));
      }
    } else if (bits >= fromBits || (acc & ((1 << bits) - 1)) != 0) {
      throw Exception('Invalid padding');
    }

    return result;
  }
}
