// To parse this JSON data, do
//
//     final addBookingDetails = addBookingDetailsFromJson(jsonString);

import 'dart:convert';

AddBookingDetails addBookingDetailsFromJson(String str) => AddBookingDetails.fromJson(json.decode(str));

String addBookingDetailsToJson(AddBookingDetails data) => json.encode(data.toJson());

class AddBookingDetails {
  AddBookingDetails({
    this.userId,
    this.amount,
    this.vehicleType,
    this.payment,
    this.source,
    this.destination,
    this.sourceLocation,
    this.destinationLocation,
    this.currentLocation,
    this.distance,
    this.tripDate,
    this.promoCode,
    this.packageSize,
    this.packageWeight,
    this.packageImages,
    this.isPre,
    this.isRound,
    this.roundDropLocation,
  });

  String userId;
  int amount;
  String vehicleType;
  String payment;
  String source;
  String destination;
  List<double> sourceLocation;
  List<double> destinationLocation;
  List<double> currentLocation;
  String distance;
  DateTime tripDate;
  String promoCode;
  String packageSize;
  String packageWeight;
  List<dynamic> packageImages;
  bool isPre;
  bool isRound;
  List<double> roundDropLocation;

  factory AddBookingDetails.fromJson(Map<String, dynamic> json) => AddBookingDetails(
    userId: json["user_id"],
    amount: json["amount"],
    vehicleType: json["vehicle_type"],
    payment: json["payment"],
    source: json["source"],
    destination: json["destination"],
    sourceLocation: List<double>.from(json["source_location"].map((x) => x.toDouble())),
    destinationLocation: List<double>.from(json["destination_location"].map((x) => x.toDouble())),
    currentLocation: List<double>.from(json["current_location"].map((x) => x.toDouble())),
    distance: json["distance"],
    tripDate: DateTime.parse(json["trip_date"]),
    promoCode: json["promo_code"],
    packageSize: json["package_size"],
    packageWeight: json["package_weight"],
    packageImages: List<dynamic>.from(json["package_images"].map((x) => x)),
    isPre: json["is_pre"],
    isRound: json["is_round"],
    roundDropLocation: List<double>.from(json["round_drop_location"].map((x) => x.toDouble())),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "amount": amount,
    "vehicle_type": vehicleType,
    "payment": payment,
    "source": source,
    "destination": destination,
    "source_location": List<dynamic>.from(sourceLocation.map((x) => x)),
    "destination_location": List<dynamic>.from(destinationLocation.map((x) => x)),
    "current_location": List<dynamic>.from(currentLocation.map((x) => x)),
    "distance": distance,
    "trip_date": tripDate.toIso8601String(),
    "promo_code": promoCode,
    "package_size": packageSize,
    "package_weight": packageWeight,
    "package_images": List<dynamic>.from(packageImages.map((x) => x)),
    "is_pre": isPre,
    "is_round": isRound,
    "round_drop_location": List<dynamic>.from(roundDropLocation.map((x) => x)),
  };
}
