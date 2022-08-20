// To parse this JSON data, do
//
//     final abdResError = abdResErrorFromJson(jsonString);

import 'dart:convert';

AbdResError abdResErrorFromJson(String str) => AbdResError.fromJson(json.decode(str));

String abdResErrorToJson(AbdResError data) => json.encode(data.toJson());

class AbdResError {
  AbdResError({
    this.status,
    this.message,
  });

  bool status;
  String message;

  factory AbdResError.fromJson(Map<String, dynamic> json) => AbdResError(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}
