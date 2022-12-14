

import 'dart:convert';

import 'package:aimcabuser/utils/util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/abd_response.dart';
import 'package:http/http.dart' as http;

import '../model/add_booking_details.dart';

class CargoApi{
  int _statusCode;
  int get getStatusCode => _statusCode;
  set setStatusCode(int value) {
    _statusCode = value;
  }
  String _message;
  String get getMessage => _message;
  set setMessage(String value) {
    _message = value;
  }

  bool _error;
  bool get getError => _error;
  set setError(bool value) {
    _error = value;
  }
  Future<AbdResponse> getBookingResCargo(AddBookingDetails bookingDetails,BuildContext context) async {
    AbdResponse abdResponse;
    var token = await getToken();
    try {

      var response = await http.post(
        Uri.parse('https://cabandcargo.com/v1.0/cargo/add-booking'),
        headers: {
          "Authorization": token,
          'Content-Type': 'application/json',
        },
        body: addBookingDetailsToJson( bookingDetails),
      );
      print("booking details response ${bookingDetails.toJson()}");
      print("response code ${response.statusCode}");
      print(response.body);
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        abdResponse = abdResponseFromJson(response.body);
        setStatusCode = response.statusCode;
        setMessage = abdResponse.message;
      } else {
        //abdResponse = abdResponseFromJson(response.body);
        setStatusCode = response.statusCode;
        final parsedJson = json.decode(response.body);
        setMessage = parsedJson['message'];
        print(getMessage);
        throw Exception('Failed to load post');
      }
      return abdResponse;
    }
    catch(e){
      print(e);
    }
    return abdResponse;
  }
}