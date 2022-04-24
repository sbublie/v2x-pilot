import 'package:flutter/material.dart';

class PilotPage extends StatefulWidget {
  const PilotPage({Key? key}) : super(key: key);

  @override
  State<PilotPage> createState() => _PilotPageState();
}

class _PilotPageState extends State<PilotPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Approach ID: 12",
          style: TextStyle(fontSize: 20),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Icon(
                  Icons.arrow_back_rounded,
                  size: 150,
                  color: Colors.red,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      size: 50,
                    ),
                    Text(
                      "15s",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                )
              ],
            ),
            Column(
              children: [
                Icon(Icons.arrow_upward_rounded,
                    size: 150, color: Colors.green),
                Row(
                  children: [
                    Icon(
                      Icons.timer_rounded,
                      size: 50,
                    ),
                    Text("10s", style: TextStyle(fontSize: 18))
                  ],
                )
              ],
            ),
          ],
        ),
      ],
    ));
  }
}
