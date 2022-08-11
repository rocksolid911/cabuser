

import 'dart:convert';

import 'package:aimcabuser/utils/util.dart';
import 'package:flutter/foundation.dart';

import '../model/abd_response.dart';
import 'package:http/http.dart' as http;

import '../model/add_booking_details.dart';

class CargoApi{

  Future<AbdResponse> getBookingResCargo(AddBookingDetails bookingDetails) async {
    AbdResponse abdResponse;
    try {

      var response = await http.post(
        Uri.parse('/get-booking-res'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: addBookingDetailsToJson( bookingDetails),
      );
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        abdResponse = AbdResponse.fromJson(responseBody);
      } else {
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