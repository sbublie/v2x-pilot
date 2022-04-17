import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:provider/provider.dart';

import '/provider/settings.dart';

class ConnectionDialog extends StatefulWidget {
  final BuildContext context;

  const ConnectionDialog({Key? key, required this.context}) : super(key: key);

  @override
  State<ConnectionDialog> createState() => _ConnectionDialogState();
}

class _ConnectionDialogState extends State<ConnectionDialog> {
  String textValue = "http://127.0.0.1:5000/graphql";

  @override
  Widget build(BuildContext ctx) {
    return AlertDialog(
      title: const Text('V2X-Server can\'t be reached!'),
      content: Container(
        constraints: BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Divider(height: 20, color: Colors.grey),
            const Text(
              "Please enter the address under which the V2X-Server is running. Make sure to connect both devices to the same network.",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
                initialValue: context.watch<AppSettings>().serverURL,
                onChanged: (input) {
                  textValue = input;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'V2X-Server Address',
                )),
            Divider(
              height: 25,
              color: Colors.grey,
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                context.read<AppSettings>().setServerURL(textValue);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsDialog extends StatefulWidget {
  final BuildContext context;

  const SettingsDialog({Key? key, required this.context}) : super(key: key);

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  String textValue = "http://127.0.0.1:5000/graphql";

  @override
  Widget build(BuildContext ctx) {
    return AlertDialog(
      title: const Text('Settings'),
      content: Container(
        constraints: BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //Divider(height: 20, color: Colors.grey),
            const Text(
              "Enter the address under which the V2X-Server is running. Make sure to connect both devices to the same network.",
              style: TextStyle(fontSize: 15),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
                initialValue: context.watch<AppSettings>().serverURL,
                onChanged: (input) {
                  textValue = input;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'V2X-Server Address',
                )),
            Divider(
              height: 25,
              color: Colors.grey,
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                context.read<AppSettings>().setServerURL(textValue);
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
