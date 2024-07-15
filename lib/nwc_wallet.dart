library nwc_wallet;

// Export from other files
export 'enums/nwc_method.dart' show NwcMethod;
export 'enums/nwc_error_code.dart' show NwcErrorCode;
export 'enums/transaction_type.dart' show TransactionType;
export 'enums/bitcoin_network.dart' show BitcoinNetwork;
export 'data/models/nostr_key_pair.dart' show NostrKeyPair;
export 'data/models/transaction.dart' show Transaction;
export 'data/models/tlv_record.dart' show TlvRecord;
export 'data/models/nwc_connection.dart' show NwcConnection;
export 'data/models/nwc_request.dart'
    show
        NwcRequest,
        NwcGetInfoRequest,
        NwcGetBalanceRequest,
        NwcMakeInvoiceRequest,
        NwcPayInvoiceRequest,
        NwcMultiPayInvoiceRequest,
        NwcPayKeysendRequest,
        NwcMultiPayKeysendRequest,
        NwcLookupInvoiceRequest,
        NwcListTransactionsRequest;

import 'package:flutter/foundation.dart';
import 'package:nwc_wallet/constants/app_configs.dart';
import 'package:nwc_wallet/data/models/nostr_key_pair.dart';
import 'package:nwc_wallet/data/models/nwc_connection.dart';
import 'package:nwc_wallet/data/models/nwc_request.dart';
import 'package:nwc_wallet/data/models/nwc_response.dart';
import 'package:nwc_wallet/data/models/transaction.dart';
import 'package:nwc_wallet/data/providers/nostr_relay_provider.dart';
import 'package:nwc_wallet/data/repositories/nostr_repository.dart';
import 'package:nwc_wallet/enums/bitcoin_network.dart';
import 'package:nwc_wallet/enums/nwc_error_code.dart';
import 'package:nwc_wallet/enums/nwc_method.dart';
import 'package:nwc_wallet/services/nwc_service.dart';

class NwcWallet {
  // Private fields
  final String _relayUrl;
  final NostrKeyPair _walletNostrKeyPair;
  late NwcService _nwcService;

  // Public fields
  Stream<NwcRequest> get nwcRequests => _nwcService.nwcRequests;

  // Private constructor
  NwcWallet._(
    this._walletNostrKeyPair,
    this._relayUrl,
    List<NwcConnection> connections,
    int? lastRequestTimestamp,
  ) {
    _nwcService = NwcServiceImpl(
      _walletNostrKeyPair,
      NostrRepositoryImpl(
        NostrRelayProviderImpl(
          _relayUrl,
        ),
      ),
      connections,
      lastRequestTimestamp,
    );
  }

  // Singleton instance
  static NwcWallet? _instance;

  // Factory constructor
  factory NwcWallet({
    required NostrKeyPair walletNostrKeyPair,
    String relayUrl = AppConfigs.defaultRelayUrl,
    List<NwcConnection> connections = const [],
    int? lastRequestTimestamp,
  }) {
    _instance ??= NwcWallet._(
      walletNostrKeyPair,
      relayUrl,
      connections,
      lastRequestTimestamp,
    );
    return _instance!;
  }

  Future<NwcConnection> addConnection({
    required List<NwcMethod> permittedMethods,
  }) async {
    // If first active connection, connect the _nwcService
    if (_nwcService.connections.isEmpty) {
      await _nwcService.connect();
    }

    final connection = await _nwcService.addConnection(
      relayUrl: _relayUrl,
      permittedMethods: permittedMethods,
    );

    debugPrint('Connection URI: ${connection.uri}');

    return connection;
  }

  Future<void> removeConnection(String pubkey) async {
    _nwcService.removeConnection(pubkey);

    // Disconnect from the relay's websocket if no active connections left
    if (_nwcService.connections.isEmpty) {
      await _nwcService.disconnect();
    }
  }

  Future<void> getInfoRequestHandled(
    NwcGetInfoRequest request, {
    required String alias,
    required String color,
    required String pubkey,
    required BitcoinNetwork network,
    required int blockHeight,
    required String blockHash,
    required List<NwcMethod> methods,
  }) async {
    // Todo: Add parameter validation
    final response = NwcResponse.nwcGetInfoResponse(
      alias: alias,
      color: color,
      pubkey: pubkey,
      network: network,
      blockHeight: blockHeight,
      blockHash: blockHash,
      methods: methods,
    );

    await _nwcService.handleResponse(request: request, response: response);
  }

  Future<void> getBalanceRequestHandled(
    NwcGetBalanceRequest request, {
    required int balanceSat,
  }) async {
    final response = NwcResponse.nwcGetBalanceResponse(balanceSat: balanceSat);

    await _nwcService.handleResponse(request: request, response: response);
  }

  Future<void> makeInvoiceRequestHandled(
    NwcMakeInvoiceRequest request, {
    String? invoice,
    String? description,
    String? descriptionHash,
    String? preimage,
    required String paymentHash,
    required int amountSat,
    required int feesPaidSat,
    required int createdAt,
    required int expiresAt,
    required Map<dynamic, dynamic> metadata,
  }) async {
    final response = NwcResponse.nwcMakeInvoiceResponse(
      invoice: invoice,
      description: description,
      descriptionHash: descriptionHash,
      preimage: preimage,
      paymentHash: paymentHash,
      amountSat: amountSat,
      feesPaidSat: feesPaidSat,
      createdAt: createdAt,
      expiresAt: expiresAt,
      metadata: metadata,
    );

    await _nwcService.handleResponse(request: request, response: response);
  }

  Future<void> payInvoiceRequestHandled(
    NwcPayInvoiceRequest request, {
    required String preimage,
  }) async {
    final response = NwcResponse.nwcPayInvoiceResponse(preimage: preimage);

    await _nwcService.handleResponse(request: request, response: response);
  }

  Future<void> multiPayInvoiceRequestHandled(
    NwcMultiPayInvoiceRequest request, {
    required Map<String, String> preimageById,
  }) async {
    for (var entry in preimageById.entries) {
      final response = NwcResponse.nwcMultiPayInvoiceResponse(
        preimage: entry.value,
        id: entry.key,
      );

      await _nwcService.handleResponse(request: request, response: response);
    }
  }

  Future<void> payKeysendRequestHandled(
    NwcPayKeysendRequest request, {
    required String preimage,
  }) async {
    final response = NwcResponse.nwcPayKeysendResponse(preimage: preimage);

    await _nwcService.handleResponse(request: request, response: response);
  }

  Future<void> multiPayKeysendRequestHandled(
    NwcMultiPayKeysendRequest request, {
    required Map<String, String> preimageById,
  }) async {
    for (var entry in preimageById.entries) {
      final response = NwcResponse.nwcMultiPayKeysendResponse(
        preimage: entry.value,
        id: entry.key,
      );

      await _nwcService.handleResponse(request: request, response: response);
    }
  }

  Future<void> lookupInvoiceRequestHandled(
    NwcLookupInvoiceRequest request, {
    String? invoice,
    String? description,
    String? descriptionHash,
    String? preimage,
    required String paymentHash,
    required int amountSat,
    required int feesPaidSat,
    required int createdAt,
    int? expiresAt,
    int? settledAt,
    required Map<dynamic, dynamic> metadata,
  }) async {
    final response = NwcResponse.nwcLookupInvoiceResponse(
      invoice: invoice,
      description: description,
      descriptionHash: descriptionHash,
      preimage: preimage,
      paymentHash: paymentHash,
      amountSat: amountSat,
      feesPaidSat: feesPaidSat,
      createdAt: createdAt,
      expiresAt: expiresAt,
      settledAt: settledAt,
      metadata: metadata,
    );

    await _nwcService.handleResponse(request: request, response: response);
  }

  Future<void> listTransactionsRequestHandled(
    NwcListTransactionsRequest request, {
    required List<Transaction> transactions,
  }) async {
    final response =
        NwcResponse.nwcListTransactionsResponse(transactions: transactions);

    await _nwcService.handleResponse(request: request, response: response);
  }

  Future<void> failedToHandleRequest(
    NwcRequest request, {
    required NwcErrorCode error,
  }) async {
    final response = NwcResponse.nwcErrorResponse(
      method: request.method,
      error: error,
    );

    await _nwcService.handleResponse(request: request, response: response);
  }

  // After disposing, the instance is no longer usable
  Future<void> dispose() async {
    await _nwcService.dispose();
    _instance = null;
  }
}
