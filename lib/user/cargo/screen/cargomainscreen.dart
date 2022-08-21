import 'dart:io';
import 'package:aimcabuser/user/cargo/model/add_booking_details.dart';
import 'package:aimcabuser/user/cargo/model/selectcargo.dart';
import 'package:aimcabuser/user/screens/DashBoard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geocoder/model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:place_picker/entities/localization_item.dart';
import 'package:place_picker/entities/location_result.dart';
import 'package:place_picker/widgets/place_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:lottie/lottie.dart' as lottie;

import '../../../common/drawer_widget.dart';
import '../../../common/topbar.dart';
import '../../../utils/Constant.dart';
import '../../../utils/util.dart';
import '../../model/RideEstimate.dart';
import '../../model/User.dart';
import '../model/selectparcel.dart';
import '../providers.dart';
import 'deliverycomplete.dart';

class CargoScreen extends StatefulWidget {
  const CargoScreen({Key key}) : super(key: key);

  @override
  State<CargoScreen> createState() => _CargoScreenState();
}

class _CargoScreenState extends State<CargoScreen> {
  final _formKey = GlobalKey<FormState>();
  String _mapStyle = "";
  User _user;
  Socket socket;
  Address address;
  Address destinationAddress;
  double CAMERA_ZOOM = 13;
  double lon = 0;
  bool isDestinationLocation = true;
  // bool isNextButton = false;
  // bool detail = false;
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
  List<bool> isSelected = [false, false, false, false, false,];
  List<bool> veh = [false, false, false, ];
  List<int> categorydata = [];
  int categoryId;
  int vehid;
  String vehicleType;
  String parcelType;

// List of coordinates to join
  List<LatLng> polylineCoordinates = [];

// Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};
  //image picker
  bool uploadimg = false;
  PickedFile carSide1File;
  PickedFile carSide2File;
  PickedFile carSide3File;

  double lat = 0;
  TextEditingController pkgsizetextcontrlr = TextEditingController();
  TextEditingController pkgweighttextcontrlr = TextEditingController();
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _user = (await getUser());
      if (kDebugMode) {
        print("data of user:${_user.email}");
      }
      // connectToServer();
      // getDriversLocation();
      // getRunningRideData();
    });
    // final details = Provider.of<BookingProvider>(context).shoeDetails;
    // final isNext = Provider.of<BookingProvider>(context).getIsNext;
    _getCurrentLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
     final bookingProvider = Provider.of<BookingProvider>(context,listen: true);
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
      body: Form(
        key: _formKey,
        child: Container(
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
                                    //location card
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
                                  //choose parcel type
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
                                        itemCount: 5,
                                        itemBuilder: (_, i) {
                                          return categoryList(i, isSelected[i]);
                                        },
                                      )),
                                  //package size
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
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter package size';
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
                                  //package weight
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
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter package weight';
                                              }
                                              return null;
                                            },
                                            controller: pkgweighttextcontrlr,
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
                                  //3 box to upload image
                                  Container(
                                      margin: const EdgeInsets.all(20),
                                      alignment: Alignment.center,
                                      child: const Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text("Upload Cargo Image"),
                                      )),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal:10,vertical: 10),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Card(
                                          elevation: 15,
                                          child: GestureDetector(
                                            child: Container(
                                              height: 90,
                                              width: 90,
                                             color: Colors.white,
                                              child: Center(
                                                child: carSide1File == null
                                                    ? const Icon(
                                                        Icons.add_a_photo,
                                                        size: 40,
                                                        color: Colors.black,
                                                      )
                                                    : Image.file(
                                                  File(carSide1File.path),
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                            onTap: () async {
                                              final _picker = ImagePicker();
                                              carSide1File = await _picker.getImage(
                                                  source: ImageSource.gallery);
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        Card(
                                          elevation: 15,
                                          child: GestureDetector(
                                            child: Container(
                                              height: 90,
                                              width: 90,
                                              color: Colors.white,
                                              child: Center(
                                                child: carSide2File == null
                                                    ? const Icon(
                                                  Icons.add_a_photo,
                                                  size: 40,
                                                  color: Colors.black,
                                                )
                                                    : Image.file(
                                                  File(carSide2File.path),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            onTap: () async {
                                              final _picker = ImagePicker();
                                              carSide2File = await _picker.getImage(
                                                  source: ImageSource.gallery);
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        Card(
                                          elevation: 15,
                                          child: GestureDetector(
                                            child: Container(
                                              height: 90,
                                              width: 90,
                                              color: Colors.white,
                                              child: Center(
                                                child: carSide3File == null
                                                    ? const Icon(
                                                  Icons.add_a_photo,
                                                  size: 40,
                                                  color: Colors.black,
                                                )
                                                    : Image.file(
                                                  File(carSide3File.path),
                                                  width: 90,
                                                  height: 90,
                                                  //fit: BoxFit.contain,
                                                ),
                                              ),
                                            ),
                                            onTap: () async {
                                              final _picker = ImagePicker();
                                              carSide3File = await _picker.getImage(
                                                  source: ImageSource.gallery);
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(20),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        //back button
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
                                        //continue button
                                        ElevatedButton(
                                          onPressed: () {
                                            if(address!=null && destinationAddress!=null){
                                              if(parcelType!=null){
                                                if(carSide1File!=null && carSide2File!=null && carSide3File!=null){
                                                  if (_formKey.currentState.validate()) {
                                                    bookingProvider.setIsNext=true;
                                                    setState(() {
                                                      isDestinationLocation = false;
                                                    });
                                                  }
                                                }else{
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          title: const Text("Error"),
                                                          content: const Text(
                                                              "Please upload all images"),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              child: const Text(
                                                                  "OK"),
                                                              onPressed: () {
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                            )
                                                          ],
                                                        );
                                                      });
                                                }

                                              }else{
                                                showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return AlertDialog(
                                                        elevation: 10,
                                                        title: const Text("Error",
                                                            style: TextStyle(
                                                                color: Colors.red)),
                                                        content: const Text(
                                                            "Please select parcel type"),
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
                                            }else{
                                              showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      elevation: 10,
                                                      title: const Text("Error",
                                                          style: TextStyle(
                                                              color: Colors.red)),
                                                      content: const Text(
                                                          "Please select destination location"),
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
                                                  vertical: 15, horizontal: 40),
                                            ),
                                          ),
                                          child: Text("continue",
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
                  visible: bookingProvider.getIsNext,
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
                                  const SizedBox(height: 20,),
                                  Container(
                                      height: 125,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: 3,
                                        itemBuilder: (_, i) {
                                          return vehicleList(i, veh[i]);
                                        },
                                      ),),
                                  const SizedBox(height: 20,),

                                  Container(
                                    width: 450,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        print("error stat :${bookingProvider.getError}");
                                        if(vehicleType!=null){
                                          //field must not be null
                                          bookingProvider.setBookingDetails=AddBookingDetails(
                                              userId: _user.sId,
                                              source: address.addressLine,
                                              destination: destinationAddress.addressLine,
                                              vehicleType: vehicleType,
                                              parcelType: parcelType,
                                              sourceLocation: [
                                                address.coordinates.latitude,
                                                address.coordinates.longitude
                                              ],
                                              destinationLocation: [
                                                destinationAddress.coordinates.latitude,
                                                destinationAddress.coordinates.longitude
                                              ],
                                              currentLocation: [
                                                address.coordinates.latitude,
                                                address.coordinates.longitude
                                              ],
                                              isPre: false,
                                              distance: "1234",
                                              tripDate: DateTime.now(),
                                              isRound: false,
                                              amount: 500,
                                              payment: "payment_gateway",
                                              promoCode: "",
                                              packageSize: pkgsizetextcontrlr.text,
                                              packageWeight: pkgweighttextcontrlr.text,
                                              packageImages: [],
                                              roundDropLocation: []
                                          );
                                          bookingProvider.addBookingProvider(
                                              context,
                                              file1: carSide1File.path,
                                              file2: carSide2File.path,
                                              file3: carSide3File.path
                                          );
                                          print("error stat 2 :${bookingProvider.getShowDetails}");
                                          print(bookingProvider.getCargoBookingId);
                                        }else{
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  elevation: 10,
                                                  title: const Text("Error",
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                  content: const Text(
                                                      "Please select vehicle type"),
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
                    visible: bookingProvider.getShowDetails,
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
                                      const SizedBox(height: 20,),
                                      const Text("Your Cargo info"),
                                      const SizedBox(height: 20,),
                                      const Text("Driver info"),
                                      const SizedBox(height: 10,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                        Row(
                                          children: [
                                            const CircleAvatar(backgroundColor: Colors.yellow,radius: 25,),
                                            Column(children: [
                                              const Text("Driver name"),
                                              const Text("Jogn mark"),
                                            ],),
                                          ],
                                        ),
                                          Column(children: [
                                          const Text("OTP"),
                                          const Text("4546"),
                                        ],),
                                      ],),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            children: [
                                              const Text("Arriving Time"),
                                              const Text("12.30"),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              const Text("Vehicle No"),
                                              const Text("LX05E123"),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              const Text("Vehicle Type"),
                                              const Text("Auto"),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Container(
                                        width: 450,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // Navigator.push(context, MaterialPageRoute(builder: (context)=>DashBoard()));
                                            // setState(() {
                                            //   detail=true;
                                            // });
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>DeliveryComplete()));
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
      ),
    );
  }

  Widget categoryList(int i, bool isSelect) {
    List<SelectParcel> selectParcel =[
      SelectParcel(
        url: "https://assets9.lottiefiles.com/packages/lf20_cjKFbz.json",
        name: "Parcel",
      ),
      SelectParcel(
        url: "https://assets10.lottiefiles.com/packages/lf20_gecz9hqm.json",
        name: "Delivery",
      ),
      SelectParcel(
        url: "https://assets10.lottiefiles.com/private_files/lf30_vb7v5ca0.json",
        name: "Grocery",
      ),
      SelectParcel(
        url: "https://assets1.lottiefiles.com/private_files/lf30_thkzdgrl.json",
        name: "Pharma",
      ),
      SelectParcel(
        url: "https://assets6.lottiefiles.com/private_files/lf30_BTdDKs.json",
        name: "Electronic",
      ),
    ];
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
        switch(categoryId){
          case 0:
            {
              parcelType = "Parcel";
            }
            break;
          case 1:
            {
             parcelType = "Delivery";
            }
            break;
          case 2:
            {
              parcelType = "Grocery";
            }
            break;
          case 3:
            {
              parcelType = "Pharma";
            }
            break;
          case 4:
            {
              parcelType = "Electronic";
            }
            break;
        }
        print(parcelType);
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20),
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
              height: 100,
              width: 100,
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: lottie.Lottie.network(
                 selectParcel[i].url?? "https://www.lincoln.com/cmslibs/content/dam/vdm_ford/live/en_us/lincoln/nameplate/aviator/2022/collections/3_2/Avi_std_glgn_34.jpeg/_jcr_content/renditions/cq5dam.web.1280.1280.jpeg",
                  width: 50,
                  height: 50,
                ),
              ),
            ),
          ),
          // const SizedBox(
          //   height: 7,
          // ),
          Padding(
            padding: const EdgeInsets.only(left: 15),
            child: Text(
              selectParcel[i].name??"vehicle",
              maxLines: 2,
              overflow: TextOverflow.visible,
              style: const TextStyle(
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
    List<SelectCargo> selectCargo = [
      SelectCargo(
        url: "https://thumbs.dreamstime.com/b/moving-truck-5819445.jpg",
        name: "truck",
      ),
      SelectCargo(
        url: "https://image.shutterstock.com/image-illustration/mini-truck-isolated-side-view-260nw-1751816231.jpg",
        name: "mini truck",
      ),
      SelectCargo(
        url: "https://us.123rf.com/450wm/norbertsobolewski/norbertsobolewski2006/norbertsobolewski200600029/158239901-mini-asian-truck-side-view-of-small-modern-truck-flat-vector-.jpg",
        name: "Chota hati",
      ),

    ];
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
        print(selectCargo[i].url);
        switch(vehid){
          case 0:
            {
              vehicleType = "Truck";
            }
            break;
          case 1:
            {
              vehicleType = "mini truck";
            }
            break;
          case 2:
            {
              vehicleType = "chota hati";
            }
            break;
        }
        print(vehicleType);
      },
      child: Card(
        elevation: vehid==i?15:0,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
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
                   // "https://www.lincoln.com/cmslibs/content/dam/vdm_ford/live/en_us/lincoln/nameplate/aviator/2022/collections/3_2/Avi_std_glgn_34.jpeg/_jcr_content/renditions/cq5dam.web.1280.1280.jpeg",
                    selectCargo[i].url??"https://www.lincoln.com/cmslibs/content/dam/vdm_ford/live/en_us/lincoln/nameplate/aviator/2022/collections/3_2/Avi_std_glgn_34.jpeg/_jcr_content/renditions/cq5dam.web.1280.1280.jpeg",
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
             Padding(
              padding: const EdgeInsets.only(left: 15),
              child: Text(
                //"vehicle",
                selectCargo[i].name?? "vehicle",
                maxLines: 2,
                overflow: TextOverflow.visible,
                style: const TextStyle(
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
