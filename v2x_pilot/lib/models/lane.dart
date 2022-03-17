import 'package:google_maps_flutter/google_maps_flutter.dart';

class LaneType {
  final int id;
  LaneType(this.id);

  String name() {
    switch (id) {
      case 0:
        return "Vehicle Lane";
      case 1:
        return "Bike Lane";
      case 2:
        return "Crosswalk";
      default:
        return "undefined";
    }
  }
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
  final ConnectsWith? connectsWith;
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
      this.connectsWith,
      this.ingressApproachId,
      this.egressApproachId,
      this.approachType,
      this.sharedWithId,
      this.maneuverId,
      this.polyline);
}

class ConnectsWith {
  final int? laneId;
  final int? maneuverId;
  final int? signalGroupId;

  ConnectsWith(this.laneId, this.maneuverId, this.signalGroupId);
}
