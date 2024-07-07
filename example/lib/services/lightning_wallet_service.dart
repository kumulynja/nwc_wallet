import 'dart:async';
import 'dart:io';

import 'package:example/enums/lightning_node_implementation.dart';
import 'package:example/entities/transaction_entity.dart';
import 'package:example/repositories/mnemonic_repository.dart';
import 'package:ldk_node/ldk_node.dart';
import 'package:path_provider/path_provider.dart';

abstract class LightningWalletService {
  LightningNodeImplementation get lightningNodeImplementation;
  Future<void> init();
  Future<void> addWallet();
  bool get hasWallet;
  Future<void> deleteWallet();
  Future<void> sync();
  Future<int> get spendableBalanceSat;
  Future<int> get inboundLiquiditySat;
  Future<int> get totalOnChainBalanceSat;
  Future<int> get spendableOnChainBalanceSat;
  Future<String> drainOnChainFunds(String address);
  Future<String> sendOnChainFunds(String address, int amountSat);
  Future<void> openChannel({
    required String host,
    required int port,
    required String nodeId,
    required int channelAmountSat,
    bool announceChannel = false,
  });
  Future<(String? bitcoinInvoice, String? lightningInvoice)> generateInvoices({
    int? amountSat,
    int expirySecs,
    String description,
  });
  Future<List<TransactionEntity>> getTransactions();
  Future<String> pay(
    String invoice, {
    int? amountSat,
    double? satPerVbyte,
    int? absoluteFeeSat,
  });
}

class NoWalletException implements Exception {
  final String message;

  NoWalletException(this.message);
}

class LdkNodeLightningWalletService implements LightningWalletService {
  final LightningNodeImplementation _lightningNodeImplementation =
      LightningNodeImplementation.ldkNode;
  final MnemonicRepository _mnemonicRepository;
  Node? _node;

  LdkNodeLightningWalletService({
    required MnemonicRepository mnemonicRepository,
  }) : _mnemonicRepository = mnemonicRepository;

  @override
  LightningNodeImplementation get lightningNodeImplementation =>
      _lightningNodeImplementation;

  @override
  Future<void> init() async {
    final mnemonic = await _mnemonicRepository
        .getMnemonic(_lightningNodeImplementation.label);
    if (mnemonic != null && mnemonic.isNotEmpty) {
      await _initialize(Mnemonic(seedPhrase: mnemonic));

      print(
        'Lightning node initialized with id: ${(await _node!.nodeId()).hex}',
      );
    }
  }

  @override
  Future<void> addWallet() async {
    final mnemonic = await Mnemonic.generate();

    print('Generated mnemonic: ${mnemonic.seedPhrase}');

    await _mnemonicRepository.setMnemonic(
      _lightningNodeImplementation.label,
      mnemonic.seedPhrase,
    );

    await _initialize(mnemonic);

    if (_node != null) {
      print(
        'Lightning Node added with node id: ${(await _node!.nodeId()).hex}',
      );
    }
  }

  @override
  bool get hasWallet => _node != null;

  @override
  Future<void> deleteWallet() async {
    if (_node != null) {
      await _mnemonicRepository
          .deleteMnemonic(_lightningNodeImplementation.label);
      await _node!.stop();
      await Future.delayed(const Duration(seconds: 12));
      await _clearCache();
      _node = null;
    }
  }

  @override
  Future<void> sync() async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }
    await _node!.syncWallets();

    await _printLogs();
  }

  @override
  Future<int> get spendableBalanceSat async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final balances = await _node!.listBalances();
    return balances.totalLightningBalanceSats.toInt();
  }

  @override
  Future<int> get inboundLiquiditySat async {
    if (_node == null) {
      return 0;
    }

    final usableChannels =
        (await _node!.listChannels()).where((channel) => channel.isUsable);
    final inboundCapacityMsat = usableChannels.fold(
      BigInt.zero,
      (sum, channel) => sum + channel.inboundCapacityMsat,
    );

    return inboundCapacityMsat.toInt() ~/ 1000;
  }

  @override
  Future<(String?, String?)> generateInvoices({
    int? amountSat,
    int expirySecs = 3600 * 24, // Default to 1 day
    String description = 'NWC Wallet Demo',
  }) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    Bolt11Payment bolt11Payment = await _node!.bolt11Payment();
    Bolt11Invoice? bolt11;
    try {
      if (amountSat == null) {
        // 18. Change to receive via a JIT channel when no amount is specified
        bolt11 = await bolt11Payment.receiveVariableAmountViaJitChannel(
          expirySecs: expirySecs,
          description: description,
        );
      } else {
        // 19. Check the inbound liquidity and request a JIT channel if needed
        //  otherwise receive the payment as usual.
        if (await inboundLiquiditySat < amountSat) {
          bolt11 = await bolt11Payment.receiveViaJitChannel(
            amountMsat: BigInt.from(amountSat * 1000),
            expirySecs: expirySecs,
            description: description,
          );
        } else {
          bolt11 = await bolt11Payment.receive(
            amountMsat: BigInt.from(amountSat * 1000),
            expirySecs: expirySecs,
            description: description,
          );
        }
      }
    } catch (e) {
      final errorMessage = 'Failed to generate invoice: $e';
      print(errorMessage);
    }

    final onChainPayment = await _node!.onChainPayment();
    final bitcoinAddress = await onChainPayment.newAddress();

    print('Generated invoice: ${bolt11?.signedRawInvoice}');
    print('Generated address: ${bitcoinAddress.s}');

    return (bitcoinAddress.s, bolt11 == null ? '' : bolt11.signedRawInvoice);
  }

  @override
  Future<int> get totalOnChainBalanceSat async {
    if (_node == null) {
      return 0;
    }

    final balances = await _node!.listBalances();
    return balances.totalOnchainBalanceSats.toInt();
  }

  @override
  Future<int> get spendableOnChainBalanceSat async {
    if (_node == null) {
      return 0;
    }

    final balances = await _node!.listBalances();
    return balances.spendableOnchainBalanceSats.toInt();
  }

  @override
  Future<String> drainOnChainFunds(String address) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final onChainPayment = await _node!.onChainPayment();
    final tx =
        await onChainPayment.sendAllToAddress(address: Address(s: address));
    return tx.hash;
  }

  @override
  Future<String> sendOnChainFunds(String address, int amountSat) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final onChainPayment = await _node!.onChainPayment();
    final tx = await onChainPayment.sendToAddress(
      address: Address(s: address),
      amountSats: BigInt.from(amountSat),
    );
    return tx.hash;
  }

  @override
  Future<void> openChannel({
    required String host,
    required int port,
    required String nodeId,
    required int channelAmountSat,
    bool announceChannel = false,
  }) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    await _node!.connectOpenChannel(
      socketAddress: SocketAddress.hostname(addr: host, port: port),
      nodeId: PublicKey(
        hex: nodeId,
      ),
      channelAmountSats: BigInt.from(channelAmountSat),
      announceChannel: announceChannel,
      channelConfig: null,
      pushToCounterpartyMsat: null,
    );
  }

  @override
  Future<String> pay(
    String invoice, {
    int? amountSat,
    double? satPerVbyte, // Not used in Lightning
    int? absoluteFeeSat, // Not used in Lightning
  }) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final bolt11Payment = await _node!.bolt11Payment();
    final hash = amountSat == null
        ? await bolt11Payment.send(
            invoice: Bolt11Invoice(
              signedRawInvoice: invoice,
            ),
          )
        : await bolt11Payment.sendUsingAmount(
            invoice: Bolt11Invoice(
              signedRawInvoice: invoice,
            ),
            amountMsat: BigInt.from(amountSat * 1000),
          );

    return hash.field0.toString();
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final payments = await _node!.listPayments();

    return payments
        .where((payment) => payment.status == PaymentStatus.succeeded)
        .map((payment) {
      return TransactionEntity(
        id: payment.id.field0.toString(),
        receivedAmountSat: payment.direction == PaymentDirection.inbound &&
                payment.amountMsat != null
            ? payment.amountMsat!.toInt() ~/ 1000
            : 0,
        sentAmountSat: payment.direction == PaymentDirection.outbound &&
                payment.amountMsat != null
            ? payment.amountMsat!.toInt() ~/ 1000
            : 0,
        timestamp: null,
      );
    }).toList();
  }

  Future<void> _initialize(Mnemonic mnemonic) async {
    final builder = Builder.mutinynet().setEntropyBip39Mnemonic(
      mnemonic: mnemonic,
    );
    _node = await builder.build();
    await _node!.start();

    _printLogs();
  }

  Future<String> get _nodePath async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/ldk_cache";
  }

  Future<void> _clearCache() async {
    final directory = Directory(await _nodePath);
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<void> _printLogs() async {
    final logsFile = File('${await _nodePath}/logs/ldk_node_latest.log');
    String contents = await logsFile.readAsString();

    // Define the maximum length of each chunk to be printed
    const int chunkSize = 1024;

    // Split the contents into chunks and print each chunk
    for (int i = 0; i < contents.length; i += chunkSize) {
      int end =
          (i + chunkSize < contents.length) ? i + chunkSize : contents.length;
      print(contents.substring(i, end));
    }
  }
}

/*extension U8Array32X on U8Array32 {
  String get hexCode =>
      map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}*/
