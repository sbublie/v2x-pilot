import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class Enum<T> {
  final T value;

  const Enum(this.value);
}

class LaneType<int> extends Enum<int> {
  const LaneType(int val) : super(val);

  static const LaneType vehicleLane = LaneType(0);
  static const LaneType bikeLane = LaneType(1);
  static const LaneType crosswalk = LaneType(2);
}

class LaneCollection {
  final List<Lane> lanes;
  final LatLng refPosition;

  List<Polyline> getPolylines() {
    List<Polyline> polylines = [];
    for (Lane lane in lanes) {
      polylines.add(lane.polyline);
    }
    return polylines;
  }

  LaneCollection(this.lanes, this.refPosition);
}

class Lane {
  final int id;
  final LaneType type;
  final List<LatLng> nodes;
  final int? signalGroupId;
  final int? ingressApproachId;
  final int? egressApproachId;
  final int? approachType;
  final int? sharedWithId;
  final int? maneuverId;
  final Polyline polyline;

  Lane(
      this.id,
      this.type,
      this.nodes,
      this.signalGroupId,
      this.ingressApproachId,
      this.egressApproachId,
      this.approachType,
      this.sharedWithId,
      this.maneuverId,
      this.polyline);
}
