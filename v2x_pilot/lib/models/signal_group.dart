import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SignalGroupState {
  final int state;
  SignalGroupState(this.state);

  Color color() {
    switch (state) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.red;
      case 4:
        return Colors.black;
      default:
        return Colors.white;
    }
  }
}

class SignalGroupCollection {
  final List<SignalGroup> signalGroups;
  final List<Circle> circles;
  SignalGroupCollection(this.signalGroups, this.circles);
}

class SignalGroup {
  final int id;
  SignalGroupState? state;
  int? minEndTime;
  int? maxEndTime;
  int? likelyTime;
  int? confidence;
  final LatLng position;
  Circle circle;

  SignalGroup(this.id, this.state, this.minEndTime, this.maxEndTime,
      this.likelyTime, this.confidence, this.position, this.circle);
}
