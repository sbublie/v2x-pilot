import 'package:v2x_pilot/models/lane.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'models/lane.dart';
import 'package:latlong2/latlong.dart' as latlong2;

class BackendController {
  LaneCollection getLaneCollection(QueryResult result) {
    double refPostionLat = result.data?['intersection']?['item']
            ?['ref_position']?['lat'] /
        10000000;
    double refPositionLong = result.data?['intersection']?['item']
            ?['ref_position']?['long'] /
        10000000;

    LatLng refPosition = LatLng(refPostionLat, refPositionLong);

    List<Lane> allLanes = [];

    List? lanes = result.data?['intersection']?['item']?['lanes'];
    lanes?.forEach((lane) {
      List? nodes = lane?['nodes'];
      List<LatLng> nodesLatLong = [];
      latlong2.LatLng lastPos = latlong2.LatLng(refPostionLat, refPositionLong);

      nodes?.forEach((node) {
        const latlong2.Distance distance = latlong2.Distance();
        latlong2.LatLng latOffset =
            distance.offset(lastPos, node?['offset']?['x'] / 100, 90);
        latlong2.LatLng currentPos =
            distance.offset(latOffset, node?['offset']?['y'] / 100, 0);
        lastPos = currentPos;
        nodesLatLong.add(LatLng(currentPos.latitude, currentPos.longitude));
      });

      Polyline newPolyline = Polyline(
          polylineId: PolylineId(lane['id'].toString()),
          points: nodesLatLong,
          //color: Colors.red,
          width: 5);

      Lane newLane = Lane(
          lane?['id'],
          LaneType(lane?['type']),
          nodesLatLong,
          lane?['signalGroupId'],
          lane?['ingressApproachId'],
          lane?['egressApproachId'],
          lane?['approachType'],
          lane?['sharedWithId'],
          lane?['maneuverId'],
          newPolyline);
      allLanes.add(newLane);
    });
    return LaneCollection(allLanes, refPosition);
  }
}
