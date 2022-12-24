import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../utils/util.dart';
import '../../model/RideEstimate.dart';
import '../../provider/variableprovider.dart';

class AlignWidget1 extends StatefulWidget {
  AlignWidget1({
    Key key,
    @required this.isNextButton,
    @required this.address,
    @required this.destinationAddress,
    @required this.rideEstimate,
  }) : super(key: key);

 final bool isNextButton;
  final Address address;
  final Address destinationAddress;
 final RideEstimate rideEstimate;

  set showRideEstimate(bool showRideEstimate) {}

  @override
  State<AlignWidget1> createState() => _AlignWidget1State();
}

class _AlignWidget1State extends State<AlignWidget1> {
  @override
  Widget build(BuildContext context) {
    var valuepro = Provider.of<VariableProvider>(context);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Visibility(
        visible: widget.isNextButton,
        child: Container(
          margin: const EdgeInsets.all(20),
          alignment: Alignment.bottomCenter,
          child: ElevatedButton(
            // minWidth: 250,

            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
              // shape: RoundedRectangleBorder(
              //   borderRadius: BorderRadius.circular(12), // <-- Radius
              // ),
              color: Theme.of(context).accentColor,
              child: Text(
                "Next",
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.white),
              ),
            ),
            // onPressed: () async {
            //   //   showPickup();
            //   var dio = Dio();
            //   dio.options.baseUrl = appUrl;
            //   showLoader(context);
            //   var token = await getToken();
            //
            //   var response = await dio.post(
            //     '/get-trip-amount',
            //     data: {
            //       "origin":
            //       "${widget.address.coordinates.latitude}, ${widget.address.coordinates.longitude}",
            //       "destination":
            //       "${widget.destinationAddress.coordinates.latitude}, ${widget.destinationAddress.coordinates.longitude}",
            //     },
            //     options: Options(
            //       headers: {
            //         "Authorization": token // set content-length
            //       },
            //     ),
            //   );
            //   print(response.data);
            //
            //   dissmissLoader(context);
            //
            //   print(widget.rideEstimate);
            //   //TODO must look
            //   setState(() {
            //     widget.rideEstimate = RideEstimate.fromJson(response.data);
            //     widget.isNextButton = false;
            //     widget.showRideEstimate = true;
            //   });
            // },
            onPressed: ()=>valuepro.getTripAmount(
                context,
                widget.address.coordinates.latitude,
                widget.address.coordinates.longitude,
                widget.destinationAddress.coordinates.latitude,
                widget.destinationAddress.coordinates.longitude),
          ),
        ),
      ),
    );
  }
}
