import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:v2x_pilot/controller.dart';
import 'package:v2x_pilot/models/signal_group.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';
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
      title: 'V2X Pilot',
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

class _MyHomePageState extends State<MyHomePage> {
  final Completer<GoogleMapController> _controller = Completer();
  int _index = 0;
  String backendURL = "http://127.0.0.1:5000/graphql";
  bool loading = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('V2X-Server URL'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Please enter the address under which the V2X-Server is running. Make sure to connect both devices to the same network.",
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                    initialValue: backendURL,
                    onChanged: (input) {
                      backendURL = input;
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'V2X-Server Address',
                    ))
              ],
            ),
            actions: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 4, 4),
                child: TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      loading = false;
                    });
                  },
                ),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    HttpLink link = HttpLink(backendURL);
    ValueNotifier<GraphQLClient> client = ValueNotifier(
        GraphQLClient(cache: GraphQLCache(store: HiveStore()), link: link));

    if (loading) {
      return Container();
    } else {
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
                            extendBody: true,
                            bottomNavigationBar: Container(
                              height: 90,
                              child: FloatingNavbar(
                                width: 250,
                                backgroundColor: Colors.white,
                                selectedItemColor: Colors.blue,
                                selectedBackgroundColor: Colors.grey[400],
                                unselectedItemColor: Colors.black,
                                onTap: (int val) =>
                                    setState(() => _index = val),
                                currentIndex: _index,
                                items: [
                                  FloatingNavbarItem(
                                    icon: Icons.map,
                                    title: 'Map',
                                  ),
                                  FloatingNavbarItem(
                                      icon: Icons.fork_left, title: 'Pilot'),
                                ],
                              ),
                            ),
                            body: GoogleMap(
                              markers: markers.toSet(),
                              polylines: laneCollection.getPolylines().toSet(),
                              mapType: MapType.satellite,
                              circles: signalGroupCollection.circles.toSet(),
                              initialCameraPosition: initialPosition,
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                            ));
                      },
                    ));
              }));
    }
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
