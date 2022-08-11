// To parse this JSON data, do
//
//     final abdResponse = abdResponseFromJson(jsonString);

import 'dart:convert';

AbdResponse abdResponseFromJson(String str) => AbdResponse.fromJson(json.decode(str));

String abdResponseToJson(AbdResponse data) => json.encode(data.toJson());

class AbdResponse {
  AbdResponse({
    this.status,
    this.message,
    this.data,
  });

  bool status;
  String message;
  Data data;

  factory AbdResponse.fromJson(Map<String, dynamic> json) => AbdResponse(
    status: json["status"],
    message: json["message"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  Data({
    this.vehicleType,
    this.amount,
    this.paymentDone,
    this.amountReceived,
    this.paymentTime,
    this.source,
    this.destination,
    this.isArrvied,
    this.arrviedTime,
    this.distance,
    this.date,
    this.isPre,
    this.isRound,
    this.status,
    this.cancelReason,
    this.cancelBy,
    this.cancelById,
    this.cancelTime,
    this.tripDate,
    this.isStart,
    this.starttime,
    this.isEnd,
    this.endtime,
    this.packageSize,
    this.packageImage,
    this.id,
    this.userId,
    this.sourceLocation,
    this.destinationLocation,
    this.currentLocation,
    this.payment,
    this.roundDropLocation,
    this.packageWeight,
    this.createdAt,
    this.v,
  });

  String vehicleType;
  int amount;
  bool paymentDone;
  int amountReceived;
  String paymentTime;
  String source;
  String destination;
  bool isArrvied;
  String arrviedTime;
  String distance;
  String date;
  bool isPre;
  bool isRound;
  String status;
  String cancelReason;
  String cancelBy;
  String cancelById;
  String cancelTime;
  DateTime tripDate;
  bool isStart;
  String starttime;
  bool isEnd;
  String endtime;
  String packageSize;
  List<String> packageImage;
  String id;
  String userId;
  List<double> sourceLocation;
  List<double> destinationLocation;
  List<double> currentLocation;
  String payment;
  List<double> roundDropLocation;
  dynamic packageWeight;
  DateTime createdAt;
  int v;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    vehicleType: json["vehicle_type"],
    amount: json["amount"],
    paymentDone: json["payment_done"],
    amountReceived: json["amount_received"],
    paymentTime: json["payment_time"],
    source: json["source"],
    destination: json["destination"],
    isArrvied: json["is_arrvied"],
    arrviedTime: json["arrvied_time"],
    distance: json["distance"],
    date: json["date"],
    isPre: json["is_pre"],
    isRound: json["is_round"],
    status: json["status"],
    cancelReason: json["cancel_reason"],
    cancelBy: json["cancel_by"],
    cancelById: json["cancel_by_id"],
    cancelTime: json["cancel_time"],
    tripDate: DateTime.parse(json["trip_date"]),
    isStart: json["is_start"],
    starttime: json["starttime"],
    isEnd: json["is_end"],
    endtime: json["endtime"],
    packageSize: json["package_size"],
    packageImage: List<String>.from(json["package_image"].map((x) => x)),
    id: json["_id"],
    userId: json["user_id"],
    sourceLocation: List<double>.from(json["source_location"].map((x) => x.toDouble())),
    destinationLocation: List<double>.from(json["destination_location"].map((x) => x.toDouble())),
    currentLocation: List<double>.from(json["current_location"].map((x) => x.toDouble())),
    payment: json["payment"],
    roundDropLocation: List<double>.from(json["round_drop_location"].map((x) => x.toDouble())),
    packageWeight: json["package_weight"],
    createdAt: DateTime.parse(json["createdAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "vehicle_type": vehicleType,
    "amount": amount,
    "payment_done": paymentDone,
    "amount_received": amountReceived,
    "payment_time": paymentTime,
    "source": source,
    "destination": destination,
    "is_arrvied": isArrvied,
    "arrvied_time": arrviedTime,
    "distance": distance,
    "date": date,
    "is_pre": isPre,
    "is_round": isRound,
    "status": status,
    "cancel_reason": cancelReason,
    "cancel_by": cancelBy,
    "cancel_by_id": cancelById,
    "cancel_time": cancelTime,
    "trip_date": tripDate.toIso8601String(),
    "is_start": isStart,
    "starttime": starttime,
    "is_end": isEnd,
    "endtime": endtime,
    "package_size": packageSize,
    "package_image": List<dynamic>.from(packageImage.map((x) => x)),
    "_id": id,
    "user_id": userId,
    "source_location": List<dynamic>.from(sourceLocation.map((x) => x)),
    "destination_location": List<dynamic>.from(destinationLocation.map((x) => x)),
    "current_location": List<dynamic>.from(currentLocation.map((x) => x)),
    "payment": payment,
    "round_drop_location": List<dynamic>.from(roundDropLocation.map((x) => x)),
    "package_weight": packageWeight,
    "createdAt": createdAt.toIso8601String(),
    "__v": v,
  };
}
