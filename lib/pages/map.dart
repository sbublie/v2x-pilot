import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:v2x_pilot/controller.dart';
import 'package:v2x_pilot/models/signal_group.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '/models/lane.dart';
import '/controller.dart';
import '/provider/settings.dart';
import '/util/queries.dart';
import '/ui/dialogs.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  @override
  Widget build(BuildContext context) {
    HttpLink link = HttpLink(context.watch<AppSettings>().serverURL);
    ValueNotifier<GraphQLClient> client = ValueNotifier(
        GraphQLClient(cache: GraphQLCache(store: HiveStore()), link: link));
    return GraphQLProvider(
        client: client,
        child: Query(
            options: QueryOptions(
              document: gql(readIntersection),
              variables: {
                'intersection': 309,
              },
              //pollInterval: const Duration(seconds: 10),
            ),
            builder: (QueryResult intersectionResult,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (intersectionResult.hasException) {
                //return Text(intersectionResult.exception.toString());
                return ConnectionDialog(context: context);
              }

              if (intersectionResult.isLoading) {
                return const V2XLoadingIndicator();
              }

              LaneCollection laneCollection =
                  BackendController().getLaneCollection(intersectionResult);

              CameraPosition initialPosition = CameraPosition(
                target: laneCollection.refPosition,
                zoom: 20,
                tilt: 0,
              );

              Marker refMarker = Marker(
                  markerId: const MarkerId('refMarker'),
                  position: laneCollection.refPosition);
              List<Marker> markers = [refMarker];
              return GraphQLProvider(
                  client: client,
                  child: Query(
                    options: QueryOptions(
                      document: gql(readSignalGroups),
                      variables: {
                        'intersection': 309,
                      },
                      pollInterval: const Duration(seconds: 10),
                    ),
                    builder: (QueryResult result,
                        {VoidCallback? refetch, FetchMore? fetchMore}) {
                      if (result.hasException) {
                        //return Text(result.exception.toString());
                        return ConnectionDialog(context: context);
                      }

                      if (result.isLoading) {
                        return const V2XLoadingIndicator();
                      }

                      SignalGroupCollection signalGroupCollection =
                          BackendController().getSignalGroupCollection(
                              result, laneCollection.lanes, context);

                      return GoogleMap(
                        markers: markers.toSet(),
                        polylines: laneCollection.getPolylines().toSet(),
                        mapType: MapType.satellite,
                        circles: signalGroupCollection.circles.toSet(),
                        initialCameraPosition: initialPosition,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                      );
                    },
                  ));
            }));
  }
}
