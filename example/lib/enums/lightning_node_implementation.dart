enum LightningNodeImplementation {
  ldkNode('LDK Node', 'assets/logos/ldk_node.png'),
  breezSdk('Breez SDK', 'assets/logos/breez_sdk.png');

  final String label;
  final String logoPath;

  const LightningNodeImplementation(this.label, this.logoPath);
}
