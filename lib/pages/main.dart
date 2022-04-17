import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:v2x_pilot/controller.dart';
import 'package:v2x_pilot/models/signal_group.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';

import 'package:provider/provider.dart';

import '/models/lane.dart';
import '/controller.dart';
import '/provider/settings.dart';
import '/util/queries.dart';
import '/ui/dialogs.dart';

import 'dart:async';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Completer<GoogleMapController> _controller = Completer();
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    HttpLink link = HttpLink(context.watch<AppSettings>().serverURL);
    ValueNotifier<GraphQLClient> client = ValueNotifier(
        GraphQLClient(cache: GraphQLCache(store: HiveStore()), link: link));

    return Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return SettingsDialog(
                    context: context,
                  );
                },
              );
            },
          ),
        ),
        bottomNavigationBar: SizedBox(
          height: 90,
          child: FloatingNavbar(
            width: 250,
            backgroundColor: Colors.white,
            selectedItemColor: Colors.blue,
            selectedBackgroundColor: Colors.grey[400],
            unselectedItemColor: Colors.black,
            onTap: (int val) => setState(() => _index = val),
            currentIndex: _index,
            items: [
              FloatingNavbarItem(
                icon: Icons.map,
                title: 'Map',
              ),
              FloatingNavbarItem(
                icon: Icons.fork_left,
                title: 'Pilot',
              ),
            ],
          ),
        ),
        body: GraphQLProvider(
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
                })));
  }
}
