import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '/models/lane.dart';
import '/controller.dart';
import '/provider/settings.dart';
import '/util/queries.dart';
import '/ui/dialogs.dart';
import '/ui/elements.dart';
import '/models/signal_group.dart';

/// Page to display a map containing important intersection data
class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller = Completer();
  @override
  Widget build(BuildContext context) {
    // Create GraphQL client by using the server url from the settings
    HttpLink link = HttpLink(context.watch<AppSettings>().serverURL);
    ValueNotifier<GraphQLClient> client = ValueNotifier(
        GraphQLClient(cache: GraphQLCache(store: HiveStore()), link: link));

    // First provider for fetching intersection data
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

              CameraPosition initialPosition = CameraPosition(
                target: laneCollection.refPosition,
                zoom: 20,
                tilt: 0,
              );

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
