import 'package:flutter/material.dart';
import 'package:v2x_pilot/models/approach.dart';
import 'package:v2x_pilot/models/signal_group.dart';
import 'package:v2x_pilot/provider/pilot.dart';
import 'package:provider/provider.dart';

import '/util/const.dart';

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
  const PilotDataWidget(
      {Key? key,
      required this.approachList,
      required this.signalGroupCollection})
      : super(key: key);
  final List<Approach> approachList;
  final SignalGroupCollection signalGroupCollection;

  @override
  State<PilotDataWidget> createState() => _PilotDataWidgetState();
}

class _PilotDataWidgetState extends State<PilotDataWidget> {
  Widget getApproachData() {
    for (Approach approach in widget.approachList) {
      if (approach.id == context.watch<PilotProvider>().currentApproachLane) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int id in approach.signalGroupIds)
              getSignalArrow(approach.id, id)
            //Text("  " + approachTypesLSA309[approach.id]![id].toString())
          ],
        );
      }
    }

    return Text("Error in matching approaches!");
  }

  Widget getSignalArrow(int approachId, int signalGroupId) {
    IconData selIcon = Icons.error;
    Color signalColor = Colors.grey;
    String signalTime = "None";

    for (SignalGroup signalGroup in widget.signalGroupCollection.signalGroups) {
      if (signalGroup.id == signalGroupId) {
        signalColor = signalGroup.state!.color();
        signalTime = signalGroup.convertTime(signalGroup.likelyTime);
      }
    }

    if (approachTypesLSA309[approachId]![signalGroupId][0] == 'straight') {
      selIcon = Icons.arrow_upward_rounded;
    }
    if (approachTypesLSA309[approachId]![signalGroupId][0] == 'left') {
      selIcon = Icons.arrow_back_rounded;
    }

    return Column(
      children: [
        Icon(
          selIcon,
          size: 150,
          color: signalColor,
        ),
        Row(
          children: [
            Icon(
              Icons.timer_rounded,
              size: 50,
            ),
            Text(
              signalTime,
              style: TextStyle(fontSize: 18),
            ),
          ],
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<PilotProvider>().currentApproachLane == 0) {
      return Text("No approach detected!");
    } else {
      return Column(
        children: [
          Text("Approach ID: " +
              context.watch<PilotProvider>().currentApproachLane.toString()),
          getApproachData()
        ],
      );
    }
  }
}
