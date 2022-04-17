import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import '/provider/settings.dart';
import '/pages/main.dart';

void main() async {
  await initHiveForFlutter();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => AppSettings()),
  ], child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'V2X-Pilot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}
