//--no-sound-null-safety

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:mapfollow2/datamodels/user_location.dart';
import 'package:mapfollow2/datamodels/views/animarkerExample.dart';
import 'package:mapfollow2/datamodels/views/homepage.dart';
import 'package:mapfollow2/datamodels/views/loginPage.dart';
import 'package:mapfollow2/datamodels/views/trackLocation.dart';
import 'package:mapfollow2/services/location_service.dart';
import 'package:mapfollow2/test/testPage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  /*@override
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
  }*/

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: welcomePage(),
      home: loginPage(),
    );
  }
}

class welcomePage extends StatefulWidget {
  const welcomePage({Key? key}) : super(key: key);

  @override
  State<welcomePage> createState() => _welcomePageState();
}

class _welcomePageState extends State<welcomePage> {
  Location location = new Location();
  bool isOn = false;
  bool isTurnedOn = false;

  showAlertDialog(BuildContext context) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Success"),
      content: const Text("Location Enabled"),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Turn on Location:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.25,
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: ElevatedButton(
                      onPressed: isTurnedOn == false && isOn == false
                          ? () async {
                              isOn = await location.serviceEnabled();
                              if (!isOn) {
                                //if defvice is off
                                isTurnedOn = await location.requestService();
                                if (isTurnedOn) {
                                  print("GPS device is turned ON");
                                } else {
                                  print("GPS Device is still OFF");
                                }
                              }
                              setState(() {});
                              showAlertDialog(context);
                            }
                          : null,
                      child: const Text(
                        'Turn On',
                        style: TextStyle(fontSize: 15),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(29)),
                        primary: Color.fromARGB(255, 95, 80, 229),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Image.asset('assets/illustration.png'),
              const SizedBox(
                height: 10,
              ),
              const Text('Welcome!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              const SizedBox(
                height: 10,
              ),
              const Text('What would you like to do?',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
              const SizedBox(height: 25),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.06,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const testPage()));
                  },
                  child: const Text(
                    'Alarm',
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(29)),
                    primary: Color.fromARGB(255, 95, 80, 229),
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.06,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const trackLocation()));
                  },
                  child: const Text(
                    'Track Location',
                    style: TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(29)),
                    primary: Color.fromARGB(255, 95, 80, 229),
                  ),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
