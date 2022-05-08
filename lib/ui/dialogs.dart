import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/provider/settings.dart';
import '/util/time_util.dart';

class ConnectionDialog extends StatefulWidget {
  final BuildContext context;

  const ConnectionDialog({Key? key, required this.context}) : super(key: key);

  @override
  State<ConnectionDialog> createState() => _ConnectionDialogState();
}

class _ConnectionDialogState extends State<ConnectionDialog> {
  @override
  Widget build(BuildContext ctx) {
    String textValue = context.read<AppSettings>().serverURL;
    return AlertDialog(
      title: const Text('V2X-Server can\'t be reached!'),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
                initialValue: textValue,
                onChanged: (input) {
                  textValue = input;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'V2X-Server Address',
                )),
            const Divider(
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
  @override
  Widget build(BuildContext ctx) {
    String textValue = context.read<AppSettings>().serverURL;
    return AlertDialog(
      title: const Text('Settings'),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 500),
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
                initialValue: textValue,
                onChanged: (input) {
                  textValue = input;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'V2X-Server Address',
                )),
            const Divider(
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

class SignalGroupDialog extends StatefulWidget {
  final BuildContext context;
  final dynamic signalGroup;

  const SignalGroupDialog(
      {Key? key, required this.context, required this.signalGroup})
      : super(key: key);

  @override
  State<SignalGroupDialog> createState() => _SignalGroupDialogState();
}

class _SignalGroupDialogState extends State<SignalGroupDialog> {
  @override
  Widget build(BuildContext ctx) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Signal Group " + widget.signalGroup['id'].toString(),
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            height: 8,
          ),
          Text("State: " + widget.signalGroup['state']),
          Text("Min End Time: " +
              getLabelFromTimestamp(widget.signalGroup['min_end_time'])),
          Text("Max End Time: " +
              getLabelFromTimestamp(widget.signalGroup['max_end_time'])),
          Text("Likely Time: " +
              getLabelFromTimestamp(widget.signalGroup['likely_time'])),
          Text("Confidence: " + widget.signalGroup['confidence'].toString())
        ],
      ),
    );
  }
}
