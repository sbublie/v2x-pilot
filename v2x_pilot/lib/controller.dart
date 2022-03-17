import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:v2x_pilot/models/lane.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:v2x_pilot/models/signal_group.dart';
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

      ConnectsWith connectsWith = ConnectsWith(
          lane?['connects_to']?['lane_id'],
          lane?['connects_to']?['maneuver_id'],
          lane?['connects_to']?['signal_group_id']);

      Lane newLane = Lane(
          lane?['id'],
          LaneType(lane?['type']),
          nodesLatLong,
          connectsWith,
          lane?['ingress_approach_id'],
          lane?['egress_approach_id'],
          lane?['approach_type'],
          lane?['shared_with_id'],
          lane?['maneuver_id'],
          newPolyline);
      allLanes.add(newLane);
    });
    return LaneCollection(allLanes, refPosition);
  }

  SignalGroupCollection getSignalGroupCollection(
      QueryResult result, List<Lane> lanes) {
    List? signalGroups =
        result.data?['intersection']?['item']?['signal_groups'];
    List<SignalGroup> allSignalGroups = [];
    List<Circle> allCircles = [];
    signalGroups?.forEach((signalGroup) {
      lanes.forEach((Lane lane) {
        if (lane.ingressApproachId != null) {
          if (lane.connectsWith?.signalGroupId == signalGroup['id']) {
            LatLng position = lane.nodes.first;
            SignalGroupState state = SignalGroupState(signalGroup['state']);

            Circle newCircle = Circle(
                circleId: CircleId(signalGroup['id'].toString()),
                center: position,
                fillColor: state.color(),
                strokeColor: Colors.black,
                strokeWidth: 2,
                zIndex: 2,
                radius: 1);

            SignalGroup newSignalGroup = SignalGroup(
                signalGroup['id'],
                state,
                signalGroup['min_end_time'],
                signalGroup['max_end_time'],
                signalGroup['likely_time'],
                signalGroup['confidence'],
                position,
                newCircle);
            allCircles.add(newCircle);
            allSignalGroups.add(newSignalGroup);
          }
        }
      });
    });

    return SignalGroupCollection(allSignalGroups, allCircles);
  }
}
