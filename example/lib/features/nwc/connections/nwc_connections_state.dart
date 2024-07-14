import 'package:equatable/equatable.dart';
import 'package:example/view_models/nwc_connection_view_model.dart';
import 'package:nwc_wallet/nwc_wallet.dart';

class NwcConnectionsState extends Equatable {
  NwcConnectionsState({
    this.activeConnections = const [],
    this.newConnectionName,
    List<NwcMethod>? newConnectionPermittedMethods,
  }) : newConnectionPermittedMethods = newConnectionPermittedMethods ??
            NwcMethod.values.where((m) => m != NwcMethod.unknown).toList();

  final List<NwcConnectionViewModel> activeConnections;
  final String? newConnectionName;
  final List<NwcMethod> newConnectionPermittedMethods;

  NwcConnectionsState copyWith({
    List<NwcConnectionViewModel>? activeConnections,
    String? newConnectionName,
    List<NwcMethod>? newConnectionPermittedMethods,
  }) {
    return NwcConnectionsState(
      activeConnections: activeConnections ?? this.activeConnections,
      newConnectionName: newConnectionName ?? this.newConnectionName,
      newConnectionPermittedMethods:
          newConnectionPermittedMethods ?? this.newConnectionPermittedMethods,
    );
  }

  @override
  List<Object?> get props => [
        activeConnections,
        newConnectionName,
        newConnectionPermittedMethods,
      ];
}
