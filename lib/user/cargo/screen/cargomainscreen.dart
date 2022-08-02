import 'package:aimcabuser/user/screens/DashBoard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:place_picker/entities/localization_item.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:geolocator/geolocator.dart' as geo;

import '../../../common/drawer_widget.dart';
import '../../../common/topbar.dart';
import '../../../utils/Constant.dart';
import '../../../utils/util.dart';
import '../../model/RideEstimate.dart';
import '../../model/User.dart';

class CargoScreen extends StatefulWidget {
  const CargoScreen({Key key}) : super(key: key);

  @override
  State<CargoScreen> createState() => _CargoScreenState();
}

class _CargoScreenState extends State<CargoScreen> {
  String _mapStyle = "";
  User _user;
  Socket socket;
  Address address;
  Address destinationAddress;
  double CAMERA_ZOOM = 13;
  double lon = 0;
  bool isDestinationLocation = true;
  bool isNextButton = false;
  bool detail = false;
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
  List<bool> isSelected = [false, false, false, false, false, false, false];
  List<bool> veh = [false, false, false, ];
  List<int> categorydata = [];
  int categoryId;
  int vehid;
// List of coordinates to join
  List<LatLng> polylineCoordinates = [];

// Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};

  double lat = 0;
  TextEditingController pkgsizetextcontrlr = TextEditingController();
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

  @override
  void initState() {
    _getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size sizeScreenB = MediaQuery.of(context).size;
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
                      child: Container(
                        height: 400,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0))),
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 20, bottom: 5, right: 10, left: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                      await Navigator.of(
                                                              context)
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

                                                  final coordinates =
                                                      Coordinates(
                                                          result
                                                              .latLng.latitude,
                                                          result.latLng
                                                              .longitude);
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
                                                    alignment:
                                                        Alignment.topLeft,
                                                    width:
                                                        sizeScreenB.width - 100,
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Text(
                                                      address != null
                                                          ? address.addressLine
                                                          : "Pick up Location ",
                                                      maxLines: 5,
                                                      textAlign: TextAlign.left,
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              fontSize: 15,
                                                              color:
                                                                  Colors.black),
                                                    )),
                                              ),
                                              Center(
                                                child: Container(
                                                  width: 280,
                                                  decoration:
                                                      const BoxDecoration(
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
                                                  var prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                  LocationResult result =
                                                      await Navigator.of(
                                                              context)
                                                          .push(
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          PlacePicker(
                                                        kgoogleMapKey,
                                                        //  displayLocation: LatLng(lat, lon),
                                                        localizationItem:
                                                            LocalizationItem(),
                                                      ),
                                                    ),
                                                  );

                                                  final coordinates =
                                                      Coordinates(
                                                          result
                                                              .latLng.latitude,
                                                          result.latLng
                                                              .longitude);
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
                                                    destinationAddress
                                                        .addressLine
                                                  ]);
                                                },
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(10),
                                                  width:
                                                      sizeScreenB.width - 100,
                                                  child: Text(
                                                    destinationAddress != null
                                                        ? destinationAddress
                                                            .addressLine
                                                        : " I am going to",
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      fontSize: 15,
                                                      color:
                                                          HexColor(textColor),
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
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Choose your parcel"),
                                    )),
                                Container(
                                    height: 125,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 7,
                                      itemBuilder: (_, i) {
                                        return categoryList(i, isSelected[i]);
                                      },
                                    )),
                                Container(
                                    margin: const EdgeInsets.all(20),
                                    alignment: Alignment.center,
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Package Size"),
                                    )),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Card(
                                    elevation: 15,
                                    child: Neumorphic(
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter some text';
                                            }
                                            return null;
                                          },
                                          controller: pkgsizetextcontrlr,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            isDense: true,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                    margin: const EdgeInsets.all(20),
                                    alignment: Alignment.center,
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Package Weight"),
                                    )),
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Card(
                                    elevation: 15,
                                    child: Neumorphic(
                                      child: Container(
                                        margin: const EdgeInsets.all(10),
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter some text';
                                            }
                                            return null;
                                          },
                                          controller: pkgsizetextcontrlr,
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            isDense: true,
                                          ),
                                        ),
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
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DashBoard()));
                                        },
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color>(
                                                  Colors.white60),
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
                                        child: Text("Back",
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.black)),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            isDestinationLocation = false;
                                            isNextButton = true;
                                          });
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
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Visibility(
                visible: isNextButton,
                  child: Container(
                  alignment: Alignment.bottomCenter,
                   child: Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.0),
                                topRight: Radius.circular(20.0))),
                        child: Container(
                          margin: const EdgeInsets.only(
                              top: 20, bottom: 5, right: 10, left: 10),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[

                                Container(
                                    margin: const EdgeInsets.all(20),
                                    alignment: Alignment.center,
                                    child: const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Select your cargo"),
                                    ),
                                ),
                                Container(
                                  margin: const EdgeInsets.fromLTRB(20,0,10,0),
                                  alignment: Alignment.center,
                                  child: const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text("ahhjajh vhjajh bhugaj gtyu gsy hjahs gyia hj hag"),
                                  ),
                                ),
                                SizedBox(height: 20,),
                                Container(
                                    height: 125,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: 3,
                                      itemBuilder: (_, i) {
                                        return vehicleList(i, veh[i]);
                                      },
                                    ),),
                                SizedBox(height: 20,),
                                Container(
                                  width: 450,
                                  child: ElevatedButton(
                                    onPressed: () {
                                     // Navigator.push(context, MaterialPageRoute(builder: (context)=>DashBoard()));
                                      setState(() {
                                        detail=true;
                                        isNextButton = false;
                                      });
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
                                    child: Text("Continue",
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: Colors.white)),
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
              ),
            ),
          ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Visibility(
                  visible: detail,
                  child: Container(
                    alignment: Alignment.bottomCenter,
                    child: Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SafeArea(
                        child: AnimatedOpacity(
                          opacity: 1,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0))),
                            child: Container(
                              margin: const EdgeInsets.only(
                                  top: 20, bottom: 5, right: 10, left: 10),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                      await Navigator.of(
                                                          context)
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

                                                      final coordinates =
                                                      Coordinates(
                                                          result
                                                              .latLng.latitude,
                                                          result.latLng
                                                              .longitude);
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
                                                        alignment:
                                                        Alignment.topLeft,
                                                        width:
                                                        sizeScreenB.width - 100,
                                                        margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                        child: Text(
                                                          address != null
                                                              ? address.addressLine
                                                              : "Pick up Location ",
                                                          maxLines: 5,
                                                          textAlign: TextAlign.left,
                                                          style:
                                                          GoogleFonts.poppins(
                                                              fontWeight:
                                                              FontWeight
                                                                  .normal,
                                                              fontSize: 15,
                                                              color:
                                                              Colors.black),
                                                        )),
                                                  ),
                                                  Center(
                                                    child: Container(
                                                      width: 280,
                                                      decoration:
                                                      const BoxDecoration(
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
                                                      var prefs =
                                                      await SharedPreferences
                                                          .getInstance();
                                                      LocationResult result =
                                                      await Navigator.of(
                                                          context)
                                                          .push(
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              PlacePicker(
                                                                kgoogleMapKey,
                                                                //  displayLocation: LatLng(lat, lon),
                                                                localizationItem:
                                                                LocalizationItem(),
                                                              ),
                                                        ),
                                                      );

                                                      final coordinates =
                                                      Coordinates(
                                                          result
                                                              .latLng.latitude,
                                                          result.latLng
                                                              .longitude);
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
                                                        destinationAddress
                                                            .addressLine
                                                      ]);
                                                    },
                                                    child: Container(
                                                      margin:
                                                      const EdgeInsets.all(10),
                                                      width:
                                                      sizeScreenB.width - 100,
                                                      child: Text(
                                                        destinationAddress != null
                                                            ? destinationAddress
                                                            .addressLine
                                                            : " I am going to",
                                                        style: GoogleFonts.poppins(
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          fontSize: 15,
                                                          color:
                                                          HexColor(textColor),
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
                                    SizedBox(height: 20,),
                                    Text("Your Cargo info"),
                                    SizedBox(height: 20,),
                                    Text("Driver info"),
                                    SizedBox(height: 10,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                      Row(
                                        children: [
                                          CircleAvatar(backgroundColor: Colors.yellow,radius: 25,),
                                          Column(children: [
                                            Text("Driver name"),
                                            Text("Jogn mark"),
                                          ],),
                                        ],
                                      ),
                                        Column(children: [
                                        Text("OTP"),
                                        Text("4546"),
                                      ],),
                                    ],),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Text("Arriving Time"),
                                            Text("12.30"),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text("Vehicle No"),
                                            Text("LX05E123"),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text("Vehicle Type"),
                                            Text("Auto"),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Divider(),
                                    Container(
                                      width: 450,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>DashBoard()));
                                          setState(() {
                                            detail=true;
                                          });
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
                                        child: Text("Continue",
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                                color: Colors.white)),
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
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryList(int i, bool isSelect) {
    return InkWell(
      onTap: () {
        setState(() {
          //for multiple selection
          // if (!isSelect) {
          //   categorydata.add(i);
          //   print("id added : $i");
          //
          //   isSelected[i] = true;
          //   print("isSelect-->$isSelect");
          // } else {
          //   categorydata.remove(i);
          //
          //   print(
          //       "id removed : $i");
          //   isSelected[i] = false;
          // }
          categoryId = i;
        });
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      width: 3,
                      color: categoryId == i
                          // ||
                          // categorydata.contains(
                          //     i)
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.white),
                  borderRadius: BorderRadius.circular(20)),
              height: 80,
              width: 80,
              child: Padding(
                padding: const EdgeInsets.all(13.0),
                child: Card(
                  elevation: 15,
                  child: Image.network(
                    "https://www.lincoln.com/cmslibs/content/dam/vdm_ford/live/en_us/lincoln/nameplate/aviator/2022/collections/3_2/Avi_std_glgn_34.jpeg/_jcr_content/renditions/cq5dam.web.1280.1280.jpeg",
                    width: 35,
                    height: 35,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Padding(
            padding: EdgeInsets.only(left: 15),
            child: Text(
              "vehicle",
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
  Widget vehicleList(int i, bool isSelect) {
    return InkWell(
      onTap: () {
        setState(() {
          //for multiple selection
          // if (!isSelect) {
          //   categorydata.add(i);
          //   print("id added : $i");
          //
          //   isSelected[i] = true;
          //   print("isSelect-->$isSelect");
          // } else {
          //   categorydata.remove(i);
          //
          //   print(
          //       "id removed : $i");
          //   isSelected[i] = false;
          // }
          vehid = i;
        });
      },
      child: Card(
        elevation: vehid==i?15:0,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        width: 3,
                        color:
                        // vehid == i
                        // // ||
                        // // categorydata.contains(
                        // //     i)
                        //     ? Theme.of(context).colorScheme.secondary
                        //     :
                        Colors.white),
                    borderRadius: BorderRadius.circular(20)),
                height: 80,
                width: 80,
                child: Padding(
                  padding: const EdgeInsets.all(13.0),
                  child: Image.network(
                    "https://www.lincoln.com/cmslibs/content/dam/vdm_ford/live/en_us/lincoln/nameplate/aviator/2022/collections/3_2/Avi_std_glgn_34.jpeg/_jcr_content/renditions/cq5dam.web.1280.1280.jpeg",
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 15),
              child: Text(
                "vehicle",
                maxLines: 2,
                overflow: TextOverflow.visible,
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
