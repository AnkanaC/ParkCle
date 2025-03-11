// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_places_flutter/google_places_flutter.dart';

// //const LatLng currentLocation = LatLng(22.578903696402698, 88.47613819463237);
// const LatLng currentLocation = LatLng(22.568749908401628, 88.38604742411138);

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late GoogleMapController mapController;
//   final TextEditingController _searchController = TextEditingController();
//   final Map<String, Marker> _markers = {};

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(
//             // Replace Flexible with Expanded
//             child: Stack(
//               children: [
//                 GoogleMap(
//                   initialCameraPosition: const CameraPosition(
//                     target: currentLocation,
//                     zoom: 15,
//                   ),
//                   onMapCreated: (controller) {
//                     mapController = controller;
//                     addMarkers('test', currentLocation);
//                   },
//                   markers: _markers.values.toSet(),
//                   onCameraMove: (position) {
//                     print(position.target);
//                   },
//                 ),
//                 Positioned(
//                   top: 40,
//                   left: 20,
//                   right: 20,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(8),
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 5,
//                           spreadRadius: 2,
//                           offset: Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: GooglePlaceAutoCompleteTextField(
//                       textEditingController: _searchController,
//                       googleAPIKey: 'AIzaSyDtNrQSq-Uc8nmqY2nfn67sPQtMo-WDZm8',
//                       inputDecoration: const InputDecoration(
//                         hintText: "Search location...",
//                         prefixIcon: Icon(Icons.search),
//                       ),
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   bottom: 40,
//                   left: 20,
//                   right: 20,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       showModalBottomSheet(
//                         context: context,
//                         backgroundColor: Colors.white,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.vertical(
//                             top: Radius.circular(20),
//                           ),
//                         ),
//                         clipBehavior: Clip.antiAliasWithSaveLayer,
//                         isScrollControlled: true,
//                         builder: (BuildContext context) {
//                           return Container(
//                             padding: const EdgeInsets.all(16.0),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.max,
//                               crossAxisAlignment: CrossAxisAlignment.stretch, 
//                               children: [
//                                 const Text(
//                                   "This is a bottom sheet",
//                                   style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold),
//                                 ),
//                                 const SizedBox(height: 10),
//                                 ElevatedButton(
//                                   onPressed: () => Navigator.pop(context),
//                                   child: const Text("Close"),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       );
//                     },
//                     child: const Text("Parking Spots"),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   addMarkers(String id, LatLng location) {
//     var marker = Marker(
//       markerId: MarkerId(id),
//       position: location,
//       infoWindow: const InfoWindow(
//         title: 'My Location',
//         snippet: 'This is my location',
//       ),
//     );
//     _markers[id] = marker;

//     setState(() {});
//   }
// }

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

const String googleApiKey = "AIzaSyDtNrQSq-Uc8nmqY2nfn67sPQtMo-WDZm8";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LatLng _currentLocation = LatLng(22.568749908401628, 88.38604742411138);
  List<Map<String, dynamic>> _parkingSpots = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  Future<void> _fetchParkingSpots() async {
    final url = Uri.parse(
        "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentLocation.latitude},${_currentLocation.longitude}&radius=5000&type=parking&keyword=car%20parking&key=$googleApiKey");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Map<String, dynamic>> spots = [];

      for (var place in data["results"]) {
        double lat = place["geometry"]["location"]["lat"];
        double lng = place["geometry"]["location"]["lng"];
        String name = place["name"];
        String address = place["vicinity"] ?? "No address available";
        double distance = _calculateDistance(_currentLocation.latitude, _currentLocation.longitude, lat, lng);
        String availability = _getAvailability();

        spots.add({
          "name": name,
          "address": address,
          "lat": lat,
          "lng": lng,
          "distance": distance,
          "availability": availability,
        });
      }

      spots.sort((a, b) => a["distance"].compareTo(b["distance"]));

      setState(() {
        _parkingSpots = spots;
      });

      _showParkingModal();
    } else {
      print("Failed to load parking spots");
    }
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371;
    double dLat = (lat2 - lat1) * (3.141592653589793 / 180);
    double dLon = (lon2 - lon1) * (3.141592653589793 / 180);

    double a = 
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(lat1 * (3.141592653589793 / 180)) *
        cos(lat2 * (3.141592653589793 / 180)) *
        (sin(dLon / 2) * sin(dLon / 2));

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  String _getAvailability() {
    List<String> statuses = ["Available", "Limited", "Full"];
    return statuses[DateTime.now().second % 3];
  }

  void _showParkingModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height * 0.6, // Make it scrollable
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Nearby Parking Spots",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _parkingSpots.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _parkingSpots.length,
                        itemBuilder: (context, index) {
                          var spot = _parkingSpots[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text(spot["name"], style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("${spot["address"]}\nDistance: ${spot["distance"].toStringAsFixed(2)} km"),
                              trailing: Chip(
                                label: Text(spot["availability"]),
                                backgroundColor: spot["availability"] == "Available"
                                    ? Colors.green
                                    : spot["availability"] == "Limited"
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                            ),
                          );
                        },
                      ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: MarkerId("currentLocation"),
                position: _currentLocation,
                infoWindow: InfoWindow(title: "You are here"),
              )
            },
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _fetchParkingSpots,
              child: const Text("Show Nearby Parking"),
            ),
          ),
        ],
      ),
    );
  }
}
