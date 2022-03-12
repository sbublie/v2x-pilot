import 'package:google_maps_flutter/google_maps_flutter.dart';

enum SignalGroupState {
  undefined,
  green,
  yellow,
  red,
  dark,
}

class SignalGroup {
  final int id;
  SignalGroupState state;
  int minEndTime;
  int maxEndTime;
  int likelyTime;
  int confidence;
  final LatLng position;
  Circle circle;

  SignalGroup(this.id, this.state, this.minEndTime, this.maxEndTime,
      this.likelyTime, this.confidence, this.position, this.circle);
}
