import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:parkcle/booking.dart';

//const LatLng currentLocation = LatLng(22.578903696402698, 88.47613819463237);
const LatLng currentLocation = LatLng(22.568749908401628, 88.38604742411138);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  final Map<String, Marker> _markers = {};

  LatLng _currentLocation = const LatLng(22.568749908401628, 88.38604742411138);

  List<Map<String, dynamic>> parkingPlaces = [
  {"name": "Gallery 67", "distance": 0.1, "availability": "almost full"},
  {"name": "Eennra", "distance": 0.5, "availability": "full"},
  {"name": "Mani Casa", "distance": 1.2, "availability": "full"},
  {"name": "Lake Parking", "distance": 2.0, "availability": "almost full"},
  {"name": "Kitchen-Q", "distance": 2.5, "availability": "almost full"},
  {"name": "Ajmair Tower", "distance": 3.0, "availability": "full"},
  {"name": "Meraki Inn", "distance": 3.8, "availability": "almost full"},
  {"name": "Dreamy Sunrise", "distance": 4.1, "availability": "almost full"},
  {"name": "Mani Square", "distance": 4.7, "availability": "almost full"},
  {"name": "Q-INN", "distance": 5.0, "availability": "almost full"},
];

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

  Widget _myParkingSpace(int ind, String name, double dist, String avail) {
  return ListTile(
    leading: Text('$ind'),
    title: Text(name),
    subtitle: Text('$dist'),
   trailing: (avail == "full") 
    ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: Colors.red),
          SizedBox(width: 5),
          Text("$avail"),
        ],
      )
    : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: Colors.yellow),
          SizedBox(width: 5),
          Text("$avail"),
        ],
      ),

  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: currentLocation,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    mapController = controller;
                    addMarkers('test', currentLocation);
                  },
                  markers: _markers.values.toSet(),
                  onCameraMove: (position) {
                    print(position.target);
                  },
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: GooglePlaceAutoCompleteTextField(
                      textEditingController: _searchController,
                      googleAPIKey: 'AIzaSyDtNrQSq-Uc8nmqY2nfn67sPQtMo-WDZm8',
                      inputDecoration: const InputDecoration(
                        hintText: "Search location...",
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      print("Button Pressed! Parking Places Count: ${parkingPlaces.length}");
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
                            height: MediaQuery.of(context).size.height * 0.6, // Limit modal height
                            child: Column(
                              mainAxisSize: MainAxisSize.min, 
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                parkingPlaces.isNotEmpty
                                    ? Flexible( 
                                        child: ListView.builder(
                                          itemCount: parkingPlaces.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return Card(
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => BookingPage(),
                                                    ),
                                                  );
                                                },
                                              child: _myParkingSpace(
                                                index + 1, 
                                                parkingPlaces[index]["name"], 
                                                parkingPlaces[index]["distance"],
                                                parkingPlaces[index]["availability"],
                                                ),
                                              ), 
                                            );
                                          },
                                        ),
                                      )
                                    : const Center(child: Text("No Parking Spots Available")), // Handle empty list
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Close"),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    child: const Text("Parking Spots"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  addMarkers(String id, LatLng location) {
    var marker = Marker(
      markerId: MarkerId(id),
      position: location,
      infoWindow: const InfoWindow(
        title: 'My Location',
        snippet: 'This is my location',
      ),
    );
    _markers[id] = marker;

    setState(() {});
  }
}

// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
// import 'package:parkcle/booking.dart';

// const String googleApiKey = "AIzaSyDtNrQSq-Uc8nmqY2nfn67sPQtMo-WDZm8";

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   LatLng _currentLocation = const LatLng(22.568749908401628, 88.38604742411138);
//   List<Map<String, dynamic>> _parkingSpots = [];

//   @override
//   void initState() {
//     super.initState();
//     _getUserLocation();
//   }

//   Future<void> _getUserLocation() async {
//     try {
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() {
//         _currentLocation = LatLng(position.latitude, position.longitude);
//       });
//     } catch (e) {
//       print("Error getting location: $e");
//     }
//   }

//   Future<void> _fetchParkingSpots() async {
//     final url = Uri.parse(
//         "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_currentLocation.latitude},${_currentLocation.longitude}&radius=5000&type=parking&keyword=car%20parking&key=$googleApiKey");

//     final response = await http.get(url);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       List<Map<String, dynamic>> spots = [];

//       for (var place in data["results"]) {
//         double lat = place["geometry"]["location"]["lat"];
//         double lng = place["geometry"]["location"]["lng"];
//         String name = place["name"];
//         String address = place["vicinity"] ?? "No address available";
//         double distance = _calculateDistance(
//             _currentLocation.latitude, _currentLocation.longitude, lat, lng);
//         String availability = _getAvailability();

//         spots.add({
//           "name": name,
//           "address": address,
//           "lat": lat,
//           "lng": lng,
//           "distance": distance,
//           "availability": availability,
//         });
//       }

//       spots.sort((a, b) => a["distance"].compareTo(b["distance"]));

//       setState(() {
//         _parkingSpots = spots;
//       });

//       _showParkingModal();
//     } else {
//       print("Failed to load parking spots");
//     }
//   }

//   double _calculateDistance(
//       double lat1, double lon1, double lat2, double lon2) {
//     const double R = 6371;
//     double dLat = (lat2 - lat1) * (3.141592653589793 / 180);
//     double dLon = (lon2 - lon1) * (3.141592653589793 / 180);

//     double a = (sin(dLat / 2) * sin(dLat / 2)) +
//         cos(lat1 * (3.141592653589793 / 180)) *
//             cos(lat2 * (3.141592653589793 / 180)) *
//             (sin(dLon / 2) * sin(dLon / 2));

//     double c = 2 * atan2(sqrt(a), sqrt(1 - a));
//     return R * c;
//   }

//   String _getAvailability() {
//     List<String> statuses = ["Available", "Limited", "Full"];
//     return statuses[DateTime.now().second % 3];
//   }

//   void _showParkingModal() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       clipBehavior: Clip.antiAliasWithSaveLayer,
//       isScrollControlled: true,
//       builder: (BuildContext context) {
//         return Container(
//           padding: const EdgeInsets.all(16.0),
//           height: MediaQuery.of(context).size.height * 0.6,
//           child: Column(
//             mainAxisSize: MainAxisSize.max,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               const Text(
//                 "Nearby Parking Spots",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: _parkingSpots.isEmpty
//                     ? const Center(child: CircularProgressIndicator())
//                     : ListView.builder(
//                         itemCount: _parkingSpots.length,
//                         itemBuilder: (context, index) {
//                           var spot = _parkingSpots[index];
//                           return Card(
//                             margin: const EdgeInsets.symmetric(vertical: 5),
//                             child: ListTile(
//                               title: Text(
//                                 spot["name"],
//                                 style: const TextStyle(fontWeight: FontWeight.bold),
//                               ),
//                               subtitle: Text(
//                                   "${spot["address"]}\nDistance: ${spot["distance"].toStringAsFixed(2)} km"),
//                               trailing: Chip(
//                                 label: Text(spot["availability"]),
//                                 backgroundColor: spot["availability"] == "Available"
//                                     ? Colors.green
//                                     : spot["availability"] == "Limited"
//                                     ? Colors.orange
//                                     : Colors.red,
//                               ),
//                               onTap: () {
//                                 // Navigate to DetailPage and pass data
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => BookingPage(),
//                                   ),
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       ),
//               ),
//               ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text("Close"),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: _currentLocation,
//               zoom: 15,
//             ),
//             markers: {
//               Marker(
//                 markerId: const MarkerId("currentLocation"),
//                 position: _currentLocation,
//                 infoWindow: const InfoWindow(title: "You are here"),
//               )
//             },
//           ),
//           Positioned(
//             bottom: 40,
//             left: 20,
//             right: 20,
//             child: ElevatedButton(
//               onPressed: _fetchParkingSpots,
//               style: ElevatedButton.styleFrom(
//                 fixedSize: const Size(200, 50),
//               ),
//               child: const Text("Show Nearby Parking"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
