import 'dart:async';

import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:example/entities/nwc_connection_entity.dart';
import 'package:example/services/lightning_wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:nwc_wallet/nwc_wallet.dart';

abstract class NwcWalletHandlerService {
  Future<void> init();
  Future<NwcConnection> addConnection({
    required String name,
    required List<NwcMethod> permittedMethods,
  });
  Future<void> handleNwcRequest(NwcRequest request);
  Future<List<NwcConnectionEntity>> getSavedConnections();
}

class NwcWalletHandlerServiceImpl implements NwcWalletHandlerService {
  final LightningWalletService _lightningWalletService;

  NwcWalletHandlerServiceImpl({
    required LightningWalletService lightningWalletService,
  }) : _lightningWalletService = lightningWalletService;

  @override
  Future<void> init() async {
    // Todo: send data to foreground task to initialize nwc wallet service
  }

  @override
  Future<NwcConnection> addConnection({
    required String name,
    required List<NwcMethod> permittedMethods,
  }) async {
    // Todo: send data to foreground task to add connection

    // Todo: save connection to repository

    return newConnection;
  }

  @override
  Future<List<NwcConnectionEntity>> getSavedConnections() {
    return Future.value([]); // Todo: get stored connections from repository
  }

  @override
  Future<void> handleNwcRequest(NwcRequest request) async {
    switch (request.method) {
      case NwcMethod.getInfo:
        await _handleGetInfoRequest(request as NwcGetInfoRequest);
      case NwcMethod.getBalance:
        await _handleGetBalanceRequest(request as NwcGetBalanceRequest);
      case NwcMethod.makeInvoice:
        await _handleMakeInvoiceRequest(request as NwcMakeInvoiceRequest);
      case NwcMethod.lookupInvoice:
        await _handleLookupInvoiceRequest(request as NwcLookupInvoiceRequest);
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
      debugPrint('NwcWalletService: Handling getBalance request');
      final balance = await _lightningWalletService.spendableBalanceSat;
      debugPrint('NwcWalletService: Balance: $balance');
      await _nwcWallet!.getBalanceRequestHandled(request, balanceSat: balance);
      debugPrint('NwcWalletService: getBalance request handled');
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
        amountSat: request.amountSat,
        description: request.description,
        expirySecs: request.expiry,
      );

      if (bolt11Invoice == null || bolt11Invoice.isEmpty) {
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
      } else if (request.invoice != null) {
        // Parse the invoice
        final paymentRequest = Bolt11PaymentRequest(request.invoice!);
        final id = paymentRequest.tags
            .where((tag) => tag.type == 'payment_hash')
            .first
            .data;
        final createdAt = paymentRequest.timestamp.toInt();
        final expiryTag = paymentRequest.tags
            .where(
              (tag) => tag.type == 'expiry',
            )
            .first
            .data as int;
        final expiry = createdAt + expiryTag;
        final payment = await _lightningWalletService.getTransactionById(id!);

        if (payment == null) {
          throw InvoiceNotFoundException('Invoice not found');
        }

        return _nwcWallet!.lookupInvoiceRequestHandled(
          request,
          invoice: request.invoice,
          paymentHash: id,
          preimage: payment.preimage,
          amountSat: payment.amountSat ?? 0,
          feesPaidSat: 0,
          createdAt: createdAt,
          expiresAt: expiry,
          settledAt:
              payment.isPaid == true ? payment.latestUpdateTimestamp : null,
          metadata: {},
        );
      } else {
        final payment = await _lightningWalletService
            .getTransactionById(request.paymentHash!);

        if (payment == null) {
          throw InvoiceNotFoundException('Invoice not found');
        }

        await _nwcWallet!.lookupInvoiceRequestHandled(
          request,
          invoice: request.invoice,
          paymentHash: request.paymentHash!,
          preimage: payment.preimage,
          amountSat: payment.amountSat ?? 0,
          feesPaidSat: 0,
          createdAt: payment.timestamp ??
              payment
                  .latestUpdateTimestamp, // ldk_node_flutter doesn't return timestamp of creation separately, so this might not be entirely correct
          settledAt:
              payment.isPaid == true ? payment.latestUpdateTimestamp : null,
          metadata: {},
        );
      }
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
