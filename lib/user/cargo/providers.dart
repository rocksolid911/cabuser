import 'package:aimcabuser/user/cargo/model/add_booking_details.dart';
import 'package:aimcabuser/user/cargo/services/apiservices.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/util.dart';
import 'model/abd_response.dart';

class BookingProvider extends ChangeNotifier {
  AddBookingDetails bookingDetails = AddBookingDetails();
  CargoApi cargoApi = CargoApi();
  AbdResponse abdResponse = AbdResponse();
  bool loading = false;
  bool error;
  bool shoeDetails = false;
  bool isNextButton = false;
  String cargoBookingId = "";
  String errorMessage = "";
  String message = "";
  String token = "";

  bool get getShowDetails => shoeDetails;

  bool get getIsNext => isNextButton;

  String get getCargoBookingId => cargoBookingId;

  set setCargoBookingId(String value) {
    cargoBookingId = value;
  }

  set setShowDetails(bool value) {
    shoeDetails = value;
    notifyListeners();
  }

  set setIsNext(bool value) {
    isNextButton = value;
    notifyListeners();
  }

  AddBookingDetails get getBookingDetails {
    return bookingDetails;
  }

  set setBookingDetails(AddBookingDetails value) {
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

  AbdResponse get getAbdResponse {
    return abdResponse;
  }

  set setAbdResponse(AbdResponse value) {
    abdResponse = value;
    notifyListeners();
  }

  addBookingProvider(context,
      {String file1, String file2, String file3}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    showLoader(context);
    print(bookingDetails.toJson());
    abdResponse = await cargoApi.getBookingResCargo(bookingDetails, context);
    print("messege after :${cargoApi.getMessage}");
    switch (cargoApi.getStatusCode) {
      case 200:
        upLoadImage(context, token, id: abdResponse.data.id,
            file1: file1,
            file2: file2,
            file3: file3);
         dissmissLoader(context);
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

  void upLoadImage(context, String token,
      { String file1, String file2, String file3,
        String id}) async {
    var dio = Dio();
    dio.options.baseUrl =
    // "http://api.cabandcargo.com//v1.0/";
    "https://cabandcargo.com/v1.0/";
    Response response;
    var formdata = FormData.fromMap(
        {
          "package_images": await MultipartFile.fromFile(
            file1,
            filename: "package_images",
          ),
          "package_images": await MultipartFile.fromFile(
            file2,
            filename: "package_images2",
          ),
          "package_images": await MultipartFile.fromFile(
            file3,
            filename: "package_images3",
          ),
        }
    );
    try{
      response = await dio.post(
        "/cargo/upload-package-image/$id",
        data: formdata,
        options:
        Options(
          headers: {
            "Authorization":
            token
            // set content-length
          },
        ),
      );
      print("response of image upload:${response.statusCode}");
      if(response.statusCode==200){
        showSuccess(context, cargoApi.getMessage);
        dissmissLoader(context);
        setShowDetails = true;
        setIsNext = false;
        notifyListeners();
      }else{
        print("hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii");
        showError(context, "Image Uploaded Failed");
        dissmissLoader(context);
      }
    }catch(e) {
      if(e is DioError){
        print("hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii");
        showError(context, "Image Uploaded Failed");
        dissmissLoader(context);
      }
      print(e);
    }

  }
}