import 'package:equatable/equatable.dart';
import 'package:nwc_wallet/nwc_wallet.dart';
import 'package:nwc_wallet_app/enums/foreground_method.dart';
import 'package:flutter/material.dart';

@immutable
abstract class ForegroundTaskRequest extends Equatable {
  final ForegroundMethod method;

  const ForegroundTaskRequest({
    required this.method,
  });

  const factory ForegroundTaskRequest.initRequest() = InitRequest;
  const factory ForegroundTaskRequest.addConnectionRequest({
    required String name,
    required List<NwcMethod> permittedMethods,
  }) = AddConnectionRequest;
  const factory ForegroundTaskRequest.addWalletRequest() = AddWalletRequest;
  const factory ForegroundTaskRequest.hasWalletRequest() = HasWalletRequest;
  const factory ForegroundTaskRequest.aliasRequest() = AliasRequest;
  const factory ForegroundTaskRequest.colorRequest() = ColorRequest;
  const factory ForegroundTaskRequest.nodeIdRequest() = NodeIdRequest;
  const factory ForegroundTaskRequest.networkRequest() = NetworkRequest;
  const factory ForegroundTaskRequest.blockHeightRequest() = BlockHeightRequest;
  const factory ForegroundTaskRequest.blockHashRequest() = BlockHashRequest;
  const factory ForegroundTaskRequest.deleteWalletRequest() =
      DeleteWalletRequest;
  const factory ForegroundTaskRequest.syncRequest() = SyncRequest;
  const factory ForegroundTaskRequest.spendableBalanceSatRequest() =
      SpendableBalanceSatRequest;
  const factory ForegroundTaskRequest.inboundLiquiditySatRequest() =
      InboundLiquiditySatRequest;
  const factory ForegroundTaskRequest.generateInvoicesRequest({
    int? amountSat,
    int? expirySecs,
    String? description,
  }) = GenerateInvoicesRequest;
  const factory ForegroundTaskRequest.totalOnChainBalanceSatRequest() =
      TotalOnChainBalanceSatRequest;
  const factory ForegroundTaskRequest.spendableOnChainBalanceSatRequest() =
      SpendableOnChainBalanceSatRequest;
  const factory ForegroundTaskRequest.drainOnChainFundsRequest({
    required String address,
  }) = DrainOnChainFundsRequest;
  const factory ForegroundTaskRequest.sendOnChainFundsRequest({
    required String address,
    required int amountSat,
  }) = SendOnChainFundsRequest;
  const factory ForegroundTaskRequest.openChannelRequest({
    required String host,
    required int port,
    required String nodeId,
    required int channelAmountSat,
    bool announceChannel,
  }) = OpenChannelRequest;
  const factory ForegroundTaskRequest.payRequest(
    String invoice, {
    int? amountSat,
    double? satPerVbyte,
    int? absoluteFeeSat,
  }) = PayRequest;
  const factory ForegroundTaskRequest.getTransactionsRequest() =
      GetTransactionsRequest;
  const factory ForegroundTaskRequest.getTransactionByIdRequest(
    String id,
  ) = GetTransactionByIdRequest;

  factory ForegroundTaskRequest.fromMap(Map<String, dynamic> map) {
    final ForegroundMethod method =
        ForegroundMethod.fromPlaintext(map['method']);
    switch (method) {
      case ForegroundMethod.init:
        return const InitRequest();
      case ForegroundMethod.addConnection:
        return AddConnectionRequest(
          name: map['name'],
          permittedMethods: (map['permittedMethods'] as List)
              .map((e) => NwcMethod.fromPlaintext(e))
              .toList(),
        );
      case ForegroundMethod.addWallet:
        return const AddWalletRequest();
      case ForegroundMethod.hasWallet:
        return const HasWalletRequest();
      case ForegroundMethod.alias:
        return const AliasRequest();
      case ForegroundMethod.color:
        return const ColorRequest();
      case ForegroundMethod.nodeId:
        return const NodeIdRequest();
      case ForegroundMethod.network:
        return const NetworkRequest();
      case ForegroundMethod.blockHeight:
        return const BlockHeightRequest();
      case ForegroundMethod.blockHash:
        return const BlockHashRequest();
      case ForegroundMethod.deleteWallet:
        return const DeleteWalletRequest();
      case ForegroundMethod.sync:
        return const SyncRequest();
      case ForegroundMethod.spendableBalanceSat:
        return const SpendableBalanceSatRequest();
      case ForegroundMethod.inboundLiquiditySat:
        return const InboundLiquiditySatRequest();
      case ForegroundMethod.generateInvoices:
        return GenerateInvoicesRequest(
          amountSat: map['amountSat'],
          expirySecs: map['expirySecs'],
          description: map['description'],
        );
      case ForegroundMethod.totalOnChainBalanceSat:
        return const TotalOnChainBalanceSatRequest();
      case ForegroundMethod.spendableOnChainBalanceSat:
        return const SpendableOnChainBalanceSatRequest();
      case ForegroundMethod.drainOnChainFunds:
        return DrainOnChainFundsRequest(
          address: map['address'],
        );
      case ForegroundMethod.sendOnChainFunds:
        return SendOnChainFundsRequest(
          address: map['address'],
          amountSat: map['amountSat'],
        );
      case ForegroundMethod.openChannel:
        return OpenChannelRequest(
          host: map['host'],
          port: map['port'],
          nodeId: map['nodeId'],
          channelAmountSat: map['channelAmountSat'],
          announceChannel: map['announceChannel'],
        );
      case ForegroundMethod.pay:
        return PayRequest(
          map['invoice'],
          amountSat: map['amountSat'],
          satPerVbyte: map['satPerVbyte'],
          absoluteFeeSat: map['absoluteFeeSat'],
        );
      case ForegroundMethod.getTransactions:
        return const GetTransactionsRequest();
      case ForegroundMethod.getTransactionById:
        return GetTransactionByIdRequest(
          map['id'],
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
class InitRequest extends ForegroundTaskRequest {
  const InitRequest() : super(method: ForegroundMethod.init);
}

@immutable
class AddConnectionRequest extends ForegroundTaskRequest {
  final String name;
  final List<NwcMethod> permittedMethods;

  const AddConnectionRequest({
    required this.name,
    required this.permittedMethods,
  }) : super(method: ForegroundMethod.addConnection);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'name': name,
      'permittedMethods': permittedMethods.map((e) => e.plaintext).toList(),
    };
  }

  @override
  List<Object?> get props => [name, permittedMethods];
}

@immutable
class AddWalletRequest extends ForegroundTaskRequest {
  const AddWalletRequest() : super(method: ForegroundMethod.addWallet);
}

@immutable
class HasWalletRequest extends ForegroundTaskRequest {
  const HasWalletRequest() : super(method: ForegroundMethod.hasWallet);
}

@immutable
class AliasRequest extends ForegroundTaskRequest {
  const AliasRequest() : super(method: ForegroundMethod.alias);
}

@immutable
class ColorRequest extends ForegroundTaskRequest {
  const ColorRequest() : super(method: ForegroundMethod.color);
}

@immutable
class NodeIdRequest extends ForegroundTaskRequest {
  const NodeIdRequest() : super(method: ForegroundMethod.nodeId);
}

@immutable
class NetworkRequest extends ForegroundTaskRequest {
  const NetworkRequest() : super(method: ForegroundMethod.network);
}

@immutable
class BlockHeightRequest extends ForegroundTaskRequest {
  const BlockHeightRequest() : super(method: ForegroundMethod.blockHeight);
}

@immutable
class BlockHashRequest extends ForegroundTaskRequest {
  const BlockHashRequest() : super(method: ForegroundMethod.blockHash);
}

@immutable
class DeleteWalletRequest extends ForegroundTaskRequest {
  const DeleteWalletRequest() : super(method: ForegroundMethod.deleteWallet);
}

@immutable
class SyncRequest extends ForegroundTaskRequest {
  const SyncRequest() : super(method: ForegroundMethod.sync);
}

@immutable
class SpendableBalanceSatRequest extends ForegroundTaskRequest {
  const SpendableBalanceSatRequest()
      : super(method: ForegroundMethod.spendableBalanceSat);
}

@immutable
class InboundLiquiditySatRequest extends ForegroundTaskRequest {
  const InboundLiquiditySatRequest()
      : super(method: ForegroundMethod.inboundLiquiditySat);
}

@immutable
class GenerateInvoicesRequest extends ForegroundTaskRequest {
  final int? amountSat;
  final int? expirySecs;
  final String? description;

  const GenerateInvoicesRequest({
    this.amountSat,
    this.expirySecs,
    this.description,
  }) : super(method: ForegroundMethod.generateInvoices);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'amountSat': amountSat,
      'expirySecs': expirySecs,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [amountSat, expirySecs, description];
}

@immutable
class TotalOnChainBalanceSatRequest extends ForegroundTaskRequest {
  const TotalOnChainBalanceSatRequest()
      : super(method: ForegroundMethod.totalOnChainBalanceSat);
}

@immutable
class SpendableOnChainBalanceSatRequest extends ForegroundTaskRequest {
  const SpendableOnChainBalanceSatRequest()
      : super(method: ForegroundMethod.spendableOnChainBalanceSat);
}

@immutable
class DrainOnChainFundsRequest extends ForegroundTaskRequest {
  final String address;

  const DrainOnChainFundsRequest({
    required this.address,
  }) : super(method: ForegroundMethod.drainOnChainFunds);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'address': address,
    };
  }

  @override
  List<Object?> get props => [...super.props, address];
}

@immutable
class SendOnChainFundsRequest extends ForegroundTaskRequest {
  final String address;
  final int amountSat;

  const SendOnChainFundsRequest({
    required this.address,
    required this.amountSat,
  }) : super(method: ForegroundMethod.sendOnChainFunds);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'address': address,
      'amountSat': amountSat,
    };
  }

  @override
  List<Object?> get props => [...super.props, address, amountSat];
}

@immutable
class OpenChannelRequest extends ForegroundTaskRequest {
  final String host;
  final int port;
  final String nodeId;
  final int channelAmountSat;
  final bool announceChannel;

  const OpenChannelRequest({
    required this.host,
    required this.port,
    required this.nodeId,
    required this.channelAmountSat,
    this.announceChannel = false,
  }) : super(method: ForegroundMethod.openChannel);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'host': host,
      'port': port,
      'nodeId': nodeId,
      'channelAmountSat': channelAmountSat,
      'announceChannel': announceChannel,
    };
  }

  @override
  List<Object?> get props =>
      [...super.props, host, port, nodeId, channelAmountSat, announceChannel];
}

@immutable
class PayRequest extends ForegroundTaskRequest {
  final String invoice;
  final int? amountSat;
  final double? satPerVbyte;
  final int? absoluteFeeSat;

  const PayRequest(
    this.invoice, {
    this.amountSat,
    this.satPerVbyte, // Not used in Lightning
    this.absoluteFeeSat, // Not used in Lightning
  }) : super(method: ForegroundMethod.pay);

  @override
  Map<String, dynamic> toMap() {
    return {
      ...super.toMap(),
      'invoice': invoice,
      'amountSat': amountSat,
      'satPerVbyte': satPerVbyte,
      'absoluteFeeSat': absoluteFeeSat,
    };
  }

  @override
  List<Object?> get props =>
      [...super.props, invoice, amountSat, satPerVbyte, absoluteFeeSat];
}

@immutable
class GetTransactionsRequest extends ForegroundTaskRequest {
  const GetTransactionsRequest()
      : super(method: ForegroundMethod.getTransactions);
}

@immutable
class GetTransactionByIdRequest extends ForegroundTaskRequest {
  final String id;

  const GetTransactionByIdRequest(
    this.id,
  ) : super(method: ForegroundMethod.getTransactionById);

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
