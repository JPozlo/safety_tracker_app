import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException, rootBundle;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart' as MyGeolocator;
import 'package:safety_tracker_app/utils/constants.dart';

class MapPage extends StatefulWidget {
  MapPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final LatLng destinationCoords = LatLng(-1.351429, 36.759981);
  PolylinePoints polylinePoints;
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();
  String _startAddress = '';
  String _placeDistance;

  final MyGeolocator.Geolocator _geolocator = MyGeolocator.Geolocator();
// For storing the current position
  List<LatLng> polylineCoordinates = [];
  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> markers = {};
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool running = false;
  MyGeolocator.Position _firstUserPosition;
  MyGeolocator.Position _currentPosition;
  MyGeolocator.Position _lastUserPosition;
  double finalDistance;

  StreamSubscription _locationSubscription;
  Location _locationTracker = Location();
  Marker marker;
  Circle circle;
  GoogleMapController _controller;

  static final CameraPosition initialLocation = CameraPosition(
    target: LatLng(0.0, 0.0),
    zoom: 14.4746,
  );

  Widget _textField({
    TextEditingController controller,
    String label,
    String hint,
    String initialValue,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextFormField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        // initialValue: initialValue,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue[300],
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  Future<Uint8List> getUserMarker() async {
    ByteData byteData = await rootBundle.load("images/driving_pin.png");
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> getDestinationMarker() async {
    ByteData byteData =
        await rootBundle.load("images/destination_map_marker.png");
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

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.red,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
  }

  void updateMarkerAndCircle(LocationData newLocalData, Uint8List imageData) {
    LatLng latlng = LatLng(newLocalData.latitude, newLocalData.longitude);
    this.setState(() {
      marker = Marker(
          markerId: MarkerId("home"),
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
      markers.add(marker);
    });
  }

   _getFirstCurrentLocation() async {
   await _geolocator
        .getCurrentPosition(desiredAccuracy: MyGeolocator.LocationAccuracy.high)
        .then((MyGeolocator.Position position) async {
      setState(() {
        _firstUserPosition = position;

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
    await _geolocator
        .getCurrentPosition(desiredAccuracy: MyGeolocator.LocationAccuracy.high)
        .then((MyGeolocator.Position position) async {
      setState(() {

        _lastUserPosition = position;
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
          latitude: _lastUserPosition.latitude,
          longitude: _lastUserPosition.longitude
        );


        Uint8List imageData = await getDestinationMarker();

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
            snippet: _startAddress,
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
            markerId: MarkerId("stopMarker"),
            position: destinationCoords,
            infoWindow: InfoWindow(title: "Endpoints Marker Finish"),
            draggable: false,
            zIndex: 2,
            flat: true,
            anchor: Offset(0.5, 0.5),
            icon: BitmapDescriptor.fromBytes(imageData));

        // Adding the markers to the list
        markers.add(startMarker);
        markers.add(destinationMarker);

        print('START COORDINATES: $startCoordinates');
        print('DESTINATION COORDINATES: $destinationCoordinates');

        MyGeolocator.Position _northeastCoordinates;
        MyGeolocator.Position _southwestCoordinates;

        // Calculating to check that
        // southwest coordinate <= northeast coordinate
        if (startCoordinates.latitude <= destinationCoordinates.latitude) {
          _southwestCoordinates = startCoordinates;
          _northeastCoordinates = destinationCoordinates;
        } else {
          _southwestCoordinates = destinationCoordinates;
          _northeastCoordinates = startCoordinates;
        }

        // Accomodate the two locations within the
        // camera view of the map
        _controller.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                _northeastCoordinates.latitude,
                _northeastCoordinates.longitude,
              ),
              southwest: LatLng(
                _southwestCoordinates.latitude,
                _southwestCoordinates.longitude,
              ),
            ),
            100.0,
          ),
        );

        // Calculating the distance between the start and the end positions
        // with a straight path, without considering any route
        // double distanceInMeters = await Geolocator().bearingBetween(
        //   startCoordinates.latitude,
        //   startCoordinates.longitude,
        //   destinationCoordinates.latitude,
        //   destinationCoordinates.longitude,
        // );

        await _createPolylines(startCoordinates, destinationCoordinates);

        double totalDistance = 0.0;

        // Calculating the total distance by adding the distance
        // between small segments
        for (int i = 0; i < polylineCoordinates.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i + 1].latitude,
            polylineCoordinates[i + 1].longitude,
          );
        }

        setState(() {
          _placeDistance = totalDistance.toStringAsFixed(2);
          print('DISTANCE: $_placeDistance km');
        });

        return true;

    } catch (e) {
      print(e);
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

  void updateUserLocation() async {
    try {
     running = true;

      Uint8List imageData = await getUserMarker();
      var location = await _locationTracker.getLocation();

      updateMarkerAndCircle(location, imageData);

      if (_locationSubscription != null) {
        _locationSubscription.cancel();
      }

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
      });
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        debugPrint("Permission Denied");
      }
    }
  }

  void stopTrackingUserLocation() async {
    try {
      running = false;
      _getLastCurrentLocation();
      finalDistance = _coordinateDistance(_firstUserPosition.latitude, _firstUserPosition.longitude, _lastUserPosition.latitude, _lastUserPosition.longitude);
      _createPolylines(_firstUserPosition, _lastUserPosition);
    } on Exception catch (e) {
      debugPrint("Error due to $e");
    }
  }

  @override
  void initState() {
    super.initState();
    running = false;
    _getFirstCurrentLocation();
  }

  @override
  void dispose() {
    if (_locationSubscription != null) {
      _locationSubscription.cancel();
    }
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
                markers: markers != null ? Set<Marker>.from(markers) : null,
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
                            SizedBox(height: 5),
                            Visibility(
                              visible: running == false ? true: false,
                              child: RaisedButton(
                              onPressed:() async {
                                updateUserLocation();
                                setState(() {
                                  if (markers.isNotEmpty) markers.clear();
                                  if (polylines.isNotEmpty)
                                    polylines.clear();
                                  if (polylineCoordinates.isNotEmpty)
                                    polylineCoordinates.clear();
                                  _placeDistance = null;
                                });
                                },

                              color: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Start Run'.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20.0,
                                  ),
                                ),
                              ),
                            ),
                            ),
                            Visibility(
                              visible: running == true ? true: false,
                              child: RaisedButton(
                                onPressed:
                                    () async {
                                  stopTrackingUserLocation();

                                  _calculateDistance().then((isCalculated) {
                                    if (isCalculated) {
                                      _scaffoldKey.currentState
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Distance Calculated Sucessfully'),
                                        ),
                                      );
                                    } else {
                                      _scaffoldKey.currentState
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Error Calculating Distance'),
                                        ),
                                      );
                                    }
                                  });
                                }
                                    ,
                                color: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Stop Run'.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.white,
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
                            color: Colors.orange[100], // button color
                            child: InkWell(
                              splashColor: Colors.orange, // inkwell color
                              child: SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(Icons.my_location),
                              ),
                              onTap: () {
                                _controller.animateCamera(
                                  CameraUpdate.newCameraPosition(
                                    CameraPosition(
                                      target: LatLng(
                                        _firstUserPosition.latitude,
                                        _firstUserPosition.longitude,
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
}
