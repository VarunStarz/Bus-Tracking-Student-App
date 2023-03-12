import 'package:flutter/material.dart';
import 'package:mapfollow2/datamodels/user_location.dart';
import 'package:provider/provider.dart';

import '../datamodels/views/homepage.dart';
import '../services/location_service.dart';

class testPage extends StatefulWidget {
  const testPage({Key? key}) : super(key: key);

  @override
  State<testPage> createState() => _testPageState();
}

class _testPageState extends State<testPage> {
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
