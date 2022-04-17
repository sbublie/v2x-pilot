import 'package:flutter/material.dart';
import 'package:floating_bottom_navigation_bar/floating_bottom_navigation_bar.dart';

import '/ui/dialogs.dart';
import '/pages/map.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
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
        body: const MapPage());
  }
}
