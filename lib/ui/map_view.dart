import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException, rootBundle;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as MyGeolocator;
import 'package:safety_tracker_app/services/services.dart';
import 'package:safety_tracker_app/utils/utils.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key, this.title, this.theGroupId}) : super(key: key);
  final String title;
  final String theGroupId;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  PolylinePoints polylinePoints;
  String _placeDistance;

  final MyGeolocator.Geolocator _geolocator = MyGeolocator.Geolocator();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// For storing the current position
  List<LatLng> _polylineCoordinates = [];
  Map<PolylineId, Polyline> _polylines = {};
  Set<Polyline> _myPolylines = {};
  Set<Marker> _markers = {};
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _running = false;
  bool _hasRun = false;
  MyGeolocator.Position _firstUserPosition;
  MyGeolocator.Position _currentPosition;

  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;

  double _totalDistance = 0.0;
  DateTime _startTime;
  DateTime _endTime;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 14.4746,
  );

  Future<Uint8List> getUserMarker() async {
    ByteData byteData = await rootBundle.load("images/tracking_marker.png");
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> getDestinationMarker() async {
    ByteData byteData = await rootBundle.load("images/location_marker.png");
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> getStartMarker() async {
    ByteData byteData = await rootBundle.load("images/location_marker.png");
    return byteData.buffer.asUint8List();
  }

  // Create the polylines for showing the route between two places
  _createPolylines(
      MyGeolocator.Position start, MyGeolocator.Position destination) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Constants().apiKey, // Google Maps API Key
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.walking,
    );

    print("RESULTS of POLYLINE: $result");

    if (result != null) {
      // Adding the coordinates to the list
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          _polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
      }

      // Defining an ID
      PolylineId id = PolylineId('poly');

      // Initializing Polyline
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: _polylineCoordinates,
        width: 3,
      );

      // Adding the polyline to the map
      setState(() {
        _polylines[id] = polyline;
        _myPolylines.add(polyline);
      });
    }
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("user"),
          position: latlng,
          infoWindow: InfoWindow(title: "User Marker"),
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      circle = Circle(
          circleId: CircleId("car"),
          radius: newLocalData.accuracy,
          zIndex: 1,
          strokeColor: Colors.blue,
          center: latlng,
          fillColor: Colors.blue.withAlpha(70));
      _markers.add(marker);
    });
  }

  void setStartMarkerAndCircle(
      MyGeolocator.Position newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("location1"),
          position: latlng,
          infoWindow: InfoWindow(title: "Location Marker 1"),
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
    });
    _markers.add(marker);
  }

  void setEndMarkerAndCircle(MyGeolocator.Position firstLocalData,
      MyGeolocator.Position newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      Marker marker1 = Marker(
          markerId: MarkerId("location1"),
          position: latlng,
          infoWindow: InfoWindow(title: "Location Marker 1"),
          rotation: firstLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      Marker marker2 = Marker(
          markerId: MarkerId("location2"),
          position: latlng,
          infoWindow: InfoWindow(title: "Location Marker 2"),
          rotation: newLocalData.heading,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: Offset(0.5, 0.5),
          icon: BitmapDescriptor.fromBytes(imageData));
      _markers.add(marker1);
      _markers.add(marker2);
    });
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
      // Use the retrieved coordinates of the current position,
      // instead of the address if the start position is user's
      // current position, as it results in better accuracy.
      MyGeolocator.Position startCoordinates = MyGeolocator.Position(
          latitude: _firstUserPosition.latitude,
          longitude: _firstUserPosition.longitude);

      MyGeolocator.Position destinationCoordinates = MyGeolocator.Position(
          latitude: _currentPosition.latitude,
          longitude: _currentPosition.longitude);

      // Calculating the distance between the start and the end positions
      // with a straight path, without considering any route
      // double distanceInMeters = await Geolocator().bearingBetween(
      //   startCoordinates.latitude,
      //   startCoordinates.longitude,
      //   destinationCoordinates.latitude,
      //   destinationCoordinates.longitude,
      // );

      await _createPolylines(startCoordinates, destinationCoordinates);

      print("POLYLINE COORDS LENGTH: ${_polylineCoordinates.length}");

      // Calculating the total distance by adding the distance
      // between small segments
      if (_polylineCoordinates.length > 0) {
        for (int i = 0; i < _polylineCoordinates.length - 1; i++) {
          _totalDistance += _coordinateDistance(
            _polylineCoordinates[i].latitude,
            _polylineCoordinates[i].longitude,
            _polylineCoordinates[i + 1].latitude,
            _polylineCoordinates[i + 1].longitude,
          );
          print(
              "LOOP $i OF TOTAL DISTANCE CALCULATION: ${_totalDistance.toStringAsFixed(2)}");
        }
      } else {
        _totalDistance = 0.0;
      }

      setState(() {
        _totalDistance = _totalDistance;
        _placeDistance = _totalDistance.toStringAsFixed(2);
        print('PLACE DISTANCE AS FIXED: $_placeDistance m');
        print('DISTANCE: ${_totalDistance.toString()} m');
      });
      return true;
    } catch (e) {
      print("Calculate distance due to: $e");
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  _getFirstCurrentLocation() async {
    await _geolocator
        .getCurrentPosition(desiredAccuracy: MyGeolocator.LocationAccuracy.high)
        .then((MyGeolocator.Position position) async {
      var imageData = await getStartMarker();
      setState(() {
        _firstUserPosition = position;
        setStartMarkerAndCircle(position, imageData);
        // For moving the camera to current location
        _controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
    }).catchError((e) {
      print(e);
    });
  }

  _getLastCurrentLocation() async {
    var imageData = await getStartMarker();
    print("The total distance is: $_totalDistance kilometres");
    print("The first user position coordinates is: $_firstUserPosition");
    print("The current user position coordinates is: $_currentPosition");

    getStringPrefs(Constants.groupID)
        .then((value) => {
      GroupService()
          .saveRun(
          distance: _totalDistance,
          groupId: value,
          startTime: _startTime,
          endTime: _endTime)
          .then((val) {
        print("Added Run successfully to firestore");
      }).catchError((e) {
        print("Error adding run to firestore due to: $e");
      })
    })
        .catchError((err) {
      print("Error getting group id due to: $err");
    });

    setState(() {
      _endTime = DateTime.now();
      _createPolylines(_firstUserPosition, _currentPosition);
      setEndMarkerAndCircle(_firstUserPosition, _currentPosition, imageData);
      // For moving the camera to current location
      _controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
            LatLng(_currentPosition.latitude, _currentPosition.longitude),
            zoom: 18.0,
          ),
        ),
      );
    });

  }

  void updateUserLocation() async {
    try {
      _running = true;
      _hasRun = false;

      Uint8List imageData = await getUserMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

      getStringPrefs(Constants.groupID).then((value){
        GroupService().saveInitialRun(
          groupId: value
        ).then((val){
          print("Initial run saved successfully");
        }).catchError((err){
          print("Error saving initial run");
        });
      }).catchError((err){
        print("Error getting Group ID: $err");
      });


      setState(() {
        _startTime = DateTime.now();
      });

      _locationSubscription =
          _locationTracker.onLocationChanged.listen((newLocalData) {
        if (_controller != null) {
          _controller.animateCamera(CameraUpdate.newCameraPosition(
              new CameraPosition(
                  bearing: 192.8334901395799,
                  target: LatLng(newLocalData.latitude, newLocalData.longitude),
                  tilt: 0,
                  zoom: 18.00)));
          updateMarkerAndCircle(newLocalData, imageData);
        }
        _currentPosition = MyGeolocator.Position(
            longitude: newLocalData.longitude, latitude: newLocalData.latitude);
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  void stopTrackingUserLocation() async {
    try {
      setState(() {
        if (_locationSubscription != null) {
          _locationSubscription.cancel();
        }
        if (_markers.isNotEmpty) _markers.clear();
      });
      _running = false;
      _hasRun = true;
      _getLastCurrentLocation();
    } on Exception catch (e) {
      debugPrint("Error due to $e");
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _running = false;
      _hasRun = false;
    });
    _getFirstCurrentLocation();
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
    setState(() {
      if (_markers.isNotEmpty) _markers.clear();
      if (_polylines.isNotEmpty) _polylines.clear();
      if (_polylineCoordinates.isNotEmpty) _polylineCoordinates.clear();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
        height: height,
        width: width,
        child: Scaffold(
          key: _scaffoldKey,
          body: Stack(
            children: <Widget>[
              GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: initialLocation,
                polylines: _myPolylines != null
                    ? Set<Polyline>.from(_myPolylines)
                    : null,
                markers: _markers != null ? Set<Marker>.from(_markers) : null,
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                },
              ),
              // Show the place input fields & button for
              // showing the route
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20.0),
                        ),
                      ),
                      width: width * 0.9,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(height: 10),
                            Visibility(
                                visible: _hasRun == true ? true : false,
                                child: showDistance()),
                            SizedBox(height: 5),
                            Visibility(
                              visible: (_running == false && _hasRun == false)
                                  ? true
                                  : false,
                              child: RaisedButton(
                                onPressed: () async {
                                  updateUserLocation();
                                },
                                color: Constants.appThemeColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Start Run'.toUpperCase(),
                                    style: TextStyle(
                                      color: Constants.myAccent,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: _running == true ? true : false,
                              child: RaisedButton(
                                onPressed: () async {
                                  stopTrackingUserLocation();
                                  _calculateDistance().then((isCalculated) {
                                    if (isCalculated) {
                                      _scaffoldKey.currentState.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Distance Calculated Sucessfully'),
                                        ),
                                      );
                                      setState(() {
                                        if (_polylineCoordinates.isNotEmpty)
                                          _polylineCoordinates.clear();
                                      });
                                      _totalDistance = 0.0;
                                    } else {
                                      _scaffoldKey.currentState.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Error Calculating Distance'),
                                        ),
                                      );
                                      setState(() {
                                        if (_markers.isNotEmpty)
                                          _markers.clear();
                                        if (_polylines.isNotEmpty)
                                          _polylines.clear();
                                        if (_polylineCoordinates.isNotEmpty)
                                          _polylineCoordinates.clear();
                                      });
                                      _totalDistance = 0.0;
                                    }
                                  });
                                },
                                color: Constants.appThemeColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Stop Run'.toUpperCase(),
                                    style: TextStyle(
                                      color: Constants.myAccent,
                                      fontSize: 20.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Show current location button
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        ClipOval(
                          child: Material(
                            color: Constants.appThemeColor, // button color
                            child: InkWell(
                              splashColor: Colors.orange, // inkwell color
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(
                                  Icons.my_location,
                                  color: Constants.myAccent,
                                ),
                              ),
                              onTap: () {
                                _controller.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                        _currentPosition.latitude,
                                        _currentPosition.longitude,
                                      ),
                                      zoom: 18.0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  Widget showNoDistanceMoved() {
    return Scaffold(
      body: Center(
        child: Column(
          children: [Text("You moved zero distance")],
        ),
      ),
    );
  }

  Widget showDistance() {
    return Text(
      "Distance run is: ${_totalDistance.toStringAsFixed(2)} km",
      style: TextStyle(color: Constants.appThemeColor, fontSize: 20),
    );
  }
}
