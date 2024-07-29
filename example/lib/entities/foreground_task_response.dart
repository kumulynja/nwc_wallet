import 'package:equatable/equatable.dart';
import 'package:nwc_wallet/data/models/nwc_connection.dart';
import 'package:nwc_wallet_app/entities/payment_details_entity.dart';
import 'package:nwc_wallet_app/enums/foreground_method.dart';
import 'package:flutter/material.dart';
import 'package:nwc_wallet/enums/bitcoin_network.dart';

@immutable
class ForegroundTaskResponse extends Equatable {
  final ForegroundMethod method;

  const ForegroundTaskResponse({
    required this.method,
  });

  factory ForegroundTaskResponse.initResponse() {
    return const InitResponse();
  }
  factory ForegroundTaskResponse.addConnectionResponse(
      {required NwcConnection connection}) {
    return AddConnectionResponse(connection: connection);
  }
  factory ForegroundTaskResponse.addWalletResponse() {
    return const AddWalletResponse();
  }
  factory ForegroundTaskResponse.hasWalletResponse({required bool hasWallet}) {
    return HasWalletResponse(hasWallet: hasWallet);
  }
  factory ForegroundTaskResponse.aliasResponse({required String alias}) {
    return AliasResponse(alias: alias);
  }
  factory ForegroundTaskResponse.colorResponse({required String color}) {
    return ColorResponse(color: color);
  }
  factory ForegroundTaskResponse.nodeIdResponse({required String nodeId}) {
    return NodeIdResponse(nodeId: nodeId);
  }
  factory ForegroundTaskResponse.networkResponse({
    required BitcoinNetwork network,
  }) {
    return NetworkResponse(network: network);
  }
  factory ForegroundTaskResponse.blockHeightResponse(
      {required int blockHeight}) {
    return BlockHeightResponse(blockHeight: blockHeight);
  }
  factory ForegroundTaskResponse.blockHashResponse(
      {required String blockHash}) {
    return BlockHashResponse(blockHash: blockHash);
  }
  factory ForegroundTaskResponse.deleteWalletResponse() {
    return const DeleteWalletResponse();
  }
  factory ForegroundTaskResponse.syncResponse() {
    return const SyncResponse();
  }
  factory ForegroundTaskResponse.spendableBalanceSatResponse({
    required int spendableBalanceSat,
  }) {
    return SpendableBalanceSatResponse(
        spendableBalanceSat: spendableBalanceSat);
  }
  factory ForegroundTaskResponse.inboundLiquiditySatResponse({
    required int inboundLiquiditySat,
  }) {
    return InboundLiquiditySatResponse(
        inboundLiquiditySat: inboundLiquiditySat);
  }
  factory ForegroundTaskResponse.generateInvoicesResponse({
    required String? bitcoinInvoice,
    required String? lightningInvoice,
  }) {
    return GenerateInvoicesResponse(
      bitcoinInvoice: bitcoinInvoice,
      lightningInvoice: lightningInvoice,
    );
  }
  factory ForegroundTaskResponse.totalOnChainBalanceSatResponse({
    required int totalOnChainBalanceSat,
  }) {
    return TotalOnChainBalanceSatResponse(
      totalOnChainBalanceSat: totalOnChainBalanceSat,
    );
  }
  factory ForegroundTaskResponse.spendableOnChainBalanceSatResponse({
    required int spendableOnChainBalanceSat,
  }) {
    return SpendableOnChainBalanceSatResponse(
      spendableOnChainBalanceSat: spendableOnChainBalanceSat,
    );
  }
  factory ForegroundTaskResponse.drainOnChainFundsResponse(
      {required String txid}) {
    return DrainOnChainFundsResponse(txid: txid);
  }
  factory ForegroundTaskResponse.sendOnChainFundsResponse(
      {required String txid}) {
    return SendOnChainFundsResponse(txid: txid);
  }
  factory ForegroundTaskResponse.openChannelResponse() {
    return const OpenChannelResponse();
  }
  factory ForegroundTaskResponse.payResponse({required String id}) {
    return PayResponse(id: id);
  }
  factory ForegroundTaskResponse.getTransactionsResponse({
    required List<PaymentDetailsEntity> transactions,
  }) {
    return GetTransactionsResponse(transactions: transactions);
  }
  factory ForegroundTaskResponse.getTransactionByIdResponse({
    required PaymentDetailsEntity? transaction,
  }) {
    return GetTransactionByIdResponse(transaction: transaction);
  }

  factory ForegroundTaskResponse.fromMap(Map<String, dynamic> map) {
    final ForegroundMethod method =
        ForegroundMethod.fromPlaintext(map['method']);
    switch (method) {
      case ForegroundMethod.init:
        return const InitResponse();
      case ForegroundMethod.addConnection:
        return AddConnectionResponse(
          connection: NwcConnection.fromMap(map['connection']),
        );
      case ForegroundMethod.addWallet:
        return const AddWalletResponse();
      case ForegroundMethod.hasWallet:
        return HasWalletResponse(hasWallet: map['hasWallet']);

      case ForegroundMethod.alias:
        return AliasResponse(alias: map['alias']);
      case ForegroundMethod.color:
        return ColorResponse(color: map['color']);
      case ForegroundMethod.nodeId:
        return NodeIdResponse(nodeId: map['nodeId']);
      case ForegroundMethod.network:
        return NetworkResponse(
          network: BitcoinNetwork.fromPlaintext(map['network']),
        );
      case ForegroundMethod.blockHeight:
        return BlockHeightResponse(blockHeight: map['blockHeight']);
      case ForegroundMethod.blockHash:
        return BlockHashResponse(blockHash: map['blockHash']);
      case ForegroundMethod.deleteWallet:
        return const DeleteWalletResponse();
      case ForegroundMethod.sync:
        return const SyncResponse();
      case ForegroundMethod.spendableBalanceSat:
        return SpendableBalanceSatResponse(
          spendableBalanceSat: map['spendableBalanceSat'],
        );
      case ForegroundMethod.inboundLiquiditySat:
        return InboundLiquiditySatResponse(
          inboundLiquiditySat: map['inboundLiquiditySat'],
        );
      case ForegroundMethod.generateInvoices:
        return GenerateInvoicesResponse(
          bitcoinInvoice: map['bitcoinInvoice'],
          lightningInvoice: map['lightningInvoice'],
        );
      case ForegroundMethod.totalOnChainBalanceSat:
        return TotalOnChainBalanceSatResponse(
          totalOnChainBalanceSat: map['totalOnChainBalanceSat'],
        );

      case ForegroundMethod.spendableOnChainBalanceSat:
        return SpendableOnChainBalanceSatResponse(
          spendableOnChainBalanceSat: map['spendableOnChainBalanceSat'],
        );
      case ForegroundMethod.drainOnChainFunds:
        return DrainOnChainFundsResponse(txid: map['txid']);
      case ForegroundMethod.sendOnChainFunds:
        return SendOnChainFundsResponse(txid: map['txid']);
      case ForegroundMethod.openChannel:
        return const OpenChannelResponse();
      case ForegroundMethod.pay:
        return PayResponse(id: map['id']);
      case ForegroundMethod.getTransactions:
        return GetTransactionsResponse(
          transactions: (map['transactions'] as List)
              .map((e) => PaymentDetailsEntity.fromMap(e))
              .toList(),
        );
      case ForegroundMethod.getTransactionById:
        return GetTransactionByIdResponse(
          transaction: map['transaction'] != null
              ? PaymentDetailsEntity.fromMap(map['transaction'])
              : null,
        );
      default:
        throw Exception('Unknown method: $method');
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'method': method.plaintext,
    };
  }

  @override
  List<Object?> get props => [method];
}

@immutable
class InitResponse extends ForegroundTaskResponse {
  const InitResponse() : super(method: ForegroundMethod.init);
}

@immutable
class AddConnectionResponse extends ForegroundTaskResponse {
  final NwcConnection connection;

  const AddConnectionResponse({required this.connection})
      : super(method: ForegroundMethod.addConnection);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'connection': connection.toMap(),
    };
  }

  @override
  List<Object?> get props => [...super.props, connection];
}

@immutable
class AddWalletResponse extends ForegroundTaskResponse {
  const AddWalletResponse() : super(method: ForegroundMethod.addWallet);
}

@immutable
class HasWalletResponse extends ForegroundTaskResponse {
  final bool hasWallet;
  const HasWalletResponse({required this.hasWallet})
      : super(method: ForegroundMethod.hasWallet);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'hasWallet': hasWallet,
    };
  }

  @override
  List<Object?> get props => [...super.props, hasWallet];
}

@immutable
class AliasResponse extends ForegroundTaskResponse {
  final String alias;
  const AliasResponse({required this.alias})
      : super(method: ForegroundMethod.alias);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'alias': alias,
    };
  }

  @override
  List<Object?> get props => [...super.props, alias];
}

@immutable
class ColorResponse extends ForegroundTaskResponse {
  final String color;
  const ColorResponse({required this.color})
      : super(method: ForegroundMethod.color);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'color': color,
    };
  }

  @override
  List<Object?> get props => [...super.props, color];
}

@immutable
class NodeIdResponse extends ForegroundTaskResponse {
  final String nodeId;
  const NodeIdResponse({required this.nodeId})
      : super(method: ForegroundMethod.nodeId);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'nodeId': nodeId,
    };
  }

  @override
  List<Object?> get props => [...super.props, nodeId];
}

@immutable
class NetworkResponse extends ForegroundTaskResponse {
  final BitcoinNetwork network;

  const NetworkResponse({required this.network})
      : super(method: ForegroundMethod.network);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'network': network.plaintext,
    };
  }

  @override
  List<Object?> get props => [...super.props, network];
}

@immutable
class BlockHeightResponse extends ForegroundTaskResponse {
  final int blockHeight;

  const BlockHeightResponse({required this.blockHeight})
      : super(method: ForegroundMethod.blockHeight);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'blockHeight': blockHeight,
    };
  }

  @override
  List<Object?> get props => [...super.props, blockHeight];
}

@immutable
class BlockHashResponse extends ForegroundTaskResponse {
  final String blockHash;

  const BlockHashResponse({required this.blockHash})
      : super(method: ForegroundMethod.blockHash);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'blockHash': blockHash,
    };
  }

  @override
  List<Object?> get props => [...super.props, blockHash];
}

@immutable
class DeleteWalletResponse extends ForegroundTaskResponse {
  const DeleteWalletResponse() : super(method: ForegroundMethod.deleteWallet);
}

@immutable
class SyncResponse extends ForegroundTaskResponse {
  const SyncResponse() : super(method: ForegroundMethod.sync);
}

@immutable
class SpendableBalanceSatResponse extends ForegroundTaskResponse {
  final int spendableBalanceSat;

  const SpendableBalanceSatResponse({required this.spendableBalanceSat})
      : super(method: ForegroundMethod.spendableBalanceSat);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'spendableBalanceSat': spendableBalanceSat,
    };
  }

  @override
  List<Object?> get props => [...super.props, spendableBalanceSat];
}

@immutable
class InboundLiquiditySatResponse extends ForegroundTaskResponse {
  final int inboundLiquiditySat;

  const InboundLiquiditySatResponse({required this.inboundLiquiditySat})
      : super(method: ForegroundMethod.inboundLiquiditySat);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'inboundLiquiditySat': inboundLiquiditySat,
    };
  }

  @override
  List<Object?> get props => [...super.props, inboundLiquiditySat];
}

@immutable
class GenerateInvoicesResponse extends ForegroundTaskResponse {
  final String? bitcoinInvoice;
  final String? lightningInvoice;

  const GenerateInvoicesResponse({
    this.bitcoinInvoice,
    this.lightningInvoice,
  }) : super(method: ForegroundMethod.generateInvoices);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'bitcoinInvoice': bitcoinInvoice,
      'lightningInvoice': lightningInvoice,
    };
  }

  @override
  List<Object?> get props => [...super.props, bitcoinInvoice, lightningInvoice];
}

@immutable
class TotalOnChainBalanceSatResponse extends ForegroundTaskResponse {
  final int totalOnChainBalanceSat;

  const TotalOnChainBalanceSatResponse({required this.totalOnChainBalanceSat})
      : super(method: ForegroundMethod.totalOnChainBalanceSat);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'totalOnChainBalanceSat': totalOnChainBalanceSat,
    };
  }

  @override
  List<Object?> get props => [...super.props, totalOnChainBalanceSat];
}

@immutable
class SpendableOnChainBalanceSatResponse extends ForegroundTaskResponse {
  final int spendableOnChainBalanceSat;

  const SpendableOnChainBalanceSatResponse(
      {required this.spendableOnChainBalanceSat})
      : super(method: ForegroundMethod.spendableOnChainBalanceSat);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'spendableOnChainBalanceSat': spendableOnChainBalanceSat,
    };
  }

  @override
  List<Object?> get props => [...super.props, spendableOnChainBalanceSat];
}

@immutable
class DrainOnChainFundsResponse extends ForegroundTaskResponse {
  final String txid;

  const DrainOnChainFundsResponse({required this.txid})
      : super(method: ForegroundMethod.drainOnChainFunds);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'txid': txid,
    };
  }

  @override
  List<Object?> get props => [...super.props, txid];
}

@immutable
class SendOnChainFundsResponse extends ForegroundTaskResponse {
  final String txid;

  const SendOnChainFundsResponse({required this.txid})
      : super(method: ForegroundMethod.sendOnChainFunds);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'txid': txid,
    };
  }

  @override
  List<Object?> get props => [...super.props, txid];
}

@immutable
class OpenChannelResponse extends ForegroundTaskResponse {
  const OpenChannelResponse() : super(method: ForegroundMethod.openChannel);
}

@immutable
class PayResponse extends ForegroundTaskResponse {
  final String id;

  const PayResponse({required this.id}) : super(method: ForegroundMethod.pay);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'id': id,
    };
  }

  @override
  List<Object?> get props => [...super.props, id];
}

@immutable
class GetTransactionsResponse extends ForegroundTaskResponse {
  final List<PaymentDetailsEntity> transactions;

  const GetTransactionsResponse({required this.transactions})
      : super(method: ForegroundMethod.getTransactions);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'transactions': transactions.map((e) => e.toMap()).toList(),
    };
  }

  @override
  List<Object?> get props => [...super.props, transactions];
}

@immutable
class GetTransactionByIdResponse extends ForegroundTaskResponse {
  final PaymentDetailsEntity? transaction;

  const GetTransactionByIdResponse({required this.transaction})
      : super(method: ForegroundMethod.getTransactionById);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'transaction': transaction?.toMap(),
    };
  }

  @override
  List<Object?> get props => [...super.props, transaction];
}
