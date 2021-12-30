//--no-sound-null-safety

import 'package:flutter/material.dart';
import 'package:mapfollow2/datamodels/user_location.dart';
import 'package:mapfollow2/datamodels/views/homepage.dart';
import 'package:mapfollow2/services/location_service.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserLocation>(
      create: (_) => LocationService().locationStream,
      initialData: UserLocation(latitude: 0, longitude: 0),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Consumer<UserLocation>(
          builder: (context, position, widget) {
            return (position != null)
                ? HomePage(position)
                : Center(
                    child: CircularProgressIndicator(),
                  );
          },
        ),
      ),
    );
  }
}
