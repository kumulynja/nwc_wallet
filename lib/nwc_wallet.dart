library nwc_wallet;

export 'enums/nwc_method_enum.dart' show NwcMethod;

import 'package:nwc_wallet/data/providers/database_provider.dart';
import 'package:nwc_wallet/data/providers/nwc_connection_provider.dart';
import 'package:nwc_wallet/data/repositories/nwc_connection_repository.dart';
import 'package:nwc_wallet/enums/nwc_method_enum.dart';
import 'package:nwc_wallet/services/nwc_service.dart';

class NwcWallet {
  // Private constructor
  NwcWallet._();

  // Singleton instance
  static final NwcWallet _instance = NwcWallet._();

  // Factory constructor
  factory NwcWallet() => _instance;

  // Internal fields
  late final NwcService _service = NwcServiceImpl(
    NwcConnectionRepositoryImpl(
      NwcConnectionProviderImpl(
        DatabaseProviderImpl.instance,
      ),
    ),
  );

  Future<String> addConnection(
    String name,
    String relayUrl,
    List<NwcMethod> permittedMethods,
    int monthlyLimit,
    int expiry,
  ) {
    return _service.addConnection(
      name,
      relayUrl,
      permittedMethods,
      monthlyLimit,
      expiry,
    );
  }
}
