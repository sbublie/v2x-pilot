import 'package:flutter/material.dart';

class PilotPage extends StatefulWidget {
  const PilotPage({Key? key}) : super(key: key);

  @override
  State<PilotPage> createState() => _PilotPageState();
}

class _PilotPageState extends State<PilotPage> {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Coming soon!',
      style: TextStyle(fontSize: 20),
    );
  }
}
