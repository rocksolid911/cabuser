import 'dart:async';
import 'dart:convert';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:aimcabuser/common/subscription.dart';
import 'package:aimcabuser/common/topbar.dart';
import 'package:aimcabuser/user/cargo/screen/cargomainscreen.dart';
import 'package:aimcabuser/user/provider/variableprovider.dart';
import 'package:aimcabuser/user/screens/support/support_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker/entities/localization_item.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:socket_io_client/socket_io_client.dart';
import '../../common/SplashScreen.dart';
import '../../common/Varibles.dart';
import '../../common/drawerList_widget.dart';
import '../../common/drawer_widget.dart';
import '../../utils/Constant.dart';
import '../../utils/util.dart';
import '../Dashboard/widget/align_widget_1.dart';
import '../Dashboard/widget/caboption.dart';
import '../cargo/screen/deliverycomplete.dart';
import '../model/AddBookingData.dart';
import '../model/DriverLocationMap.dart';
import '../model/RideEstimate.dart';
import '../model/User.dart';
import 'PromoScreen.dart';
import 'UserAccount.dart';
import 'UserRideHistory.dart';
import 'chatescrren.dart';
import 'userTerms.dart';

class DashBoard extends StatefulWidget {
  @override
  _DashBoardState createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard> {
  String _mapStyle = "";
  User _user;
  Socket socket;
  Address address;
  Address destinationAddress;
  double CAMERA_ZOOM = 13;
  double lon = 0;
  bool isDestinationLocation = true;
  bool isNextButton = false;
  dynamic rideData;
  String promocode = "";
  GoogleMapController mapController;
  Set<Marker> markers = {};
  bool showRideEstimate = false;
  PolylinePoints polylinePoints;
  RideEstimate rideEstimate;
  int selectedCab = -1;
  double showMessage = 0;
  String messageTitle = "";

// List of coordinates to join
  List<LatLng> polylineCoordinates = [];

// Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};

  double lat = 0;

  @override
  void initState() {
    // TODO: implement initState
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    getwalltedeatisl();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _user = (await getUser());
      if (kDebugMode) {
        print("data of user:${_user.email}");
      }
      connectToServer();
      getDriversLocation();
      getRunningRideData();
      _getCurrentLocation();
    });
    super.initState();
  }

  Future<dynamic> getwalltedeatisl() async {
    var dio = Dio();
    var user = await getUser();
    var token = await getToken();

    print("user_id_ride:" + user.sId);
    print("user_id_ride:" + token);
    String urlis = user.sId;
    Varibles.UserId == urlis;
    Varibles.Token == token;
    var response = await dio.get(
      'https://cabandcargo.com/v1.0/user-data/$urlis',
      options: Options(
        headers: {
          "Authorization": token // set content-length
        },
      ),
    );
    List userwalltedata = jsonDecode(response.toString())['data'];
    print("res_wallete_data:" + userwalltedata.toString());

    setState(() {
      for (var i = 0; i < userwalltedata.length; i++) {
        Varibles.user_wallate_balance =
            userwalltedata[i]['wallet_amount'].toString();
      }
    });
  }

  void connectToServer() {
    print("UsserIdddd:" + _user.sId);
    Varibles.SendID = _user.sId;
    Varibles.SenderName = _user.username;

    try {
      // Configure socket transports must be sepecified
      socket = io('https://cabandcargo.com/socket_chat',
          <String, dynamic>{
        'transports': ['websocket'],
        'query': {"id": _user.sId},
        'autoConnect': true,
      });
      socket.connect();

      socket.onConnect((data) => {
            print("IsConnected:" + socket.connected.toString()),
            print("SocketID:" + socket.id.toString())
          });
      socket.on("showBooking",
          (data) => {print("Call1111111114:"), onBookingFound(data)});
      socket.on("OnDriverLocationSend",
          (data) => {print("Call1111111115:"), onBookingFound(data)});

      // Connect to websocket

      // Handle socket events

    } catch (e) {
      print("socket_error:" + e.toString());
    }
  }

  onNewBooking(param0) {
    print(param0.toString());
  }

  _getCurrentLocation() async {
    showLoader(context);
    geo.Geolocator.getCurrentPosition(desiredAccuracy: geo.LocationAccuracy.low)
        .then((geo.Position position) async {
      dissmissLoader(context);
      lat = position.latitude;
      lon = position.longitude;
      final coordinates = Coordinates(position.latitude, position.longitude);
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      address = first;
      print("${first.featureName} : ${first.addressLine}");

      setState(() {});
    }).catchError((e) {
      setState(() {
        lon = 28.6118443;
        lat = 77.2254473;
      });
    });
  }

  Future<void> getRunningRideData() async {
    showLoader(context);
    var dio = Dio();
    dio.options.baseUrl = appUrl;
    polylineCoordinates.clear();
    markers.clear();

    var token = await getToken();
    DateTime date = DateTime.now();
    print("driverId:" + _user.sId);

    var response = await dio.post(
      '/get-current-ride',
      data: {"type": "user", "user_id": _user.sId},
      options: Options(
        headers: {
          "Authorization": token // set content-length
        },
      ),
    );
    print("res_data:" + response.data.toString());
    setState(() {
      rideData = response.data;
    });

    dissmissLoader(context);
    if (rideData['data']['booking']['is_arrvied'] ?? false) {
      print("ride data n rng rdiedata :$rideData");
      Marker startMarker = Marker(
        markerId: MarkerId(response.data['data']['booking']['source']),
        position: LatLng(response.data['data']['booking']['source_location'][0],
            response.data['data']['booking']['source_location'][1]),
        infoWindow: InfoWindow(
          title: response.data['data']['booking']['source'],
          snippet: response.data['data']['booking']['source'],
        ),
        icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(64, 64)),
            'assets/images/car_location.png'),
      );

// Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: MarkerId(response.data['data']['booking']['destination']),
        position: LatLng(
            response.data['data']['booking']['destination_location'][0],
            response.data['data']['booking']['destination_location'][1]),
        infoWindow: InfoWindow(
          title: response.data['data']['booking']['destination'],
          snippet: response.data['data']['booking']['destination'],
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      markers.add(startMarker);
      markers.add(destinationMarker);
      double startLatitude =
          response.data['data']['booking']['source_location'][0];
      double startLongitude =
          response.data['data']['booking']['source_location'][1];
      double destinationLatitude =
          response.data['data']['booking']['destination_location'][0];
      double destinationLongitude =
          response.data['data']['booking']['destination_location'][1];
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

// Accommodate the two locations within the
// camera view of the map
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );
      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);
    } else {
      Marker startMarker = Marker(
        markerId: const MarkerId("driver_location"),
        position: LatLng(
          response.data['data']['driver']['location'][0],
          response.data['data']['driver']['location'][1],
        ),
        infoWindow: const InfoWindow(
          title: "Driver location",
          snippet: "Driver location",
        ),
        icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(64, 64)),
            'assets/images/car_location.png'),
      );

// Destination Location Marker
      Marker destinationMarker = Marker(
        markerId: const MarkerId("pickup_location"),
        position: LatLng(response.data['data']['booking']['source_location'][0],
            response.data['data']['booking']['source_location'][1]),
        infoWindow: const InfoWindow(
          title: "User location",
          snippet: "user",
        ),
        icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(64, 64)),
            'assets/images/rider_location.png'),
      );

      markers.add(startMarker);
      markers.add(destinationMarker);
      double startLatitude = response.data['data']['driver']['location'][0];
      double startLongitude = response.data['data']['driver']['location'][1];
      double destinationLatitude =
          response.data['data']['booking']['source_location'][0];
      double destinationLongitude =
          response.data['data']['booking']['source_location'][1];
      double miny = (startLatitude <= destinationLatitude)
          ? startLatitude
          : destinationLatitude;
      double minx = (startLongitude <= destinationLongitude)
          ? startLongitude
          : destinationLongitude;
      double maxy = (startLatitude <= destinationLatitude)
          ? destinationLatitude
          : startLatitude;
      double maxx = (startLongitude <= destinationLongitude)
          ? destinationLongitude
          : startLongitude;

      double southWestLatitude = miny;
      double southWestLongitude = minx;

      double northEastLatitude = maxy;
      double northEastLongitude = maxx;

// Accommodate the two locations within the
// camera view of the map

      await _createPolylines(startLatitude, startLongitude, destinationLatitude,
          destinationLongitude);
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          100.0,
        ),
      );
    }
    print(response);
  }

  void showPrebook() {
    bool isRoundTrip = false;
    DateTime dateTime = DateTime.now();
    showModalBottomSheet<void>(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setterState) {
          return Container(
            decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0))),
            child: Container(
              margin: const EdgeInsets.only(
                  top: 20, bottom: 5, right: 10, left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(left: 20),
                    child: Text(
                      "Select drop up date & time",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Container(
                    height: 200,
                    child: CupertinoDatePicker(
                      initialDateTime: DateTime.now(),
                      onDateTimeChanged: (DateTime newdate) {
                        dateTime = newdate;
                      },
                      use24hFormat: true,
                      mode: CupertinoDatePickerMode.dateAndTime,
                    ),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    margin: const EdgeInsets.only(left: 20),
                    child: Text(
                      "Looking for round trip?",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Container(
                      alignment: Alignment.topLeft,
                      margin: const EdgeInsets.only(left: 20),
                      child: Row(
                        children: [
                          NeumorphicCheckbox(
                              padding: const EdgeInsets.all(2),
                              value: isRoundTrip,
                              onChanged: (val) {
                                setterState(() {
                                  isRoundTrip = true;
                                });
                              }),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Yes",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.normal, fontSize: 12),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          NeumorphicCheckbox(
                              padding: const EdgeInsets.all(2),
                              value: !isRoundTrip,
                              onChanged: (val) {
                                setterState(() {
                                  isRoundTrip = false;
                                });
                              }),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "No",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.normal, fontSize: 12),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      )),
                  Container(
                    margin: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    child: FlatButton(
                      minWidth: 250,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), // <-- Radius
                      ),
                      color: Theme.of(context).accentColor,
                      child: Text("Confirm",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white)),
                      onPressed: () async {
                        if (dateTime != null) {
                          if (selectedCab != -1) {
                            showLoader(context);
                            var dio = Dio();
                            dio.options.baseUrl = appUrl;

                            var token = await getToken();
                            DateTime date = DateTime.now();
                            var response = await dio.post(
                              '/add-booking-details',
                              data: {
                                "user_id": _user.sId,
                                "vehicle_type":
                                    rideEstimate.data[selectedCab].vehicleType,
                                "amount": rideEstimate.data[selectedCab].amount,
                                "payment": "payment_gateway",
                                "source": address.addressLine,
                                "destination": destinationAddress.addressLine,
                                "source_location": [
                                  address.coordinates.latitude,
                                  address.coordinates.longitude
                                ],
                                "destination_location": [
                                  destinationAddress.coordinates.latitude,
                                  destinationAddress.coordinates.longitude
                                ],
                                "current_location": [
                                  address.coordinates.latitude,
                                  address.coordinates.longitude
                                ],
                                "distance":
                                    rideEstimate.data[selectedCab].distance,
                                "createdAt": date.toString(),
                                "is_pre": true,
                                "is_round": isRoundTrip,
                                "round_drop_location": [
                                  address.coordinates.latitude,
                                  address.coordinates.longitude
                                ],
                                "trip_date": dateTime.toString(),
                                "promo_code": promocode
                              },
                              options: Options(
                                headers: {
                                  "Authorization": token
                                  // set content-length
                                },
                              ),
                            );
                            promocode = "";

                            setState(() {
                              messageTitle = "Your pre-booking is confirmed.";
                              showMessage = 1;
                              isDestinationLocation = true;
                              isNextButton = false;
                              showRideEstimate = false;
                              polylines.clear();
                              markers.clear();
                            });
                            Timer(const Duration(seconds: 3), () {
                              setState(() {
                                showMessage = 0;
                              });
                            });

                            dissmissLoader(context);
                          } else {
                            showError(context, "Please select your");
                          }
                          Navigator.of(context).pop();
                        } else {
                          showSuccess(context, "Please select time");
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var valuepro = Provider.of<VariableProvider>(context);
    rideEstimate = valuepro.rideEstimate;
    Size sizeScreenB = MediaQuery.of(context).size;
    // void showPickup() {
    //   Size sizeScreenB = MediaQuery.of(context).size;
    //   showModalBottomSheet<void>(
    //     isScrollControlled: true,
    //     context: context,
    //     backgroundColor: Colors.transparent,
    //     builder: (BuildContext context) {
    //       return StatefulBuilder(
    //           builder: (BuildContext context, StateSetter setterState) {
    //         return Container(
    //           decoration: const BoxDecoration(
    //               color: Colors.white,
    //               borderRadius: BorderRadius.only(
    //                   topLeft: Radius.circular(20.0),
    //                   topRight: Radius.circular(20.0))),
    //           child: Container(
    //             margin: const EdgeInsets.only(
    //                 top: 20, bottom: 5, right: 10, left: 10),
    //             child: Column(
    //               mainAxisAlignment: MainAxisAlignment.start,
    //               mainAxisSize: MainAxisSize.min,
    //               children: <Widget>[
    //                 Container(
    //                   child: Card(
    //                     elevation: 15,
    //                     shape: const RoundedRectangleBorder(
    //                         borderRadius:
    //                             BorderRadius.all(Radius.circular(10))),
    //                     child: Container(
    //                       child: Row(
    //                         mainAxisSize: MainAxisSize.max,
    //                         mainAxisAlignment: MainAxisAlignment.start,
    //                         children: [
    //                           Container(
    //                             margin:
    //                                 const EdgeInsets.symmetric(horizontal: 10),
    //                             child: Column(
    //                               children: const [
    //                                 Icon(
    //                                   Icons.circle,
    //                                   color: Colors.black,
    //                                   size: 10,
    //                                 ),
    //                                 SizedBox(
    //                                     height: 40,
    //                                     child: VerticalDivider()),
    //                                 Icon(
    //                                   Icons.circle,
    //                                   color: Colors.black,
    //                                   size: 10,
    //                                 )
    //                               ],
    //                             ),
    //                           ),
    //                           Column(
    //                             mainAxisAlignment: MainAxisAlignment.start,
    //                             crossAxisAlignment: CrossAxisAlignment.start,
    //                             children: [
    //                               InkWell(
    //                                 onTap: () async {
    //                                   LocationResult result =
    //                                       await Navigator.of(context).push(
    //                                     MaterialPageRoute(
    //                                       builder: (context) => PlacePicker(
    //                                         kgoogleMapKey,
    //                                         displayLocation: LatLng(lat, lon),
    //                                       ),
    //                                     ),
    //                                   );
    //
    //                                   final coordinates = Coordinates(
    //                                       result.latLng.latitude,
    //                                       result.latLng.longitude);
    //                                   print("result" + result.toString());
    //                                   var addresses = await Geocoder.local
    //                                       .findAddressesFromCoordinates(
    //                                           coordinates);
    //
    //                                   setterState(() {
    //                                     address = addresses.first;
    //                                   });
    //                                   setState(() {});
    //                                 },
    //                                 child: Container(
    //                                     alignment: Alignment.topLeft,
    //                                     width: sizeScreenB.width - 100,
    //                                     margin: const EdgeInsets.all(10),
    //                                     child: Text(
    //                                       address != null
    //                                           ? address.addressLine
    //                                           : "Pick up Location ",
    //                                       maxLines: 5,
    //                                       textAlign: TextAlign.left,
    //                                       style: GoogleFonts.poppins(
    //                                           fontWeight: FontWeight.normal,
    //                                           fontSize: 15,
    //                                           color: Colors.black),
    //                                     )),
    //                               ),
    //                               Center(
    //                                 child: Container(
    //                                   width: 280,
    //                                   decoration: const BoxDecoration(
    //                                     border: Border(
    //                                       bottom: BorderSide(
    //                                           color: Colors.grey, width: 1.0),
    //                                     ),
    //                                   ),
    //                                 ),
    //                               ),
    //                               InkWell(
    //                                 onTap: () async {
    //                                   var prefs =
    //                                       await SharedPreferences.getInstance();
    //                                   LocationResult result =
    //                                       await Navigator.of(context).push(
    //                                     MaterialPageRoute(
    //                                       builder: (context) => PlacePicker(
    //                                         kgoogleMapKey,
    //                                         //  displayLocation: LatLng(lat, lon),
    //                                         localizationItem:
    //                                             LocalizationItem(),
    //                                       ),
    //                                     ),
    //                                   );
    //
    //                                   final coordinates = Coordinates(
    //                                       result.latLng.latitude,
    //                                       result.latLng.longitude);
    //                                   var addresses = await Geocoder.local
    //                                       .findAddressesFromCoordinates(
    //                                           coordinates);
    //                                   setterState(() {
    //                                     destinationAddress = addresses.first;
    //                                   });
    //                                   setState(() {});
    //                                   prefs.setStringList("loc",
    //                                       [destinationAddress.addressLine]);
    //                                 },
    //                                 child: Container(
    //                                   margin: const EdgeInsets.all(10),
    //                                   width: sizeScreenB.width - 100,
    //                                   child: Text(
    //                                     destinationAddress != null
    //                                         ? destinationAddress.addressLine
    //                                         : " I am going to",
    //                                     style: GoogleFonts.poppins(
    //                                       fontWeight: FontWeight.normal,
    //                                       fontSize: 15,
    //                                       color: HexColor(textColor),
    //                                     ),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ],
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //                 Container(
    //                   margin: const EdgeInsets.all(20),
    //                   alignment: Alignment.center,
    //                   child: FlatButton(
    //                     minWidth: 250,
    //                     padding: const EdgeInsets.symmetric(
    //                         vertical: 15, horizontal: 50),
    //                     shape: RoundedRectangleBorder(
    //                       borderRadius: BorderRadius.circular(12), // <-- Radius
    //                     ),
    //                     color: Theme.of(context).colorScheme.secondary,
    //                     child: Text("Next",
    //                         style: GoogleFonts.poppins(
    //                             fontWeight: FontWeight.bold,
    //                             fontSize: 15,
    //                             color: Colors.white)),
    //                     onPressed: () async {
    //                       String startCoordinatesString =
    //                           '(${address.coordinates.latitude}, ${address.coordinates.longitude})';
    //                       String destinationCoordinatesString =
    //                           '(${destinationAddress.coordinates.latitude}, ${destinationAddress.coordinates.longitude})';
    //
    //                         // Start Location Marker
    //
    //                       Marker startMarker = Marker(
    //                         markerId: MarkerId(startCoordinatesString),
    //                         position: LatLng(address.coordinates.latitude,
    //                             address.coordinates.longitude),
    //                         infoWindow: InfoWindow(
    //                           title: startCoordinatesString,
    //                           snippet: address.featureName,
    //                         ),
    //                         icon: await BitmapDescriptor.fromAssetImage(
    //                             const ImageConfiguration(size: Size(64, 64)),
    //                             'assets/images/car_location.png'),
    //                       );
    //
    //                       // Destination Location Marker
    //
    //                       Marker destinationMarker = Marker(
    //                         markerId: MarkerId(destinationCoordinatesString),
    //                         position: LatLng(
    //                             destinationAddress.coordinates.latitude,
    //                             destinationAddress.coordinates.longitude),
    //                         infoWindow: InfoWindow(
    //                           title: '$destinationCoordinatesString',
    //                           snippet: destinationAddress.featureName,
    //                         ),
    //                         icon: BitmapDescriptor.defaultMarker,
    //                       );
    //
    //                       markers.add(startMarker);
    //                       markers.add(destinationMarker);
    //                       double startLatitude = address.coordinates.latitude;
    //                       double startLongitude = address.coordinates.longitude;
    //                       double destinationLatitude =
    //                           destinationAddress.coordinates.latitude;
    //                       double destinationLongitude =
    //                           destinationAddress.coordinates.longitude;
    //                       double miny = (startLatitude <= destinationLatitude)
    //                           ? startLatitude
    //                           : destinationLatitude;
    //                       double minx = (startLongitude <= destinationLongitude)
    //                           ? startLongitude
    //                           : destinationLongitude;
    //                       double maxy = (startLatitude <= destinationLatitude)
    //                           ? destinationLatitude
    //                           : startLatitude;
    //                       double maxx = (startLongitude <= destinationLongitude)
    //                           ? destinationLongitude
    //                           : startLongitude;
    //
    //                       double southWestLatitude = miny;
    //                       double southWestLongitude = minx;
    //
    //                       double northEastLatitude = maxy;
    //                       double northEastLongitude = maxx;
    //
    //                       // Accommodate the two locations within the
    //                      // camera view of the map
    //                       mapController.animateCamera(
    //                         CameraUpdate.newLatLngBounds(
    //                           LatLngBounds(
    //                             northeast: LatLng(
    //                                 northEastLatitude, northEastLongitude),
    //                             southwest: LatLng(
    //                                 southWestLatitude, southWestLongitude),
    //                           ),
    //                           100.0,
    //                         ),
    //                       );
    //                       await _createPolylines(startLatitude, startLongitude,
    //                           destinationLatitude, destinationLongitude);
    //
    //                       setState(() {
    //                         isDestinationLocation = false;
    //                         isNextButton = true;
    //                       });
    //
    //                       Navigator.of(context).pop();
    //                     },
    //                   ),
    //                 )
    //               ],
    //             ),
    //           ),
    //         );
    //       });
    //     },
    //   );
    // }

    GoogleMap googleMap;
    Size sizeScreen = MediaQuery.of(context).size;
    googleMap ??= GoogleMap(
      myLocationEnabled: true,
      polylines: Set<Polyline>.of(polylines.values),
      myLocationButtonEnabled: true,
      markers: Set<Marker>.from(markers),
      initialCameraPosition: CameraPosition(
          bearing: 192.8334901395799,
          target: LatLng(lat, lon),
          tilt: 59.440717697143555,
          zoom: CAMERA_ZOOM),
      onMapCreated: (c) {
        mapController = c;

        if (mounted) {
          setState(() {
            c.setMapStyle(_mapStyle);
          });
        }
      },
      mapType: MapType.normal,
      compassEnabled: false,
      padding: const EdgeInsets.only(
        top: 1.0,
      ),
      onCameraIdle: () {},
      onCameraMove: ((_positionMoving) {
//          setState(() {
//          });
      }),
    );
    return Scaffold(
      drawer: Custom_Drawer(user: _user),
      body: Container(
        child: SafeArea(
          child: Stack(
            children: [
              lat == 0 ? Container() : googleMap,
              const TopBar(),
              AlignWidget1(
                  isNextButton: valuepro.isNextButton,
                  address: address,
                  destinationAddress: destinationAddress,
                  rideEstimate: valuepro.rideEstimate),
              //isDestinationLocation
              Visibility(
                visible: isDestinationLocation,
                child: Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 200),
//                       child: Container(
//                         child: Column(
//                           children: <Widget>[
//                             GestureDetector(
//                               child: Visibility(
//                                 visible: true,
//                                 child: Container(
//                                   width: true ? sizeScreen.width - 20 : 0,
// //                                  margin:EdgeInsets.only(left:20),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.grey.withOpacity(0.4),
//                                         spreadRadius: 2,
//                                         blurRadius: 8,
//                                         offset: const Offset(0, 5),
//                                       )
//                                     ],
//                                     borderRadius: const BorderRadius.only(
//                                       topLeft: Radius.circular(12.0),
//                                       topRight: Radius.circular(12.0),
//                                     ),
//                                   ),
//                                   child: Center(
//                                     child: SingleChildScrollView(
//                                       physics:
//                                           const NeverScrollableScrollPhysics(),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: <Widget>[
//                                           Container(
//                                               alignment: Alignment.topLeft,
//                                               margin: const EdgeInsets.all(10),
//                                               child: Text(
//                                                   "Destination location",
//                                                   style: GoogleFonts.poppins(
//                                                     fontWeight: FontWeight.bold,
//                                                     fontSize: 25,
//                                                     color: HexColor("#3E4958"),
//                                                   ))),
//                                           Container(
//                                             margin: const EdgeInsets.symmetric(
//                                                 vertical: 10, horizontal: 20),
//                                             child: Row(
//                                               children: [
//                                                 CircleAvatar(
//                                                     backgroundColor:
//                                                         Theme.of(context)
//                                                             .accentColor,
//                                                     child: const Icon(
//                                                         Icons.location_on)),
//                                                 const SizedBox(
//                                                   width: 10,
//                                                 ),
//                                                 Container(
//                                                   width: 200,
//                                                   child: Text(
//                                                     address != null
//                                                         ? address.addressLine
//                                                         : "",
//                                                     style: GoogleFonts.poppins(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 13,
//                                                       color:
//                                                           HexColor("#3E4958"),
//                                                     ),
//                                                   ),
//                                                 )
//                                               ],
//                                             ),
//                                           ),
//                                           Container(
//                                             margin: const EdgeInsets.all(20),
//                                             alignment: Alignment.center,
//                                             child: FlatButton(
//                                               padding:
//                                                   const EdgeInsets.symmetric(
//                                                       vertical: 15,
//                                                       horizontal: 30),
//                                               shape: RoundedRectangleBorder(
//                                                 borderRadius:
//                                                     BorderRadius.circular(
//                                                         12), // <-- Radius
//                                               ),
//                                               color:
//                                                   Theme.of(context).accentColor,
//                                               child: Text(
//                                                   "Set destination location",
//                                                   style: GoogleFonts.poppins(
//                                                       fontWeight:
//                                                           FontWeight.bold,
//                                                       fontSize: 15,
//                                                       color: Colors.white)),
//                                               onPressed: () {
//                                                 print('click desination');
//                                                 showPickup();
//                                               },
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0))),
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 20, bottom: 5, right: 10, left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                child: Card(
                                  elevation: 15,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Container(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Column(
                                            children: const [
                                              Icon(
                                                Icons.circle,
                                                color: Colors.black,
                                                size: 10,
                                              ),
                                              SizedBox(
                                                  height: 40,
                                                  child: VerticalDivider()),
                                              Icon(
                                                Icons.circle,
                                                color: Colors.black,
                                                size: 10,
                                              )
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                LocationResult result =
                                                    await Navigator.of(context)
                                                        .push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PlacePicker(
                                                      kgoogleMapKey,
                                                      displayLocation:
                                                          LatLng(lat, lon),
                                                    ),
                                                  ),
                                                );

                                                final coordinates = Coordinates(
                                                    result.latLng.latitude,
                                                    result.latLng.longitude);
                                                print("result" +
                                                    result.toString());
                                                var addresses = await Geocoder
                                                    .local
                                                    .findAddressesFromCoordinates(
                                                        coordinates);

                                                setState(() {
                                                  address = addresses.first;
                                                });
                                                setState(() {});
                                              },
                                              child: Container(
                                                  alignment: Alignment.topLeft,
                                                  width:
                                                      sizeScreenB.width - 100,
                                                  margin:
                                                      const EdgeInsets.all(10),
                                                  child: Text(
                                                    address != null
                                                        ? address.addressLine
                                                        : "Pick up Location ",
                                                    maxLines: 5,
                                                    textAlign: TextAlign.left,
                                                    style: GoogleFonts.poppins(
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontSize: 15,
                                                        color: Colors.black),
                                                  )),
                                            ),
                                            Center(
                                              child: Container(
                                                width: 280,
                                                decoration: const BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors.grey,
                                                        width: 1.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () async {
                                                // await PlacesAutocomplete.show(
                                                //   context: context,
                                                //   apiKey: kgoogleMapKey,
                                                //   radius: 10000000,
                                                //   types: [],
                                                //   startText: startAddressController.text,
                                                //   strictbounds: false,
                                                //   mode: Mode.overlay,
                                                //   language: "en",
                                                //   decoration: InputDecoration(
                                                //     hintText: 'Search',
                                                //     focusedBorder: OutlineInputBorder(
                                                //       borderRadius: BorderRadius.circular(20),
                                                //       borderSide: BorderSide(
                                                //         color: Colors.white,
                                                //       ),
                                                //     ),
                                                //   ),
                                                //   components: [],
                                                // ).then((value) {
                                                //   setState(() {
                                                //     // // predictions = [];
                                                //     // // _startAddress = "";
                                                //     // startAddressController.clear();
                                                //     // markers.clear();
                                                //     // polylines.clear();
                                                //     // polylineCoordinates.clear();
                                                //     // _placeDistance = 0.0;
                                                //   });
                                                //   print(value.description);
                                                //
                                                //     // setState(() {});
                                                //
                                                // }),

                                                var prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                LocationResult result =
                                                    await Navigator.of(context)
                                                        .push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PlacePicker(
                                                      kgoogleMapKey,
                                                      displayLocation:
                                                          LatLng(lat, lon),
                                                    ),
                                                  ),
                                                );
                                                debugPrint("result${result.formattedAddress}");

                                                final coordinates = Coordinates(
                                                    result.latLng.latitude,
                                                    result.latLng.longitude);
                                                var addresses = await Geocoder
                                                    .local
                                                    .findAddressesFromCoordinates(
                                                        coordinates);
                                                setState(() {
                                                  destinationAddress =
                                                      addresses.first;
                                                });
                                                setState(() {});
                                                prefs.setStringList("loc", [
                                                  destinationAddress.addressLine
                                                ]);
                                              },
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.all(10),
                                                width: sizeScreenB.width - 100,
                                                child: Text(
                                                  destinationAddress != null
                                                      ? destinationAddress
                                                          .addressLine
                                                      : " I am going to",
                                                  style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 15,
                                                    color: HexColor(textColor),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(20),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    //cab button
                                    FlatButton(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15, horizontal: 50),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12), // <-- Radius
                                      ),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      child: Text("Cab",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.white)),
                                      onPressed: () async {
                                        if (destinationAddress != null) {
                                          String startCoordinatesString =
                                              '(${address.coordinates.latitude}, ${address.coordinates.longitude})';
                                          String destinationCoordinatesString =
                                              '(${destinationAddress.coordinates.latitude}, ${destinationAddress.coordinates.longitude})';

                                          // Start Location Marker

                                          Marker startMarker = Marker(
                                            markerId: MarkerId(
                                                startCoordinatesString),
                                            position: LatLng(
                                                address.coordinates.latitude,
                                                address.coordinates.longitude),
                                            infoWindow: InfoWindow(
                                              title: startCoordinatesString,
                                              snippet: address.featureName,
                                            ),
                                            icon: await BitmapDescriptor
                                                .fromAssetImage(
                                                    const ImageConfiguration(
                                                        size: Size(64, 64)),
                                                    'assets/images/car_location.png'),
                                          );

                                          // Destination Location Marker

                                          Marker destinationMarker = Marker(
                                            markerId: MarkerId(
                                                destinationCoordinatesString),
                                            position: LatLng(
                                                destinationAddress
                                                    .coordinates.latitude,
                                                destinationAddress
                                                    .coordinates.longitude),
                                            infoWindow: InfoWindow(
                                              title:
                                                  destinationCoordinatesString,
                                              snippet: destinationAddress
                                                  .featureName,
                                            ),
                                            icon:
                                                BitmapDescriptor.defaultMarker,
                                          );

                                          markers.add(startMarker);
                                          markers.add(destinationMarker);
                                          double startLatitude =
                                              address.coordinates.latitude;
                                          double startLongitude =
                                              address.coordinates.longitude;
                                          double destinationLatitude =
                                              destinationAddress
                                                  .coordinates.latitude;
                                          double destinationLongitude =
                                              destinationAddress
                                                  .coordinates.longitude;
                                          double miny = (startLatitude <=
                                                  destinationLatitude)
                                              ? startLatitude
                                              : destinationLatitude;
                                          double minx = (startLongitude <=
                                                  destinationLongitude)
                                              ? startLongitude
                                              : destinationLongitude;
                                          double maxy = (startLatitude <=
                                                  destinationLatitude)
                                              ? destinationLatitude
                                              : startLatitude;
                                          double maxx = (startLongitude <=
                                                  destinationLongitude)
                                              ? destinationLongitude
                                              : startLongitude;

                                          double southWestLatitude = miny;
                                          double southWestLongitude = minx;

                                          double northEastLatitude = maxy;
                                          double northEastLongitude = maxx;

                                          // Accommodate the two locations within the
                                          // camera view of the map
                                          mapController.animateCamera(
                                            CameraUpdate.newLatLngBounds(
                                              LatLngBounds(
                                                northeast: LatLng(
                                                    northEastLatitude,
                                                    northEastLongitude),
                                                southwest: LatLng(
                                                    southWestLatitude,
                                                    southWestLongitude),
                                              ),
                                              100.0,
                                            ),
                                          );
                                          await _createPolylines(
                                              startLatitude,
                                              startLongitude,
                                              destinationLatitude,
                                              destinationLongitude);

                                          setState(() {
                                            isDestinationLocation = false;
                                            valuepro.isNextButton = true;
                                          });

                                          //Navigator.of(context).pop();
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text("Alert",
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                  content: const Text(
                                                      "Please select a destination"),
                                                  actions: <Widget>[
                                                    TextButton(
                                                      child: const Text("OK"),
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    )
                                                  ],
                                                );
                                              });
                                        }
                                      },
                                    ),
                                    //cargo button
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const CargoScreen()
                                                //DeliveryComplete()
                                                ));
                                      },
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .secondary),
                                        shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.0),
                                        )),
                                        padding: MaterialStateProperty.all<
                                            EdgeInsetsGeometry>(
                                          const EdgeInsets.symmetric(
                                              vertical: 15, horizontal: 50),
                                        ),
                                      ),
                                      child: Text("cargo",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.white)),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              //showRideEstimate
              Visibility(
                visible: valuepro.getShowRideEstimate,
                child: Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: SafeArea(
                        child: AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        child: Column(
                          children: <Widget>[
                            GestureDetector(
                              child: Visibility(
                                visible: true,
                                child: rideEstimate != null
                                    ? Container(
                                        width: true ? sizeScreen.width - 20 : 0,
//                                  margin:EdgeInsets.only(left:20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.4),
                                              spreadRadius: 2,
                                              blurRadius: 8,
                                              offset: const Offset(0, 5),
                                            )
                                          ],
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12.0),
                                            topRight: Radius.circular(12.0),
                                          ),
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Container(
                                              alignment: Alignment.topLeft,
                                              height: 200,
                                              margin: const EdgeInsets.all(10),
                                              child: ListView.builder(
                                                  itemCount:
                                                      rideEstimate.data.length,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  shrinkWrap: true,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return Container(
                                                      child: InkWell(
                                                        onTap: () {
                                                          //TODO working code look up
                                                          setState(() {
                                                            selectedCab = index;
                                                          });
                                                          if (selectedCab ==
                                                              1) {
                                                            showModalBottomSheet(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return const CabOption();
                                                                });
                                                          }
                                                        },
                                                        child: Card(
                                                          child: Container(
                                                            width: 130,
                                                            margin:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    vertical:
                                                                        10),
                                                            child: Column(
                                                              children: [
                                                                Image.network(
                                                                  // "https://cabandcargo.com/${rideEstimate.data[index].image}",
                                                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSgDsthmI_kEgeQTzTClpzNBF0qJC6SAHe1Mg&usqp=CAU",
                                                                  height: 50,
                                                                  width: 50,
                                                                ),
                                                                Container(
                                                                    margin: const EdgeInsets
                                                                            .symmetric(
                                                                        vertical:
                                                                            5),
                                                                    child: Text(
                                                                      rideEstimate
                                                                          .data[
                                                                              index]
                                                                          .vehicleType,
                                                                      style: GoogleFonts.poppins(
                                                                          fontWeight: FontWeight
                                                                              .normal,
                                                                          fontSize:
                                                                              18,
                                                                          color:
                                                                              Colors.black),
                                                                    )),
                                                                Text(
                                                                  "₹" +
                                                                      rideEstimate
                                                                          .data[
                                                                              index]
                                                                          .amount
                                                                          .toStringAsFixed(
                                                                              2),
                                                                  style: GoogleFonts.poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontSize:
                                                                          20,
                                                                      color: HexColor(
                                                                          "3E4958")),
                                                                ),
                                                                Container(
                                                                    width: 100,
                                                                    decoration: BoxDecoration(
                                                                        color: selectedCab ==
                                                                                index
                                                                            ? Theme.of(context)
                                                                                .accentColor
                                                                            : Colors
                                                                                .grey,
                                                                        borderRadius:
                                                                            const BorderRadius.all(Radius.circular(20))),
                                                                    child: Center(
                                                                        child: Text(
                                                                      rideEstimate
                                                                              .data[index]
                                                                              .time
                                                                              .toStringAsFixed(2) +
                                                                          " mins",
                                                                      style: GoogleFonts.poppins(
                                                                          fontWeight: FontWeight
                                                                              .normal,
                                                                          fontSize:
                                                                              15,
                                                                          color:
                                                                              Colors.white),
                                                                    ))),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                            Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10,
                                                        horizontal: 15),
                                                child: Row(children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Estimated trip time",
                                                            style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 15,
                                                                color: HexColor(
                                                                    "97ADB6")),
                                                          ),
                                                          Text(
                                                            rideEstimate.data
                                                                    .isNotEmpty
                                                                ? "${rideEstimate.data.first.time.toStringAsFixed(2)} mins"
                                                                : "0 mins",
                                                            style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontSize: 15,
                                                                color: Colors
                                                                    .blue),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        width: 30,
                                                      ),
                                                      Column(
                                                        children: [
                                                          Container(
                                                            child: Text(
                                                              "Wallet:₹${Varibles.user_wallate_balance}",
                                                              style: GoogleFonts.poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 18,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .accentColor),
                                                            ),
                                                          ),
                                                          Container(
                                                            child: TextButton(
                                                                onPressed:
                                                                    //TODO working code look it up
                                                                    () async {
                                                                  final result = await Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              PromoScreen()));
                                                                  promocode =
                                                                      result;
                                                                },
                                                                child: Text(
                                                                  "Apply promocode",
                                                                  style: GoogleFonts.poppins(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .normal,
                                                                      fontSize:
                                                                          13,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .accentColor),
                                                                )),
                                                          ),
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ])),
                                            Center(
                                              child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              10),
                                                      alignment:
                                                          Alignment.center,
                                                      child: FlatButton(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 15,
                                                                horizontal: 30),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        color: Theme.of(context)
                                                            .accentColor,
                                                        child: Text("BOOK NOW",
                                                            style: GoogleFonts
                                                                .poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        15,
                                                                    color: Colors
                                                                        .white)),
                                                        onPressed: () async {
                                                          if (selectedCab !=
                                                              -1) {
                                                            // print("data to be send :${_user.sId}, ${rideEstimate
                                                            //     .data[
                                                            // selectedCab]
                                                            //     .vehicleType},${rideEstimate
                                                            //     .data[
                                                            // selectedCab]
                                                            //     .amount},${address
                                                            //     .addressLine},${destinationAddress
                                                            //     .addressLine},${address.coordinates.latitude}");
                                                            showLoader(context);
                                                            var dio = Dio();
                                                            dio.options
                                                                    .baseUrl =
                                                                appUrl;
                                                            var token =
                                                                await getToken();
                                                            DateTime date =
                                                                DateTime.now();
                                                            var response =
                                                                await dio.post(
                                                              '/add-booking-details',
                                                              data: {
                                                                "user_id":
                                                                    _user.sId,
                                                                "vehicle_type":
                                                                    rideEstimate
                                                                        .data[
                                                                            selectedCab]
                                                                        .vehicleType,
                                                                "amount":
                                                                    rideEstimate
                                                                        .data[
                                                                            selectedCab]
                                                                        .amount,
                                                                "payment":
                                                                    "payment_gateway",
                                                                "source": address
                                                                    .addressLine,
                                                                "destination":
                                                                    destinationAddress
                                                                        .addressLine,
                                                                "source_location":
                                                                    [
                                                                  address
                                                                      .coordinates
                                                                      .latitude,
                                                                  address
                                                                      .coordinates
                                                                      .longitude
                                                                ],
                                                                "destination_location":
                                                                    [
                                                                  destinationAddress
                                                                      .coordinates
                                                                      .latitude,
                                                                  destinationAddress
                                                                      .coordinates
                                                                      .longitude
                                                                ],
                                                                "current_location":
                                                                    [
                                                                  address
                                                                      .coordinates
                                                                      .latitude,
                                                                  address
                                                                      .coordinates
                                                                      .longitude
                                                                ],
                                                                "distance":
                                                                    rideEstimate
                                                                        .data[
                                                                            selectedCab]
                                                                        .distance,
                                                                "createdAt": date
                                                                    .toString(),
                                                                "is_pre": false,
                                                                "is_round":
                                                                    false,
                                                                "round_drop_location":
                                                                    [
                                                                  address
                                                                      .coordinates
                                                                      .latitude,
                                                                  address
                                                                      .coordinates
                                                                      .longitude
                                                                ],
                                                                "trip_date": date
                                                                    .toString(),
                                                                "promo_code":
                                                                    promocode
                                                              },
                                                              options: Options(
                                                                headers: {
                                                                  "Authorization":
                                                                      token
                                                                  // set content-length
                                                                },
                                                              ),
                                                            );
                                                            // print(response);
                                                            // print(
                                                            //     response.data);
                                                            print(
                                                                'api response${response.data}');

                                                            promocode = "";
                                                            var value =
                                                                AddBookingData
                                                                    .fromJson(
                                                                        response
                                                                            .data);
                                                            // print(value);
                                                            //  var test = {
                                                            //    'booking_id':
                                                            //        value
                                                            //            .data.sId,
                                                            //    'username':
                                                            //        _user.name,
                                                            //    "photo": _user
                                                            //        .userimage,
                                                            //    'booking_details':
                                                            //        {
                                                            //      "vehicle_type":
                                                            //          rideEstimate
                                                            //              .data[
                                                            //                  selectedCab]
                                                            //              .vehicleType,
                                                            //      "amount":
                                                            //          rideEstimate
                                                            //              .data[
                                                            //                  selectedCab]
                                                            //              .amount,
                                                            //      "payment_done":
                                                            //          false,
                                                            //      "payment_time":
                                                            //          "",
                                                            //      "is_arrvied":
                                                            //          false,
                                                            //      "arrvied_time":
                                                            //          "",
                                                            //      "date": "",
                                                            //      "is_pre": false,
                                                            //      "is_round":
                                                            //          false,
                                                            //      "trip_date":
                                                            //          "2021-04-06T00:00:00.000+00:00",
                                                            //      "is_start":
                                                            //          false,
                                                            //      "starttime": "",
                                                            //      "is_end": false,
                                                            //      "endtime": "",
                                                            //      "_id": value
                                                            //          .data.sId,
                                                            //      "user_id":
                                                            //          _user.sId,
                                                            //      "source": address
                                                            //          .addressLine,
                                                            //      "destination":
                                                            //          destinationAddress
                                                            //              .addressLine,
                                                            //      "source_location":
                                                            //          [
                                                            //        address
                                                            //            .coordinates
                                                            //            .latitude,
                                                            //        address
                                                            //            .coordinates
                                                            //            .longitude
                                                            //      ],
                                                            //      "destination_location":
                                                            //          [
                                                            //        destinationAddress
                                                            //            .coordinates
                                                            //            .latitude,
                                                            //        destinationAddress
                                                            //            .coordinates
                                                            //            .longitude
                                                            //      ],
                                                            //      "current_location":
                                                            //          [
                                                            //        address
                                                            //            .coordinates
                                                            //            .latitude,
                                                            //        address
                                                            //            .coordinates
                                                            //            .longitude
                                                            //      ],
                                                            //      "distance":
                                                            //          rideEstimate
                                                            //              .data[
                                                            //                  selectedCab]
                                                            //              .distance,
                                                            //      "payment":
                                                            //          "cash",
                                                            //      "round_drop_location":
                                                            //          [
                                                            //        address
                                                            //            .coordinates
                                                            //            .latitude,
                                                            //        address
                                                            //            .coordinates
                                                            //            .longitude
                                                            //      ],
                                                            //      "createdAt": date
                                                            //          .toString()
                                                            //    }
                                                            //  };

                                                            try {
                                                              print(
                                                                  "=================================================================");
                                                              // print(test);
                                                              //TODO chk for socket events
                                                              print(
                                                                  'api value response${value.data.amount}');

                                                              socket.emit(
                                                                  'showBooking',
                                                                  value.data
                                                                      .toString());
                                                              print(
                                                                  "ride dta : $rideData");
                                                            } catch (err) {
                                                              print(
                                                                  "========== Error =================");
                                                              print(err);
                                                            }

                                                            //TODO look it up working code
                                                            setState(() {
                                                              isDestinationLocation =
                                                                  true;
                                                              valuepro.isNextButton =
                                                                  false;
                                                              showRideEstimate =
                                                                  false;
                                                              polylines.clear();
                                                              markers.clear();
                                                            });

                                                            //dissmissLoader(context);
                                                          } else {
                                                            Get.snackbar("Error", "Please select your ride");
                                                            // showError(context,
                                                            //     "Please select your ride");
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.all(
                                                              10),
                                                      alignment:
                                                          Alignment.center,
                                                      child: FlatButton(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 15,
                                                                horizontal: 30),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  12), // <-- Radius
                                                        ),
                                                        color:
                                                            HexColor("DADADA"),
                                                        child: Text("PRE-BOOK",
                                                            style: GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 15,
                                                                color: Theme.of(
                                                                        context)
                                                                    .accentColor)),
                                                        onPressed: () {
                                                          showPrebook();
                                                          //        showPickup();
                                                        },
                                                      ),
                                                    ),
                                                  ]),
                                            )
                                          ],
                                        ))
                                    : const Text("null"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))),
              ),
              rideData != null
                  ? rideData['data']['booking']['amount'] != null
                      // ?rideData["status"] == true
                      ? Visibility(
                          visible: true,
                          child: Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: SafeArea(
                                  child: AnimatedOpacity(
                                opacity: 1,
                                duration: const Duration(milliseconds: 200),
                                child: Stack(
                                  //overflow: Overflow.visible,
                                  children: [
                                    Container(
                                      alignment: Alignment.bottomCenter,
                                      decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10.0),
                                              topRight: Radius.circular(10.0))),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    left: 10),
                                                child: Column(
                                                  children: [
                                                    Visibility(
                                                      visible: false,
                                                      child: Container(
                                                          child: Text(
                                                        rideData['data']
                                                            ['driver']['name'],
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: HexColor(
                                                                    "3E4958"),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 18),
                                                      )),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    right: 10, top: 20),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                        child: Text(
                                                      rideData['data']
                                                                  ['car_detail']
                                                              ['plate_number']
                                                          .toString()
                                                          .toUpperCase(),
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color: HexColor(
                                                                  "3E4958"),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 20),
                                                    )),
                                                    Container(
                                                        child: Text(
                                                      rideData['data']
                                                              ['car_detail']
                                                          ['model'],
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 10),
                                                    )),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  top: 60, left: 20, right: 20),
                                              child: Card(
                                                elevation: 5,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15.0),
                                                ),
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(20),
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        child: Row(
                                                          children: [
                                                            Text("11.0",
                                                                style: GoogleFonts.poppins(
                                                                    color: Colors
                                                                        .black12,
                                                                    fontSize:
                                                                        15)),
                                                            const SizedBox(
                                                              width: 20,
                                                            ),
                                                            Container(
                                                                width: 200,
                                                                child: Text(
                                                                    rideData['data']
                                                                            [
                                                                            'booking']
                                                                        [
                                                                        'source'],
                                                                    style: GoogleFonts.poppins(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontSize:
                                                                            15)))
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Column(
                                                          children: [
                                                            const Icon(
                                                              Icons.circle,
                                                              color:
                                                                  Colors.blue,
                                                              size: 10,
                                                            ),
                                                            Container(
                                                                height: 50,
                                                                child:
                                                                    const VerticalDivider()),
                                                            Icon(
                                                              Icons
                                                                  .keyboard_arrow_down,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                              size: 20,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        child: Row(
                                                          children: [
                                                            Text("11:24",
                                                                style: GoogleFonts.poppins(
                                                                    color: Colors
                                                                        .black12,
                                                                    fontSize:
                                                                        15)),
                                                            const SizedBox(
                                                              width: 20,
                                                            ),
                                                            Container(
                                                                width: 200,
                                                                child: Text(
                                                                    rideData['data']
                                                                            [
                                                                            'booking']
                                                                        [
                                                                        'destination'],
                                                                    style: GoogleFonts.poppins(
                                                                        color: Colors
                                                                            .black54,
                                                                        fontSize:
                                                                            15)))
                                                          ],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              )),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                bottom: 30),
                                            child: Center(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 5),
                                                    alignment: Alignment.center,
                                                    child: FlatButton(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 15,
                                                          horizontal: 20),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                12), // <-- Radius
                                                      ),
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                      child: Text(
                                                          "Contact driver",
                                                          style: GoogleFonts
                                                              .poppins(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 15,
                                                                  color: Colors
                                                                      .white)),
                                                      onPressed: () async {
                                                        String
                                                            startCoordinatesString =
                                                            '(${address.coordinates.latitude}, ${address.coordinates.longitude})';
                                                        String
                                                            destinationCoordinatesString =
                                                            '(${destinationAddress.coordinates.latitude}, ${destinationAddress.coordinates.longitude})';

// Start Location Marker
                                                        Marker startMarker =
                                                            Marker(
                                                          markerId: MarkerId(
                                                              startCoordinatesString),
                                                          position: LatLng(
                                                              address
                                                                  .coordinates
                                                                  .latitude,
                                                              address
                                                                  .coordinates
                                                                  .longitude),
                                                          infoWindow:
                                                              InfoWindow(
                                                            title:
                                                                '$startCoordinatesString',
                                                            snippet: address
                                                                .featureName,
                                                          ),
                                                          icon: await BitmapDescriptor
                                                              .fromAssetImage(
                                                                  const ImageConfiguration(
                                                                      size: Size(
                                                                          64,
                                                                          64)),
                                                                  'assets/images/car_location.png'),
                                                        );

// Destination Location Marker
                                                        Marker
                                                            destinationMarker =
                                                            Marker(
                                                          markerId: MarkerId(
                                                              destinationCoordinatesString),
                                                          position: LatLng(
                                                              destinationAddress
                                                                  .coordinates
                                                                  .latitude,
                                                              destinationAddress
                                                                  .coordinates
                                                                  .longitude),
                                                          infoWindow:
                                                              InfoWindow(
                                                            title:
                                                                '$destinationCoordinatesString',
                                                            snippet:
                                                                destinationAddress
                                                                    .featureName,
                                                          ),
                                                          icon: BitmapDescriptor
                                                              .defaultMarker,
                                                        );

                                                        markers
                                                            .add(startMarker);
                                                        markers.add(
                                                            destinationMarker);
                                                        double startLatitude =
                                                            address.coordinates
                                                                .latitude;
                                                        double startLongitude =
                                                            address.coordinates
                                                                .longitude;
                                                        double
                                                            destinationLatitude =
                                                            destinationAddress
                                                                .coordinates
                                                                .latitude;
                                                        double
                                                            destinationLongitude =
                                                            destinationAddress
                                                                .coordinates
                                                                .longitude;
                                                        double miny = (startLatitude <=
                                                                destinationLatitude)
                                                            ? startLatitude
                                                            : destinationLatitude;
                                                        double minx = (startLongitude <=
                                                                destinationLongitude)
                                                            ? startLongitude
                                                            : destinationLongitude;
                                                        double maxy = (startLatitude <=
                                                                destinationLatitude)
                                                            ? destinationLatitude
                                                            : startLatitude;
                                                        double maxx = (startLongitude <=
                                                                destinationLongitude)
                                                            ? destinationLongitude
                                                            : startLongitude;

                                                        double
                                                            southWestLatitude =
                                                            miny;
                                                        double
                                                            southWestLongitude =
                                                            minx;

                                                        double
                                                            northEastLatitude =
                                                            maxy;
                                                        double
                                                            northEastLongitude =
                                                            maxx;

// Accommodate the two locations within the
// camera view of the map
                                                        mapController
                                                            .animateCamera(
                                                          CameraUpdate
                                                              .newLatLngBounds(
                                                            LatLngBounds(
                                                              northeast: LatLng(
                                                                  northEastLatitude,
                                                                  northEastLongitude),
                                                              southwest: LatLng(
                                                                  southWestLatitude,
                                                                  southWestLongitude),
                                                            ),
                                                            100.0,
                                                          ),
                                                        );
                                                        await _createPolylines(
                                                            startLatitude,
                                                            startLongitude,
                                                            destinationLatitude,
                                                            destinationLongitude);

                                                        setState(() {
                                                          isDestinationLocation =
                                                              false;
                                                          valuepro.isNextButton =
                                                              true;
                                                        });

                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .fromLTRB(0, 0, 10, 0),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 20,
                                                      vertical: 15,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .accentColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          Varibles.ReciveID =
                                                              rideData['data'][
                                                                      'booking']
                                                                  ['driver_id'];
                                                          Varibles.ReciverName =
                                                              rideData['data']
                                                                      ['driver']
                                                                  ['name'];

                                                          print(
                                                              '=================================iii=============');
                                                          print(Varibles
                                                              .ReciveID);
                                                          print(Varibles
                                                              .ReciverName);

                                                          Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          ChatPage()));
                                                        });
                                                      },
                                                      child: const Text(
                                                        'Chat',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 20),
                                                    child: Neumorphic(
                                                      child: IconButton(
                                                          icon: const Icon(
                                                              Icons.close),
                                                          onPressed: () async {
                                                            var dio = Dio();
                                                            dio.options
                                                                    .baseUrl =
                                                                appUrl;

                                                            showLoader(context);
                                                            var token =
                                                                await getToken();
                                                            DateTime date =
                                                                DateTime.now();
                                                            print("book_id:" +
                                                                rideData['data']
                                                                        [
                                                                        'booking']
                                                                    ['_id']);
                                                            print("driver_id:" +
                                                                _user.sId);
                                                            var response =
                                                                await dio.post(
                                                              '/cancel-a-ride',
                                                              data: {
                                                                "booking_id":
                                                                    rideData['data']
                                                                            [
                                                                            'booking']
                                                                        ['_id'],
                                                                "user_id":
                                                                    _user.sId,
                                                                "cancel_by":
                                                                    "user",
                                                                "cancel_reason":
                                                                    ""
                                                              },
                                                              options: Options(
                                                                headers: {
                                                                  "Authorization":
                                                                      token
                                                                  // set content-length
                                                                },
                                                              ),
                                                            );
                                                            print("cancel_ride:" +
                                                                response
                                                                    .toString());
                                                            // getRunningRideData();

                                                            dissmissLoader(
                                                                context);
                                                          }),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: -40,
                                      child: Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        child: Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 50,
                                              backgroundColor: Colors.white,
                                              child: Container(
                                                  height: 120,
                                                  width: 120,
                                                  child: Image.network(
                                                      rideData['data']['driver']
                                                          ['userimage'],
                                                      width: 80,
                                                      height: 80)),
                                            ),
                                            Container(
                                                child: Text(
                                              rideData['data']['driver']
                                                  ['name'],
                                              style: GoogleFonts.poppins(
                                                  color: HexColor("3E4958"),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))),
                        )
                      : Container(
                          child: Text(""),
                        )
                  : Container(child: Text("hello2")),
              Align(
                alignment: Alignment.topCenter,
                child: AnimatedOpacity(
                    opacity: showMessage,
                    duration: const Duration(seconds: 2),
                    child: Container(
                        margin: const EdgeInsets.only(top: 80),
                        child: Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  bottomLeft: Radius.circular(20))),
                          child: Container(
                              margin: const EdgeInsets.all(10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 10,
                                    color: HexColor("1152FD"),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    messageTitle,
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: HexColor("4B545A")),
                                  ),
                                ],
                              )),
                        ))),
              )
            ],
          ),
        ),
      ),
    );
  }

  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    // Initializing PolylinePoints
    polylinePoints = PolylinePoints();

    // Generating the list of coordinates to be used for
    // drawing the polylines
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      kgoogleMapKey, // Google Maps API Key
      PointLatLng(startLatitude, startLongitude),
      PointLatLng(destinationLatitude, destinationLongitude),
      travelMode: TravelMode.driving,
    );

    // Adding the coordinates to the list
    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    // Defining an ID
    PolylineId id = const PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Theme.of(context).accentColor,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;
    setState(() {});
  }

  Future<void> getDriversLocation() async {
    var dio = Dio();
    dio.options.baseUrl = appUrl;
    showLoader(context);
    var loc = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.low);

    var token = await getToken();

    var response = await dio.post(
      '/get-drivers-for-booking',
      data: {
        "current_location": [loc.latitude, loc.longitude]
      },
      options: Options(
        headers: {
          "Authorization": token // set content-length
        },
      ),
    );
    print(response);
    var value = LocationMapData.fromJson(response.data);
    print(value);

    for (int i = 0; i < value.data.length; i++) {
      markers.add(Marker(
        markerId: MarkerId('location_$i'),
        position:
            LatLng(value.data[i].location.first, value.data[i].location.last),
        draggable: false,
        icon: await BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(64, 64)),
            'assets/images/car_location.png'),
      ));
    }
    setState(() {});
  }

  onBookingFound(data) {
    getRunningRideData();
  }
}

