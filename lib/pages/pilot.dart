import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:v2x_pilot/controller.dart';
import 'package:v2x_pilot/models/signal_group.dart';
import 'package:provider/provider.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as toolkit;
import 'package:v2x_pilot/provider/pilot.dart';

import '/models/lane.dart';
import '/controller.dart';
import '/util/queries.dart';
import '/provider/settings.dart';
import '/ui/dialogs.dart';
import '/ui/elements.dart';

class PilotPage extends StatefulWidget {
  const PilotPage({Key? key}) : super(key: key);

  @override
  State<PilotPage> createState() => _PilotPageState();
}

class _PilotPageState extends State<PilotPage> {
  CameraPosition init = const CameraPosition(
      target: LatLng(47.655013328784996, 9.482121257439589), zoom: 12);
  final Completer<GoogleMapController> _controller = Completer();
  final Location _location = Location();

  @override
  Widget build(BuildContext context) {
    // Create GraphQL client by using the server url from the settings
    HttpLink link = HttpLink(context.watch<AppSettings>().serverURL);
    ValueNotifier<GraphQLClient> client = ValueNotifier(
        GraphQLClient(cache: GraphQLCache(store: HiveStore()), link: link));

    return GraphQLProvider(
        client: client,
        child: Query(
            options: QueryOptions(
                // Use signal intersection query from util package
                document: gql(readIntersection),
                variables: const {
                  // TODO: Implement intersection selection
                  'intersection': 309,
                },
                fetchPolicy: FetchPolicy.noCache
                //pollInterval: const Duration(seconds: 10),
                ),
            builder: (QueryResult intersectionResult,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (intersectionResult.hasException) {
                //return Text(intersectionResult.exception.toString());
                // TODO: Error handling
                return ConnectionDialog(context: context);
              }

              if (intersectionResult.isLoading) {
                return const V2XLoadingIndicator();
              }

              // Resolve and map api response
              LaneCollection laneCollection =
                  BackendController().getLaneCollection(intersectionResult);

              Marker refMarker = Marker(
                  markerId: const MarkerId('refMarker'),
                  position: laneCollection.refPosition);
              List<Marker> markers = [refMarker];

              // Second provider for fetching signal group data
              return GraphQLProvider(
                  client: client,
                  child: Query(
                      options: QueryOptions(
                        // Use signal group query from util package
                        document: gql(readSignalGroups),
                        // TODO: Implement intersection selection
                        variables: const {
                          'intersection': 309,
                        },
                        // TODO: Investigate best cache strategy
                        fetchPolicy: FetchPolicy.noCache,
                        // TODO: Change the poll duration for live data
                        pollInterval: const Duration(milliseconds: 800),
                      ),
                      builder: (QueryResult result,
                          {VoidCallback? refetch, FetchMore? fetchMore}) {
                        if (result.hasException) {
                          //return Text(result.exception.toString());
                          // TODO: Error handling
                          return ConnectionDialog(context: context);
                        }

                        if (result.isLoading) {
                          return const V2XLoadingIndicator();
                        }

                        // Resolve and map api response
                        SignalGroupCollection signalGroupCollection =
                            BackendController().getSignalGroupCollection(
                                result, laneCollection.lanes, context);

                        return Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            const SizedBox(
                              height: 16,
                            ),
                            PilotDataWidget(
                              approachList: laneCollection.approaches,
                              signalGroupCollection: signalGroupCollection,
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GoogleMap(
                                  markers: markers.toSet(),
                                  polylines:
                                      laneCollection.getPolylines().toSet(),
                                  mapType: MapType.satellite,
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: true,
                                  initialCameraPosition: init,
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    _location.onLocationChanged.listen((l) {
                                      int currentApproachLane =
                                          getApproachId(laneCollection, l);
                                      context
                                          .read<PilotProvider>()
                                          .setCurrentApproachLane(
                                              currentApproachLane);
                                      context
                                          .read<PilotProvider>()
                                          .setCurrentPosition(LatLng(
                                              l.latitude!, l.longitude!));
                                      controller.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: LatLng(
                                                  l.latitude!, l.longitude!),
                                              zoom: 19.8,
                                              tilt: 40,
                                              bearing: l.heading!),
                                        ),
                                      );
                                    });
                                    _controller.complete(controller);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ));
                      }));
            }));
  }

  /// Check if the specified location is close to any approaching lanes
  int getApproachId(LaneCollection collection, LocationData locationData) {
    int approachId = 0;
    for (var lane in collection.lanes) {
      var toolkitNodes = <toolkit.LatLng>[];
      for (var node in lane.nodes) {
        toolkitNodes.add(toolkit.LatLng(node.latitude, node.longitude));
      }

      // set current approach ID if lane lane is within tolerance of X meters
      if (toolkit.PolygonUtil.isLocationOnPath(
          toolkit.LatLng(locationData.latitude!, locationData.longitude!),
          toolkitNodes,
          true,
          tolerance: context.read<AppSettings>().gpsTolerance)) {
        if (lane.ingressApproachId != null) {
          approachId = lane.ingressApproachId!;
        }
      }
    }
    return approachId;
  }
}
