import 'package:nwc_wallet_app/features/nwc/connections/nwc_connections_state.dart';
import 'package:nwc_wallet_app/services/nwc_wallet_service/nwc_wallet_service.dart';
import 'package:nwc_wallet_app/view_models/nwc_connection_view_model.dart';

class NwcConnectionsController {
  final NwcConnectionsState Function() _getState;
  final Function(NwcConnectionsState state) _updateState;
  final NwcWalletService _nwcWalletService;

  NwcConnectionsController({
    required getState,
    required updateState,
    required nwcWalletService,
  })  : _getState = getState,
        _updateState = updateState,
        _nwcWalletService = nwcWalletService;

  Future<void> init() async {
    final connections = await _nwcWalletService.getSavedConnections();

    _updateState(_getState().copyWith(
      activeConnections: connections
          .map((connection) => NwcConnectionViewModel(
                permittedMethods: connection.permittedMethods,
                pubkey: connection.pubkey,
                name: connection.name,
              ))
          .toList(),
    ));
  }

  Future<void> setNewConnectionName(String name) async {
    _updateState(_getState().copyWith(newConnectionName: name));
  }

  Future<String> addNewConnection() async {
    final state = _getState();
    try {
      final newConnection = await _nwcWalletService.addConnection(
        name: state.newConnectionName!,
        permittedMethods: state.newConnectionPermittedMethods,
      );
      _updateState(
        state.copyWith(
          activeConnections: state.activeConnections
            ..add(
              NwcConnectionViewModel(
                permittedMethods: newConnection.permittedMethods,
                pubkey: newConnection.pubkey,
                name: state.newConnectionName!,
              ),
            ),
        ),
      );
      return newConnection.uri!;
    } catch (e) {
      print(e);
      throw 'Failed to add new connection.';
    }
  }
}
