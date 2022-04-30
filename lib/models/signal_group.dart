import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class SignalGroupState {
  final String state;
  SignalGroupState(this.state);

  Color color() {
    switch (state) {
      case "GREEN":
        return Colors.green;
      case "YELLOW":
        return Colors.yellow;
      case "RED":
        return Colors.red;
      case "DARK":
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

  /// Convert intersection timestamp to date string
  String convertTime(timestamp) {
    if (timestamp == null) {
      return "No data";
    }
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
            .add(Duration(hours: 1));
    return DateFormat('HH:mm:ss').format(date);
  }

  String timeLeft(timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true)
        .subtract(Duration(hours: 1))
        .difference(DateTime.now())
        .inSeconds
        .toString();

    return DateTime.now()
        .add(Duration(hours: 1))
        .difference(
            DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true))
        .inSeconds
        .toString();
  }
}
