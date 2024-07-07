import 'dart:async';

import 'package:nwc_wallet/enums/nwc_method.dart';

abstract class NwcWalletService {
  Future<void> saveConnection({
    required String pubkey,
    required String name,
    required List<NwcMethod> permittedMethods,
  });
  Future<void> getConnections();
  Future<void> getInfo();
  Future<void> makeInvoice();
  Future<void> lookUpInvoice();
  Future<void> payInvoice();
  Future<void> multiPayInvoice();
  Future<void> payKeysend();
  Future<void> multiPayKeysend();
  Future<void> listTransactions();
}
