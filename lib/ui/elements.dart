import 'package:flutter/material.dart';
import 'package:v2x_pilot/provider/pilot.dart';
import 'package:provider/provider.dart';

class V2XLoadingIndicator extends StatelessWidget {
  const V2XLoadingIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Image(
          image: AssetImage('assets/icons/smartcar.png'),
          height: 100,
        ),
        SizedBox(
          height: 20,
        ),
        CircularProgressIndicator(),
      ],
    );
  }
}

class PilotDataWidget extends StatefulWidget {
  const PilotDataWidget({Key? key}) : super(key: key);

  @override
  State<PilotDataWidget> createState() => _PilotDataWidgetState();
}

class _PilotDataWidgetState extends State<PilotDataWidget> {
  @override
  Widget build(BuildContext context) {
    if (context.watch<PilotProvider>().currentApproachLane == 0) {
      return Text("No approach detected!");
    } else {
      return Column(
        children: [
          Text("Approach ID: " +
              context.watch<PilotProvider>().currentApproachLane.toString()),
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
      );
    }
  }
}
