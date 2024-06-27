import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'map-function.dart'; // Ensure this file exists and provides LocationService

class MapLocation extends StatefulWidget {
  final String address;

  const MapLocation({Key? key, required this.address}) : super(key: key);

  @override
  State<MapLocation> createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  CameraPosition? _currentCameraPosition;
  TextEditingController _originLocationController = TextEditingController();
  TextEditingController _destinationLocationController = TextEditingController();

  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polylines = Set<Polyline>();

  int _polylineIdCounter = 1;
  bool _isLoading = true;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    _destinationLocationController.text = widget.address;
    _getCurrentLocation();
    _checkLocationService();
  }

  void _setOriginMarker(LatLng point) async {
    print("Setting origin marker at $point");
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('origin'),
          position: point,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;

    setState(() {
      _polylines.add(
        Polyline(
          polylineId: PolylineId(polylineIdVal),
          width: 5,
          color: Colors.red,
          points: points.map((point) => LatLng(point.latitude, point.longitude)).toList(),
        ),
      );
    });
  }

  Future<void> _checkLocationService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error('Location permissions are permanently denied, we cannot request permissions.');
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 12,
        );
      });

      _originLocationController.text = await _getPlaceName(position.latitude, position.longitude);

      // Automatically trigger location search after getting the current location
      _searchLocation();
    } catch (e) {
      print('Error retrieving current location : $e');
    }
  }

  Future<String> _getPlaceName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // You can customize this format as needed
        return "${place.name}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
      } else {
        return "No address available";
      }
    } catch (e) {
      print(e);
      return "Error: ${e.toString()}";
    }
  }

  Marker _destinationMarker = Marker(
    markerId: MarkerId('destination'),
    infoWindow: InfoWindow(title: 'Destination'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    position: LatLng(0.0, 0.0),
  );

  Future<void> _searchLocation() async {
    try {
      String destinationPlaceId = await LocationService().getPlaceId(_destinationLocationController.text);

      var directions = await LocationService().getDirections(
        _originLocationController.text,
        'place_id:$destinationPlaceId', // Use Place ID for destination
      );

      if (directions != null) {
        _goToPlace(
          directions['start_location']['lat'],
          directions['start_location']['lng'],
          directions['end_location']['lat'],
          directions['end_location']['lng'],
          directions['bounds_ne'],
          directions['bounds_sw'],
        );

        _setPolyline(directions['polyline_decoded']);

        LatLng destinationLatLng = LatLng(
          directions['end_location']['lat'],
          directions['end_location']['lng'],
        );
        _setDestinationMarker(destinationLatLng);

        // Set _isLoading to false when markers and polylines are added
        setState(() {
          _isLoading = false;
        });
      } else {
        print('Directions not found');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No routes found from ${_originLocationController.text} to ${_destinationLocationController.text}')),
        );
      }
    } catch (e) {
      print('Error while searching location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while searching location: $e')),
      );
    }
  }

  void _setDestinationMarker(LatLng point) {
    print("Setting destination marker at $point");
    setState(() {
      _destinationMarker = Marker(
        markerId: MarkerId('destination'),
        position: point,
        infoWindow: InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
      _markers.add(_destinationMarker);
    });
  }

  Future<void> _goToPlace(
      double startLat,
      double startLng,
      double endLat,
      double endLng,
      Map<String, dynamic> boundsNe,
      Map<String, dynamic> boundsSw,
      ) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
          northeast: LatLng(boundsNe['lat'], boundsNe['lng']),
        ),
        25,
      ),
    );

    _setOriginMarker(LatLng(startLat, startLng));
    _setDestinationMarker(LatLng(endLat, endLng));
  }

  void _launchGoogleMapsFromCurrentLocation(String destination) async {
    if (_currentCameraPosition != null) {
      String googleMapsUrl = "https://www.google.com/maps/dir/?api=1&destination=$destination&travelmode=driving";
      if (await canLaunch(googleMapsUrl)) {
        await launch(googleMapsUrl);
      } else {
        throw 'Could not launch $googleMapsUrl';
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current location is not available')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Locker Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _originLocationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Your Location',
                        hintText: 'Enter your current location',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        print('Your Location: $value');
                      },
                      enabled: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _destinationLocationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: 'Your Destination',
                        hintText: 'Enter your destination',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        print('Your Destination: $value');
                      },
                      enabled: false,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex,
                  markers: _markers,
                  polylines: _polylines,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                    if (_currentCameraPosition != null) {
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(_currentCameraPosition!),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              String destination = _destinationLocationController.text;
              _launchGoogleMapsFromCurrentLocation(destination);
            },
            icon: Icon(Icons.directions),
            label: Text('Show Direction'),
            backgroundColor: Colors.blue,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
