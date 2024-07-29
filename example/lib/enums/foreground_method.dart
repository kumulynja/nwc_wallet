enum ForegroundMethod {
  init('init'),
  addConnection('addConnection'),
  addWallet('addWallet'),
  hasWallet('hasWallet'),
  alias('alias'),
  color('color'),
  nodeId('nodeId'),
  network('network'),
  blockHeight('blockHeight'),
  blockHash('blockHash'),
  deleteWallet('deleteWallet'),
  sync('sync'),
  spendableBalanceSat('spendableBalanceSat'),
  inboundLiquiditySat('inboundLiquiditySat'),
  generateInvoices('generateInvoices'),
  totalOnChainBalanceSat('totalOnChainBalanceSat'),
  spendableOnChainBalanceSat('spendableOnChainBalanceSat'),
  drainOnChainFunds('drainOnChainFunds'),
  sendOnChainFunds('sendOnChainFunds'),
  openChannel('openChannel'),
  pay('pay'),
  getTransactions('getTransactions'),
  getTransactionById('getTransactionById');

  final String plaintext;

  const ForegroundMethod(this.plaintext);

  factory ForegroundMethod.fromPlaintext(String plaintext) {
    switch (plaintext) {
      case 'init':
        return ForegroundMethod.init;
      case 'addConnection':
        return ForegroundMethod.addConnection;
      case 'addWallet':
        return ForegroundMethod.addWallet;
      case 'hasWallet':
        return ForegroundMethod.hasWallet;
      case 'alias':
        return ForegroundMethod.alias;
      case 'color':
        return ForegroundMethod.color;
      case 'nodeId':
        return ForegroundMethod.nodeId;
      case 'network':
        return ForegroundMethod.network;
      case 'blockHeight':
        return ForegroundMethod.blockHeight;
      case 'blockHash':
        return ForegroundMethod.blockHash;
      case 'deleteWallet':
        return ForegroundMethod.deleteWallet;
      case 'sync':
        return ForegroundMethod.sync;
      case 'spendableBalanceSat':
        return ForegroundMethod.spendableBalanceSat;
      case 'inboundLiquiditySat':
        return ForegroundMethod.inboundLiquiditySat;
      case 'generateInvoices':
        return ForegroundMethod.generateInvoices;
      case 'totalOnChainBalanceSat':
        return ForegroundMethod.totalOnChainBalanceSat;
      case 'spendableOnChainBalanceSat':
        return ForegroundMethod.spendableOnChainBalanceSat;
      case 'drainOnChainFunds':
        return ForegroundMethod.drainOnChainFunds;
      case 'sendOnChainFunds':
        return ForegroundMethod.sendOnChainFunds;
      case 'openChannel':
        return ForegroundMethod.openChannel;
      case 'pay':
        return ForegroundMethod.pay;
      case 'getTransactions':
        return ForegroundMethod.getTransactions;
      case 'getTransactionById':
        return ForegroundMethod.getTransactionById;
      default:
        throw Exception('Unknown ForegroundMethod: $plaintext');
    }
  }
}
