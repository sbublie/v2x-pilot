import 'package:flutter/material.dart';
import 'package:v2x_pilot/models/approach.dart';
import 'package:v2x_pilot/models/signal_group.dart';
import 'package:v2x_pilot/provider/pilot.dart';
import 'package:provider/provider.dart';

import '../util/lsa309_util.dart';
import '../util/time_util.dart';

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
          ],
        );
      }
    }

    return const Text("Error in matching approaches!");
  }

  Widget getSignalArrow(int approachId, int signalGroupId) {
    Image selIcon = Image.asset("assets/turn_straight.png");
    Color signalColor = Colors.grey;
    String remainingTime = "No data!";

    for (SignalGroup signalGroup in widget.signalGroupCollection.signalGroups) {
      if (signalGroup.id == signalGroupId) {
        if (signalGroup.likelyTime != null) {
          remainingTime =
              getRemainingTime(signalGroup.likelyTime!).toString() + "s";
        }
        signalColor = signalGroup.state!.color();
      }
    }

    selIcon = Image.asset(
      LSA309Util.getIconAsset(approachId, signalGroupId),
      color: signalColor,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: selIcon,
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const Icon(
                Icons.timer_rounded,
                size: 50,
              ),
              Text(
                remainingTime,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (context.watch<PilotProvider>().currentApproachLane == 0) {
      return const Text(
        "No approach detected!",
        style: TextStyle(fontSize: 25),
      );
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
