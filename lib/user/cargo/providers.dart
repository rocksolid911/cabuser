import 'package:aimcabuser/user/cargo/model/add_booking_details.dart';
import 'package:aimcabuser/user/cargo/services/apiservices.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/util.dart';
import 'model/abd_response.dart';

class BookingProvider extends ChangeNotifier{
  AddBookingDetails bookingDetails = AddBookingDetails();
  CargoApi cargoApi = CargoApi();
  AbdResponse abdResponse = AbdResponse();
  bool loading = false;
  bool error = false;
  String errorMessage = "";
  String message = "";
  String token = "";
  AddBookingDetails get getBookingDetails{
    return bookingDetails;
  }
  set setBookingDetails(AddBookingDetails value){
    bookingDetails = value;
    notifyListeners();
  }
  bool get getLoading {
    return loading;
  }
  set setLoading(bool value) {
    loading = value;
    notifyListeners();
  }
  bool get getError {
    return error;
  }
  set setError(bool value) {
    error = value;
    notifyListeners();
  }
  String get getErrorMessage {
    return errorMessage;
  }
  set setErrorMessage(String value) {
    errorMessage = value;
    notifyListeners();
  }
  String get getMessage {
    return message;
  }
  set setMessage(String value) {
    message = value;
    notifyListeners();
  }
  String get getToken {
    return token;
  }
  set setToken(String value) {
    token = value;
    notifyListeners();
  }

  AbdResponse get getAbdResponse{
    return abdResponse;
  }
  set setAbdResponse(AbdResponse value){
    abdResponse = value;
    notifyListeners();
  }
  addBookingProvider(context)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    showLoader(context);
    abdResponse = await cargoApi.getBookingResCargo(bookingDetails);
    switch(abdResponse.status.toString()){
      case "true":
        dissmissLoader(context);
        showSuccess(context, abdResponse.message);
        break;
      case "false":
        dissmissLoader(context);
       showError(context, abdResponse.message);
        break;

    }


    if (kDebugMode) {
      print("user Id after booking details:{${abdResponse.data.userId}}");
    }
    dissmissLoader(context);
  }
}