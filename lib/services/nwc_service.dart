import 'package:nwc_wallet/data/repositories/nwc_connection_repository.dart';
import 'package:nwc_wallet/enums/nwc_method_enum.dart';

abstract class NwcService {
  Future<String> addConnection(
    String name,
    String relayUrl,
    List<NwcMethod> permittedMethods,
    int monthlyLimit,
    int expiry,
  );
}

// Todo: use the different repositories like the nostr and db repositories, create and listen to streams,etc.
class NwcServiceImpl implements NwcService {
  final NwcConnectionRepository connectionRepository;

  NwcServiceImpl(this.connectionRepository) {
    // Todo: check and start listening to active connections
  }

  @override
  Future<String> addConnection(
    String name,
    String relayUrl,
    List<NwcMethod> permittedMethods,
    int monthlyLimit,
    int expiry,
  ) {
    // TODO: implement addConnection
    throw UnimplementedError();
  }
}
