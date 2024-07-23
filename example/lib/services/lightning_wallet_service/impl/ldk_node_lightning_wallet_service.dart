import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:example/entities/payment_details_entity.dart';
import 'package:example/repositories/mnemonic_repository.dart';
import 'package:example/enums/payment_direction.dart' as direction;
import 'package:example/services/lightning_wallet_service/lightning_wallet_service.dart';
import 'package:ldk_node/ldk_node.dart';
import 'package:nwc_wallet/nwc_wallet.dart';
import 'package:path_provider/path_provider.dart';

class LdkNodeLightningWalletService implements LightningWalletService {
  static const _alias = 'ldk_node';
  static const _color = '#FF9900';

  final MnemonicRepository _mnemonicRepository;
  Node? _node;

  LdkNodeLightningWalletService({
    required MnemonicRepository mnemonicRepository,
  }) : _mnemonicRepository = mnemonicRepository;

  @override
  Future<void> init() async {
    final mnemonic = await _mnemonicRepository.getMnemonic(_alias);
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
      _alias,
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
  String get alias => _alias;

  @override
  String get color => _color;

  @override
  Future<String> get nodeId async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final publicKey = await _node!.nodeId();
    return publicKey.hex;
  }

  @override
  BitcoinNetwork get network => BitcoinNetwork.signet;

  @override
  Future<int> get blockHeight async {
    if (_node == null) {
      return 0;
    }
    final status = await _node!.status();
    return status.currentBestBlock.height;
  }

  @override
  Future<String> get blockHash async {
    if (_node == null) {
      return '';
    }

    final status = await _node!.status();
    return status.currentBestBlock.blockHash;
  }

  @override
  Future<void> deleteWallet() async {
    if (_node != null) {
      await _mnemonicRepository.deleteMnemonic(_alias);
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
    int? expirySecs, // Default to 1 day
    String? description,
  }) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    description = description ?? 'NWC Wallet Demo';
    expirySecs = expirySecs ?? 3600 * 24;
    Bolt11Payment bolt11Payment = await _node!.bolt11Payment();
    Bolt11Invoice? bolt11;
    try {
      if (amountSat == null) {
        bolt11 = await bolt11Payment.receiveVariableAmountViaJitChannel(
          expirySecs: expirySecs,
          description: description,
        );
      } else {
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

    return hash.field0.hexCode;
  }

  @override
  Future<List<PaymentDetailsEntity>> getTransactions() async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final payments = await _node!.listPayments();

    return payments
        .where((payment) => payment.status == PaymentStatus.succeeded)
        .map(
      (payment) {
        String? preimage;
        if (payment.kind is PaymentKind_Bolt11) {
          final bolt11 = payment.kind as PaymentKind_Bolt11;
          preimage = bolt11.preimage?.data.hexCode;
        } else if (payment.kind is PaymentKind_Bolt11Jit) {
          final bolt11Jit = payment.kind as PaymentKind_Bolt11Jit;
          preimage = bolt11Jit.preimage?.data.hexCode;
        }

        return PaymentDetailsEntity(
          paymentHash: payment.id.field0.toString(),
          amountSat: payment.amountMsat != null
              ? payment.amountMsat!.toInt() ~/ 1000
              : 0,
          direction: payment.direction == PaymentDirection.inbound
              ? direction.PaymentDirection.incoming
              : direction.PaymentDirection.outgoing,
          isPaid: true,
          preimage: preimage,
          latestUpdateTimestamp: payment.latestUpdateTimestamp.toInt(),
        );
      },
    ).toList();
  }

  @override
  Future<PaymentDetailsEntity?> getTransactionById(String id) async {
    if (_node == null) {
      throw NoWalletException('A Lightning node has to be initialized first!');
    }

    final bytesArray = id.toU8Array32();
    final payment = await _node!.payment(
      paymentId: PaymentId(field0: bytesArray),
    );

    if (payment == null) {
      return null;
    }

    String? preimage;
    if (payment.kind is PaymentKind_Bolt11) {
      final bolt11 = payment.kind as PaymentKind_Bolt11;
      preimage = bolt11.preimage?.data.hexCode;
    } else if (payment.kind is PaymentKind_Bolt11Jit) {
      final bolt11Jit = payment.kind as PaymentKind_Bolt11Jit;
      preimage = bolt11Jit.preimage?.data.hexCode;
    }

    return PaymentDetailsEntity(
      paymentHash: id,
      amountSat:
          payment.amountMsat != null ? payment.amountMsat!.toInt() ~/ 1000 : 0,
      direction: payment.direction == PaymentDirection.inbound
          ? direction.PaymentDirection.incoming
          : direction.PaymentDirection.outgoing,
      preimage: preimage,
      isPaid: payment.status == PaymentStatus.succeeded,
      latestUpdateTimestamp: payment.latestUpdateTimestamp.toInt(),
    );
  }

  Future<void> _initialize(Mnemonic mnemonic) async {
    final builder = Builder.mutinynet()
        .setEntropyBip39Mnemonic(
          mnemonic: mnemonic,
        )
        .setEsploraServer('https://mutinynet.com/api');
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

extension U8Array32X on U8Array32 {
  String get hexCode =>
      map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}

extension StringX on String {
  U8Array32 toU8Array32() {
    return U8Array32(Uint8List.fromList(hex.decode(this)));
  }
}
