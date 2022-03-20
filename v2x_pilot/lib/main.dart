import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:v2x_pilot/controller.dart';
import 'package:v2x_pilot/models/signal_group.dart';
import 'models/lane.dart';
import 'controller.dart';

import 'dart:async';

void main() async {
  await initHiveForFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

final httpLink = HttpLink("http://localhost:5000/graphql");
ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(cache: GraphQLCache(store: HiveStore()), link: httpLink));

class _MyHomePageState extends State<MyHomePage> {
  final Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
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
                return Text(intersectionResult.exception.toString());
              }

              if (intersectionResult.isLoading) {
                return const Text('Loading');
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
                        return Text(result.exception.toString());
                      }

                      if (result.isLoading) {
                        return const Text('Loading');
                      }

                      SignalGroupCollection signalGroupCollection =
                          BackendController().getSignalGroupCollection(
                              result, laneCollection.lanes, context);

                      return Scaffold(
                        body: GoogleMap(
                          markers: markers.toSet(),
                          polylines: laneCollection.getPolylines().toSet(),
                          mapType: MapType.satellite,
                          circles: signalGroupCollection.circles.toSet(),
                          initialCameraPosition: initialPosition,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                          },
                        ),
                      );
                    },
                  ));
            }));
  }
}

String readIntersection = """
query GetIntersection(\$intersection: ID!){
  messages {
    messages {intersection_id, spat_available, map_available}
  }
  intersection(intersectionId: \$intersection) {
    item {
      ref_position{lat, long},
      lanes {
        id,
        type,
        ingress_approach_id,
        egress_approach_id,
        approach_type
        shared_with_id,
        maneuver_id,
        connects_to {lane_id, maneuver_id, signal_group_id},
        nodes {
          offset{
            x,
            y
          }
        }
      }
    }
  }
}
""";

String readSignalGroups = '''
query GetSignalGroups(\$intersection: ID!){
  intersection(intersectionId: \$intersection) {
    item {
      signal_groups {
        id,
        state,
        min_end_time, 
        max_end_time,
        likely_time,
        confidence
      }     
    }
  }
}
''';
