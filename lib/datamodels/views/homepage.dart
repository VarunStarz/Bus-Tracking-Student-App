import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mapfollow2/datamodels/user_location.dart';
import 'package:mapfollow2/datamodels/views/alarmpage.dart';
import 'package:mapfollow2/main.dart';
import 'package:mapfollow2/services/location_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

String place = '';
String? rideOver;
double totalDistance = 0.0;
double? newLat, newLong;
UserLocation? finalPosition;

late AudioPlayer audioPlayer = AudioPlayer();

class Distance {
  final double dist = totalDistance;
}

class HomePage extends StatefulWidget {
  late final UserLocation initialPosition;

  HomePage(this.initialPosition);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Completer<GoogleMapController> _controller = Completer();

  Set<Polyline> _polylines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  late GoogleMapController mapController;

  final LocationService locationService = LocationService();

  late double dist;
  var data;

  bool? isEmpty;

  @override
  void initState() {
    /*getCurrentLocation().listen((position) {
      centerScreen(position);
    });*/
    if (place.isEmpty) isEmpty = true;

    Geolocator.getPositionStream(
            locationSettings: LocationSettings(
                accuracy: LocationAccuracy.high, distanceFilter: 1))
        .listen((position) {
      centerScreen(UserLocation(
          latitude: position.latitude, longitude: position.longitude));
    });
    polylinePoints = PolylinePoints();

    /*if (data == 'Ride Over') {
      setState(() {
        locationService.locationStream.drain();
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => alarmPage()));
      });
    }*/

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /*Stream<UserLocation> getCurrentLocation() {
    var locationOptions =
        LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);
    return Geolocator.getPositionStream(locationSettings: locationOptions);
  }*/

  @override
  Widget build(BuildContext context) {
    var userLocation = Provider.of<UserLocation>(context);

    Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
    LatLng _center = LatLng(
        widget.initialPosition.latitude!, widget.initialPosition.longitude!);

    _addMarker() {
      final marker = Marker(
        markerId: MarkerId('place_name'),
        position: LatLng(widget.initialPosition.latitude!,
            widget.initialPosition.longitude!),
        icon: BitmapDescriptor.defaultMarker,
        // icon: BitmapDescriptor.,
        infoWindow: InfoWindow(
          title: 'title',
          snippet: 'address',
        ),
      );

      setState(() {
        markers[MarkerId('place_name')] = marker;
      });
    }

    _onMapCreated(GoogleMapController controller) {
      _controller.complete(controller);
      mapController = controller;
      final marker = Marker(
        markerId: MarkerId('place_name'),
        position: LatLng(widget.initialPosition.latitude!,
            widget.initialPosition.longitude!),
        icon: BitmapDescriptor.defaultMarker,
        // icon: BitmapDescriptor.,
        infoWindow: InfoWindow(
          title: 'title',
          snippet: 'address',
        ),
      );

      setState(() {
        markers[MarkerId('place_name')] = marker;
      });
      //setPolylines();
    }

    return Scaffold(
      /*child: Text(
          'Lat: ${userLocation.latitude}, Long: ${userLocation.longitude}'),*/
      body: Center(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(widget.initialPosition.latitude!,
                    widget.initialPosition.longitude!),
                zoom: 18.0,
              ),
              mapType: MapType.normal,
              myLocationEnabled: true,
              onMapCreated: _onMapCreated,
              polylines: _polylines,
              markers: markers.values.toSet(),
              onTap: _addMarker(),
              compassEnabled: true,
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.all(
                      Radius.circular(20.0),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Padding(
                    padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
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
                                        builder: (context) => welcomePage()));
                              },
                              child: Icon(
                                Icons.arrow_back,
                              ),
                            )),
                        Text(
                          'Enter destination',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: 20,
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
                        TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter Destination',
                            hintText: 'Start',
                          ),
                          onChanged: (text) {
                            place = text;
                          },
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              finalPosition = await getCoordinates();

                              totalDistance = Geolocator.distanceBetween(
                                  widget.initialPosition.latitude!,
                                  widget.initialPosition.longitude!,
                                  finalPosition!.latitude!,
                                  finalPosition!.longitude!);

                              print(totalDistance.toString());

                              if (place.isNotEmpty) isEmpty = false;
                            },
                            child: Text('Search')),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                            'Total Distance: ${totalDistance.toString()} meters'),
                        SizedBox(
                          height: 10,
                        ),
                        StreamBuilder<UserLocation>(
                          stream: locationService.locationStream,
                          builder: (context, snapshot) {
                            if (isEmpty == true)
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            else {
                              dist = Geolocator.distanceBetween(
                                  widget.initialPosition.latitude!,
                                  widget.initialPosition.longitude!,
                                  finalPosition!.latitude!,
                                  finalPosition!.longitude!);
                            }
                            /*if (data == 'Ride Over') {
                              locationService.locationStream.drain();
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => alarmPage()));
                            }*/

                            if (!snapshot.hasData)
                              return Center(
                                child: CircularProgressIndicator(),
                              );

                            /*return Center(
                              child: (isEmpty == true)
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : data = Text((dist <= 2375)
                                      ? rideOver = 'Ride Over'
                                      : ('Distance: ${rideOver = dist.toString()}')),
                            );*/

                            if (dist.truncate() <= 1000) {
                              rideOver = 'Ride Over';
                              locationService.locationStream.drain();

                              WidgetsBinding.instance!
                                  .addPostFrameCallback((_) async {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => alarmPage1()));

                                audioPlayer = await AudioCache()
                                    .play('wakeyalarm2.0.mp3');
                              });
                            } else {
                              rideOver = dist.toString();
                            }

                            if (isEmpty == true) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return Center(
                                child: Text(
                                    'Realtime Distance: ${rideOver} meters'),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<UserLocation> getCoordinates() async {
    List<Location> coordinates = await locationFromAddress(place);

    newLat = coordinates[0].latitude;
    newLong = coordinates[0].longitude;

    return UserLocation(latitude: newLat, longitude: newLong);
    /*totalDistance = Geolocator.distanceBetween(
        widget.initialPosition.latitude!,
        widget.initialPosition.longitude!,
        coordinates[0].latitude,
        coordinates[0].longitude);

    print(totalDistance.toString());*/
  }

  Future<void> centerScreen(UserLocation position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude!, position.longitude!), zoom: 18.0)));
  }

  /*void setPolylines() async {
    List<Location> coordinates = await locationFromAddress(place);
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        "AIzaSyCu0EbP48H4G8vzUKFyGw5LHO57lRbtr2s",
        PointLatLng(widget.initialPosition.latitude!,
            widget.initialPosition.longitude!),
        PointLatLng(coordinates[0].latitude, coordinates[0].longitude));
    if (result == 'OK') {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polylines.add(
          Polyline(
            width: 10,
            polylineId: PolylineId('polyline'),
            points: polylineCoordinates,
            color: Color(0xFF08A5CB),
          ),
        );
      });
    }
  }*/
}

class alarm extends StatefulWidget {
  const alarm({Key? key}) : super(key: key);

  @override
  _alarmState createState() => _alarmState();
}

class _alarmState extends State<alarm> {
  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      audioPlayer = await AudioCache().play('wakeyalarm2.0.mp3');
    });

    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(child: Text('STOP'), onPressed: () {}),
      ),
    );
  }
}
