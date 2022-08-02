import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/model.dart';

import '../../utils/util.dart';
import '../model/RideEstimate.dart';

class VariableProvider extends ChangeNotifier {
  bool isNextButton = false;
  bool showRideEstimate = false;
  Address address;
  Address destinationAddress;
  RideEstimate rideEstimate;
  bool get getnextbut {
    return isNextButton;
  }

  set setnextbut(bool value) {
    isNextButton = value;
    notifyListeners();
  }

  bool get getShowRideEstimate {
    return showRideEstimate;
  }

  set setShowRideEstimate(bool value) {
    showRideEstimate = value;
    notifyListeners();
  }
  Address get getSourceAddress{
    return address;
  }
  set setSourceAddress(Address value){
    address = value;
  }
  Address get getDestAddress{
    return destinationAddress;
  }
  set setDestAddress(Address value){
    destinationAddress = value;
  }

  Future getTripAmount(BuildContext context, double strat_lat, double start_lang,
      double dest_lat, double dest_lang) async {
    //   showPickup();
    print(strat_lat);
    var dio = Dio();
    dio.options.baseUrl = appUrl;
    showLoader(context);
    var token = await getToken();

    var response = await dio.post(
      '/get-trip-amount',
      data: {
        "origin": "$strat_lat, $start_lang",
        "destination": "$dest_lat, $dest_lang",
      },
      options: Options(
        headers: {
          "Authorization": token // set content-length
        },
      ),
    );
    print(response.data);

    dissmissLoader(context);

    //TODO must look

    rideEstimate = RideEstimate.fromJson(response.data);
    isNextButton = false;
    showRideEstimate = true;
    notifyListeners();
  }
}
