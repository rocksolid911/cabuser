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
  bool error;
  bool shoeDetails = false;
  bool isNextButton = false;
  Future<bool> shE;
  String errorMessage = "";
  String message = "";
  String token = "";
  bool get getShowDetails => shoeDetails;
  bool get getIsNext => isNextButton;
  set setShowDetails(bool value) {
    shoeDetails = value;
    notifyListeners();
  }
  set setIsNext(bool value) {
    isNextButton = value;
    notifyListeners();
  }
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
    print(bookingDetails.toJson());
    abdResponse = await cargoApi.getBookingResCargo(bookingDetails, context);
    print("messege after :${cargoApi.getMessage}");
    switch(cargoApi.getStatusCode){
      case 200:
        dissmissLoader(context);
        setShowDetails = true;
        setIsNext = false;
        notifyListeners();
        showSuccess(context, cargoApi.getMessage);
        break;
      case 403:
        dissmissLoader(context);
        setShowDetails = false;
        setIsNext = true;
        notifyListeners();
       showError(context, cargoApi.getMessage);
        break;
      case 500:
        dissmissLoader(context);
        setShowDetails = false;
        setIsNext = true;
        notifyListeners();
        showError(context, cargoApi.getMessage);
        break;
      default:
        showError(context, cargoApi.getMessage);
        setShowDetails = false;
        setIsNext = true;
        notifyListeners();
        dissmissLoader(context);
        break;
    }


    if (kDebugMode) {
      print("user Id after booking details:{${abdResponse.data.userId}}");
      print(getError.toString());
    }
   // dissmissLoader(context);
  }
}