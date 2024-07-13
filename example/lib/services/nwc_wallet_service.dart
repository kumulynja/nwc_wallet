import 'dart:async';

import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:example/entities/nwc_connection_entity.dart';
import 'package:example/repositories/mnemonic_repository.dart';
import 'package:example/services/lightning_wallet_service.dart';
import 'package:ldk_node/ldk_node.dart';
import 'package:nwc_wallet/data/models/nwc_request.dart';
import 'package:nwc_wallet/nwc_wallet.dart';

abstract class NwcWalletService {
  Future<void> init();
  Future<NwcConnection> addConnection({
    required String name,
    required List<NwcMethod> permittedMethods,
  });
  Future<List<NwcConnectionEntity>> getSavedConnections();
}

class NwcWalletServiceImpl implements NwcWalletService {
  final LightningWalletService _lightningWalletService;
  final MnemonicRepository _mnemonicRepository;
  NwcWallet? _nwcWallet;
  StreamSubscription? _nwcRequestsSubscription;

  NwcWalletServiceImpl({
    required LightningWalletService lightningWalletService,
    required MnemonicRepository mnemonicRepository,
  })  : _lightningWalletService = lightningWalletService,
        _mnemonicRepository = mnemonicRepository;

  @override
  Future<void> init() async {
    NostrKeyPair? walletServiceKeypair;
    List<NwcConnection> connections =
        []; // Todo: get stored connections from repository

    final mnemonic =
        await _mnemonicRepository.getMnemonic(_lightningWalletService.alias);
    if (mnemonic != null && mnemonic.isNotEmpty) {
      walletServiceKeypair = NostrKeyPair.fromMnemonic(mnemonic);

      _nwcWallet = NwcWallet(
        walletNostrKeyPair: walletServiceKeypair,
        connections: connections,
      );

      print(
        'NwcWalletService: Wallet service initialized with pubkey: ${walletServiceKeypair.publicKey}',
      );

      // Start listening to incoming NWC requests
      _subscribeToNwcRequests();
    }
  }

  @override
  Future<NwcConnection> addConnection({
    required String name,
    required List<NwcMethod> permittedMethods,
  }) async {
    if (_nwcWallet == null) {
      throw 'NwcWalletService: Wallet service not initialized';
    }

    final newConnection =
        await _nwcWallet!.addConnection(permittedMethods: permittedMethods);

    // Todo: save connection to repository

    return newConnection;
  }

  @override
  Future<List<NwcConnectionEntity>> getSavedConnections() {
    return Future.value([]); // Todo: get stored connections from repository
  }

  void _subscribeToNwcRequests() {
    _nwcRequestsSubscription = _nwcWallet!.nwcRequests.listen(
      (request) async {
        print('NwcWalletService: Received NWC request: $request');
        switch (request.method) {
          case NwcMethod.getInfo:
            await _handleGetInfoRequest(request as NwcGetInfoRequest);
          case NwcMethod.getBalance:
            await _handleGetBalanceRequest(request as NwcGetBalanceRequest);
          case NwcMethod.makeInvoice:
            await _handleMakeInvoiceRequest(request as NwcMakeInvoiceRequest);
          case NwcMethod.lookupInvoice:
            await _handleLookupInvoiceRequest(
                request as NwcLookupInvoiceRequest);
          case NwcMethod.payInvoice:
            await _handlePayInvoiceRequest(request as NwcPayInvoiceRequest);
          //case NwcMethod.multiPayInvoice:
          //  await _handleMultiPayInvoiceRequest(
          //      request as NwcMultiPayInvoiceRequest);
          //case NwcMethod.payKeysend:
          //  await _handlePayKeysendRequest(request as NwcPayKeysendRequest);
          //case NwcMethod.multiPayKeysend:
          //  await _handleMultiPayKeysendRequest(
          //      request as NwcMultiPayKeysendRequest);
          //case NwcMethod.listTransactions:
          //  await _handleListTransactionsRequest(
          //      request as NwcListTransactionsRequest);
          default:
            print(
                'NwcWalletService: Unknown NWC request method: ${request.method}');
        }
      },
      onError: (e) {
        print('NwcWalletService: Error listening to NWC requests: $e');
      },
      onDone: () {
        print('NwcWalletService: Done listening to NWC requests');
      },
    );
  }

  Future<void> _handleGetInfoRequest(NwcGetInfoRequest request) async {
    try {
      final alias = _lightningWalletService.alias;
      final color = _lightningWalletService.color;
      final pubkey = await _lightningWalletService.nodeId;
      final network = _lightningWalletService.network;
      final blockHeight = await _lightningWalletService.blockHeight;
      final blockHash = await _lightningWalletService.blockHash;

      // Todo: get permitted methods from connection entity
      final permittedMethods = [
        NwcMethod.getInfo,
        NwcMethod.getBalance,
        NwcMethod.makeInvoice,
        NwcMethod.lookupInvoice,
        NwcMethod.payInvoice,
        NwcMethod.multiPayInvoice,
        NwcMethod.payKeysend,
        NwcMethod.multiPayKeysend,
        NwcMethod.listTransactions,
      ];

      await _nwcWallet!.getInfoRequestHandled(
        request,
        alias: alias,
        color: color,
        pubkey: pubkey,
        network: network,
        blockHeight: blockHeight,
        blockHash: blockHash,
        methods: permittedMethods,
      );
    } catch (e) {
      print('NwcWalletService: Error handling getInfo request: $e');
      await _nwcWallet!.failedToHandleRequest(
        request,
        error: NwcErrorCode.internal,
      );
    }
  }

  Future<void> _handleGetBalanceRequest(NwcGetBalanceRequest request) async {
    try {
      final balance = await _lightningWalletService.spendableBalanceSat;
      await _nwcWallet!.getBalanceRequestHandled(request, balanceSat: balance);
    } catch (e) {
      print('NwcWalletService: Error handling getBalance request: $e');
      await _nwcWallet!.failedToHandleRequest(
        request,
        error: NwcErrorCode.internal,
      );
    }
  }

  Future<void> _handleMakeInvoiceRequest(NwcMakeInvoiceRequest request) async {
    try {
      final (_, bolt11Invoice) = await _lightningWalletService.generateInvoices(
        amountSat: request.amount,
        description: request.description,
        expirySecs: request.expiry,
      );

      if (bolt11Invoice == null) {
        throw 'Failed to generate invoice';
      }

      final paymentRequest = Bolt11PaymentRequest(bolt11Invoice);
      final String paymentHash = paymentRequest.tags
          .where((tag) => tag.type == 'payment_hash')
          .first
          .data;
      final int expiry =
          paymentRequest.tags.where((tag) => tag.type == 'expiry').first.data;
      final amountSat = paymentRequest.amount.toBigInt() * BigInt.from(10 ^ 8);
      await _nwcWallet!.makeInvoiceRequestHandled(
        request,
        invoice: bolt11Invoice,
        paymentHash: paymentHash,
        amountSat: amountSat.toInt(),
        feesPaidSat: 0,
        createdAt: paymentRequest.timestamp.toInt(),
        expiresAt: expiry,
        metadata: {},
      );
    } catch (e) {
      print('NwcWalletService: Error handling makeInvoice request: $e');
      await _nwcWallet!.failedToHandleRequest(
        request,
        error: NwcErrorCode.internal,
      );
    }
  }

  Future<void> _handleLookupInvoiceRequest(
    NwcLookupInvoiceRequest request,
  ) async {
    try {
      if (request.paymentHash == null && request.invoice == null) {
        throw 'Missing both paymentHash and invoice';
      }
      String? id = request.paymentHash;
      int? expiry;
      int? createdAt;
      if (id == null) {
        final paymentRequest = Bolt11PaymentRequest(request.invoice!);
        id = paymentRequest.tags
            .where((tag) => tag.type == 'payment_hash')
            .first
            .data;
        createdAt = paymentRequest.timestamp.toInt();
        expiry =
            paymentRequest.tags.where((tag) => tag.type == 'expiry').first.data;
      }
      final payment = await _lightningWalletService.getTransactionById(id!);

      if (payment == null) {
        throw InvoiceNotFoundException('Invoice not found');
      }

      await _nwcWallet!.lookupInvoiceRequestHandled(
        request,
        invoice: request.invoice,
        paymentHash: id,
        preimage: payment.preimage,
        amountSat: payment.amountSat ?? 0,
        feesPaidSat: 0,
        createdAt: createdAt ??
            payment.timestamp ??
            DateTime.now().millisecondsSinceEpoch ~/
                1000, // ldk_node_flutter doesn't return timestamp
        expiresAt: expiry,
        settledAt: payment.isPaid == true
            ? DateTime.now().millisecondsSinceEpoch ~/
                1000 // ldk_node_flutter doesn't return settled timestamp
            : null,
        metadata: {},
      );
    } catch (e) {
      print('NwcWalletService: Error handling lookupInvoice request: $e');
      if (e is InvoiceNotFoundException) {
        await _nwcWallet!.failedToHandleRequest(
          request,
          error: NwcErrorCode.notFound,
        );
      } else {
        await _nwcWallet!.failedToHandleRequest(
          request,
          error: NwcErrorCode.internal,
        );
      }
    }
  }

  Future<void> _handlePayInvoiceRequest(NwcPayInvoiceRequest request) async {
    try {
      final balance = await _lightningWalletService.spendableBalanceSat;
      final invoiceAmount = 0; // Todo: parse invoice amount from request
      if (balance < invoiceAmount) {
        throw InsufficientBalanceException('Insufficient balance');
      }

      String hash;
      try {
        hash = await _lightningWalletService.pay(
          request.invoice,
        );
      } catch (e) {
        throw FailedToPayInvoiceException('Failed to pay invoice');
      }

      // Wait a bit for the payment to be processed and be available in the list of transactions
      await Future.delayed(const Duration(seconds: 2));

      final paymentDetails =
          await _lightningWalletService.getTransactionById(hash);

      if (paymentDetails == null || paymentDetails.preimage == null) {
        throw 'Failed to get payment details';
      }

      await _nwcWallet!.payInvoiceRequestHandled(
        request,
        preimage: paymentDetails.preimage!,
      );
    } catch (e) {
      print('NwcWalletService: Error handling payInvoice request: $e');
      if (e is InsufficientBalanceException) {
        await _nwcWallet!.failedToHandleRequest(
          request,
          error: NwcErrorCode.insufficientBalance,
        );
      } else if (e is FailedToPayInvoiceException) {
        await _nwcWallet!.failedToHandleRequest(
          request,
          error: NwcErrorCode.paymentFailed,
        );
      } else {
        await _nwcWallet!.failedToHandleRequest(
          request,
          error: NwcErrorCode.internal,
        );
      }
    }
  }
}

class InvoiceNotFoundException implements Exception {
  final String message;

  InvoiceNotFoundException(this.message);
}

class InsufficientBalanceException implements Exception {
  final String message;

  InsufficientBalanceException(this.message);
}

class FailedToPayInvoiceException implements Exception {
  final String message;

  FailedToPayInvoiceException(this.message);
}
