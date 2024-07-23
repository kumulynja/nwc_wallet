import 'package:example/constants/app_sizes.dart';
import 'package:example/features/nwc/connections/nwc_connections_controller.dart';
import 'package:example/features/nwc/connections/nwc_connections_state.dart';
import 'package:example/services/nwc_wallet_service/nwc_wallet_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NwcConnectionsBottomSheet extends StatefulWidget {
  const NwcConnectionsBottomSheet({
    required this.nwcWalletService,
    super.key,
  });

  final NwcWalletService nwcWalletService;

  @override
  NwcConnectionsBottomSheetState createState() =>
      NwcConnectionsBottomSheetState();
}

class NwcConnectionsBottomSheetState extends State<NwcConnectionsBottomSheet> {
  NwcConnectionsState _state = NwcConnectionsState();
  late NwcConnectionsController _controller;

  @override
  void initState() {
    super.initState();

    _controller = NwcConnectionsController(
      getState: () => _state,
      updateState: (NwcConnectionsState state) =>
          setState(() => _state = state),
      nwcWalletService: widget.nwcWalletService,
    );
    _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: const [
          CloseButton(),
        ],
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.kSpacingUnit * 4),
        child: ListView(
          children: [
            NewConnectionRow(
              setConnectionName: _controller.setNewConnectionName,
              onAddNewConnection: _controller.addNewConnection,
            ),
          ],
        ),
      ),
    );
  }
}

class NewConnectionRow extends StatelessWidget {
  const NewConnectionRow({
    required this.setConnectionName,
    required this.onAddNewConnection,
    super.key,
  });

  final void Function(String) setConnectionName;
  final Future<String> Function() onAddNewConnection;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add new connection',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8.0),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'My favorite NWC app...',
                    border: OutlineInputBorder(),
                    helper: Text('Set a name for the connection.'),
                  ),
                  onChanged: setConnectionName,
                ),
                const SizedBox(height: 16.0),
                /*Text(
                  'Permissions:',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                ...NwcMethod.values
                    .where((method) => method != NwcMethod.unknown)
                    .map((method) {
                  return CheckboxListTile(
                    title: Text(method.plaintext),
                    value: false,
                    onChanged: (bool? value) {},
                  );
                }).toList(),
                const SizedBox(height: 16.0),*/
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      final uri = await onAddNewConnection();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          action: SnackBarAction(
                            label: 'Copy',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: uri));
                            },
                          ),
                          content: Text('Connection created: $uri'),
                        ),
                      );
                    } catch (e) {
                      print(e);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to create connection.'),
                        ),
                      );
                    }
                  },
                  label: const Text('Get new connection URI'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
