import 'dart:async';
//import 'package:bus_tracking_test/services/data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mapfollow2/main.dart';
import 'package:rxdart/rxdart.dart';

LocationData? currentLocation;

class trackLocation extends StatefulWidget {
  const trackLocation({Key? key}) : super(key: key);
  @override
  State<trackLocation> createState() => trackLocationState();
}

class trackLocationState extends State<trackLocation> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng sourceLocation = LatLng(13.0088029, 80.0054776);
  static const LatLng destination = LatLng(13.108818, 80.105423);

  LatLng? busLocation;
  Set<Marker> _markers = Set<Marker>();

  var busMarker;

  final _firestore = FirebaseFirestore.instance;
  GeoFlutterFire? geo;
  Stream<List<DocumentSnapshot>>? stream;
  final radius = BehaviorSubject<double>.seeded(1.0);

  bool started = false;
  String busNumber = '1';

  Location location = Location();
  StreamSubscription<LocationData>? locationSubscription;

  late GoogleMapController googleMapController;

  List<LatLng> polylineCoordinates = [];
  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      'AIzaSyB8un86Eki04e0fN0JSEzd5BPt_Ge3YoqQ', // Your Google Map Key
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      setState(() {});
    }
  }

  getCurrentLocation() async {
    await location.getLocation().then(
      (location) {
        setState(() {
          currentLocation = location;
          _markers.add(Marker(
              markerId: MarkerId('student location'),
              position: LatLng(
                  currentLocation!.latitude!, currentLocation!.longitude!)));
        });

        print('LOCATION IS ${currentLocation.toString()}');
      },
    );

    googleMapController = await _controller.future;
    location.onLocationChanged.listen(
      (newLoc) {
        currentLocation = newLoc;
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 13.5,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
        setState(() {});
      },
    );
  }

  @override
  void initState() {
    getPolyPoints();
    getCurrentLocation();
    // Data.setBusNumber('28C');

    geo = GeoFlutterFire();
    GeoFirePoint center = geo!.point(latitude: 12.960632, longitude: 77.641603);
    stream = radius.switchMap((rad) {
      var collectionReference = _firestore.collection('locations');
//          .where('name', isEqualTo: 'darshan');
      return geo!.collection(collectionRef: collectionReference).within(
          center: center, radius: rad, field: 'position', strictMode: true);

      /*
      ****Example to specify nested object****

      var collectionReference = _firestore.collection('nestedLocations');
//          .where('name', isEqualTo: 'darshan');
      return geo.collection(collectionRef: collectionReference).within(
          center: center, radius: rad, field: 'address.location.position');

      */
    });

    /*_firestore.collection('28C').get().then((value) {
      value.docs.forEach((element) {
        print('FROM FIREBASE: ${element.data().values.toString()}');
      });
    });*/

    BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(12, 12)),
      "assets/bus.png",
    ).then((value) => busMarker = value);

    super.initState();
  }

  void updateMarkerOnMap() async {
    CameraPosition cPosition = CameraPosition(
      zoom: 15.0,
      tilt: 80,
      bearing: 30,
      target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
    );
  }

  @override
  Widget build(BuildContext context) {
    GeoPoint gpoint;
    //Data.setBusNumber('28C');
    //busNumber = Data.getBusNumber();
    /*_firestore.collection('28C').get().then((value) {
      value.docs.forEach((element) {
        print('FROM FIREBASE: ${element.data().values.toString()}');
      });
    });*/
    return Scaffold(
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation!.latitude!,
                        currentLocation!.longitude!),
                    zoom: 13.5,
                  ),
                  /*markers: {
                    Marker(
                      markerId: const MarkerId("currentLocation"),
                      position: LatLng(currentLocation!.latitude!,
                          currentLocation!.longitude!),
                    ),
                    Marker(
                      markerId: MarkerId("source"),
                      position: LatLng(13.0418, 80.2341),
                    ),
                  },*/
                  markers: _markers,
                  onMapCreated: (mapController) {
                    _controller.complete(mapController);
                  },
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId("route"),
                      points: polylineCoordinates,
                      color: const Color(0xFF7B61FF),
                      width: 6,
                    ),
                  },
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                                alignment: Alignment.topLeft,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const welcomePage()));
                                  },
                                  child: const Icon(
                                    Icons.arrow_back,
                                  ),
                                )),
                            const Text(
                              'Select Bus Number',
                              style: TextStyle(fontSize: 20),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            /*SearchMapPlaceWidget(
                          apiKey: 'AIzaSyCu0EbP48H4G8vzUKFyGw5LHO57lRbtr2s',
                          hasClearButton: true,
                          placeType: PlaceType.address,
                          placeholder: 'Enter Destination',
                          onSelected: (Place place) async {
                            Geolocation? geolocation = await place.geolocation;
                            mapController.animateCamera(CameraUpdate.newLatLng(
                                geolocation!.coordinates));
                            mapController.animateCamera(
                                CameraUpdate.newLatLngBounds(
                                    geolocation.bounds, 0));
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),*/
                            Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width * 0.3,
                              /*child: TextField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Select Bus Number',
                                  hintText: 'Start',
                                ),
                                onChanged: (text) {
                                  // place = text;
                                },
                              ),*/
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                border: Border.all(),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                              ),
                              child: DropdownButton<String>(
                                value: busNumber,
                                icon: const Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.deepPurple),
                                onChanged: (newValue) {
                                  setState(() {
                                    busNumber = newValue!;
                                  });
                                },
                                items: <String>[
                                  '1',
                                  '2',
                                  '3',
                                  '28',
                                  '28C'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            ElevatedButton(
                                onPressed: () async {
                                  locationSubscription = location
                                      .onLocationChanged
                                      .listen((locationData) {
                                    print(
                                        'LOCATION DATA : ${locationData.toString()}');

                                    /*GeoFirePoint geoFirePoint = geo!.point(
                            latitude: currentLocation!.latitude!.toDouble(),
                            longitude: currentLocation!.longitude!.toDouble());*/

                                    var lat, lng;

                                    _firestore
                                        .collection(busNumber)
                                        .get()
                                        .then((value) {
                                      print('LENGTH: ${value.docs.isEmpty}');
                                      value.docs.forEach((element) {
                                        try {
                                          print(
                                              'FROM FIREBASE: ${element.data().values}');

                                          gpoint = element
                                                  .data()
                                                  .values
                                                  .elementAt(1)['geopoint']
                                              as GeoPoint;
                                          print(
                                              'FROM DATABASE: ${gpoint.latitude.toString()} , ${gpoint.longitude.toString()}');

                                          lat = gpoint.latitude;
                                          lng = gpoint.longitude;

                                          googleMapController.animateCamera(
                                              CameraUpdate.newCameraPosition(
                                                  CameraPosition(
                                                      target: LatLng(lat, lng),
                                                      zoom: 15.0)));

                                          _markers.add(Marker(
                                              markerId:
                                                  MarkerId('Bus Location'),
                                              position: LatLng(lat, lng),
                                              //icon: busMarker
                                              icon: BitmapDescriptor
                                                  .defaultMarkerWithHue(
                                                      BitmapDescriptor
                                                          .hueBlue)));

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                                  content: Text(
                                                      'Coordiantes: ${gpoint.latitude.toString()} , ${gpoint.longitude.toString()}')));
                                        } catch (e) {
                                          print('NO DATA: ${e.toString()}');
                                          // ScaffoldMessenger.of(context)
                                          //     .showSnackBar(const SnackBar(
                                          //         content: Text('No Data')));
                                        }
                                      });
                                    });
                                  });
                                },
                                child: Text('Search')),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        started = false;
                      });

                      setState(() {
                        locationSubscription!.cancel();
                        MarkerId id = MarkerId('Bus Location');
                        _markers.removeWhere((key) => key == id);
                      });

                      _firestore
                          //.collection('$busNumber')
                          .collection('28C')
                          .get()
                          .then((snapshot) {
                        snapshot.docs.forEach((doc) {
                          doc.reference.delete();
                        });
                      });
                    },
                    child: const Text('Stop'),
                  ),
                ),
                /*Positioned(
                  bottom: 50,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: () async {
                      //print(busNumber.toString());
                      /*setState(() {
                        started = true;
                      });*/

                      /*_firestore.collection('28C').get().then((value) {
                        value.docs.forEach((element) {
                          print('FROM FIREBASE: ${element.data().values}');

                          GeoPoint gpoint = element
                              .data()
                              .values
                              .elementAt(0)['geopoint'] as GeoPoint;
                          print(
                              'FROM DATABASE: ${gpoint.latitude.toString()} , ${gpoint.longitude.toString()}');
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'Coordiantes: ${gpoint.latitude.toString()} , ${gpoint.longitude.toString()}')));
                        });
                      });*/

                      locationSubscription =
                          location.onLocationChanged.listen((locationData) {
                        print('LOCATION DATA : ${locationData.toString()}');

                        /*GeoFirePoint geoFirePoint = geo!.point(
                            latitude: currentLocation!.latitude!.toDouble(),
                            longitude: currentLocation!.longitude!.toDouble());*/

                        var lat, lng;

                        _firestore.collection('28C').get().then((value) {
                          value.docs.forEach((element) {
                            print('FROM FIREBASE: ${element.data().values}');

                            gpoint = element
                                .data()
                                .values
                                .elementAt(1)['geopoint'] as GeoPoint;
                            print(
                                'FROM DATABASE: ${gpoint.latitude.toString()} , ${gpoint.longitude.toString()}');

                            lat = gpoint.latitude;
                            lng = gpoint.longitude;

                            googleMapController.animateCamera(
                                CameraUpdate.newCameraPosition(CameraPosition(
                                    target: LatLng(lat, lng), zoom: 15.0)));

                            _markers.add(Marker(
                                markerId: MarkerId('Bus Location'),
                                position: LatLng(lat, lng),
                                //icon: busMarker
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueBlue)));

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                    'Coordiantes: ${gpoint.latitude.toString()} , ${gpoint.longitude.toString()}')));

                            /*googleMapController.animateCamera(
                                CameraUpdate.newCameraPosition(
                                    CameraPosition(target: LatLng(lat, lng))));*/
                          });
                          /*setState(() {
                            googleMapController.animateCamera(
                                CameraUpdate.newCameraPosition(
                                    const CameraPosition(
                                        target: LatLng(13.0418, 80.2341))));

                            _markers.add(const Marker(
                              markerId: MarkerId('Bus Location'),
                              position: LatLng(13.0418, 80.2341),
                            ));
                          });*/
                        });

                        /*_firestore.collection('$busNumber').add({
                          'name': 'randomname',
                          'position': geoFirePoint.data
                        }).then((_) {
                          print('added ${geoFirePoint.hash} successfully');
                        });*/

                        /*_firestore
                            .collection('$busNumber')
                            .doc('$busNumber coordinates')
                            .set({
                          'name': 'randomname',
                          'position': geoFirePoint.data
                        }).then((_) {
                          print('added ${geoFirePoint.hash} successfully');
                        });*/
                      });

                      /*GeoFirePoint geoFirePoint = geo!.point(
                          latitude: currentLocation!.latitude!.toDouble(),
                          longitude: currentLocation!.longitude!.toDouble());
                      _firestore.collection('locations1').add({
                        'name': 'random name',
                        'position': geoFirePoint.data
                      }).then((_) {
                        print('added ${geoFirePoint.hash} successfully');
                      });*/
                    },
                    child: const Text('Start'),
                  ),
                ),*/
              ],
            ),
    );
  }
}
