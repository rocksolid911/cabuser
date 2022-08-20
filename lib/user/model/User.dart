class User {
  String userimage;
  String sId;
  String name;
  String username;
  String email;
  String password;
  String mobile;
  String gender;
  String dob;

  User(
      {this.userimage,
        this.sId,
        this.name,
        this.username,
        this.email,
        this.password,
        this.mobile,
        this.gender,
        this.dob});

  User.fromJson(Map<String, dynamic> json) {
    userimage = json['userimage'];
    sId = json['_id'];
    name = json['name'];
    username = json['username'];
    email = json['email'];
    password = json['password'];
    mobile = json['mobile'];
    gender = json['gender'];
    dob = json['dob'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userimage'] = this.userimage;
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['username'] = this.username;
    data['email'] = this.email;
    data['password'] = this.password;
    data['mobile'] = this.mobile;
    data['gender'] = this.gender;
    data['dob'] = this.dob;
    return data;
  }
}
// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

// import 'dart:convert';
//
// User userFromJson(String str) => User.fromJson(json.decode(str));
//
// String userToJson(User data) => json.encode(data.toJson());
//
// class User {
//   User({
//     this.name,
//     this.username,
//     this.licenceNumber,
//     this.userCountry,
//     this.rating,
//     this.gender,
//     this.dob,
//     this.otp,
//     this.isotpVerified,
//     this.isDriverOnline,
//     this.isLive,
//     this.isRide,
//     this.walletAmount,
//     this.userimage,
//     this.socketId,
//     this.firebaseId,
//     this.facebookId,
//     this.googleId,
//     this.id,
//     this.email,
//     this.mobile,
//     this.location,
//     this.type,
//     this.createdAt,
//     this.v,
//   });
//
//   String name;
//   String username;
//   String licenceNumber;
//   String userCountry;
//   int rating;
//   String gender;
//   String dob;
//   String otp;
//   bool isotpVerified;
//   bool isDriverOnline;
//   bool isLive;
//   bool isRide;
//   int walletAmount;
//   String userimage;
//   String socketId;
//   String firebaseId;
//   String facebookId;
//   String googleId;
//   String id;
//   String email;
//   String mobile;
//   List<double> location;
//   String type;
//   DateTime createdAt;
//   int v;
//
//   factory User.fromJson(Map<String, dynamic> json) => User(
//     name: json["name"],
//     username: json["username"],
//     licenceNumber: json["licence_number"],
//     userCountry: json["user_country"],
//     rating: json["rating"],
//     gender: json["gender"],
//     dob: json["dob"],
//     otp: json["otp"],
//     isotpVerified: json["isotp_verified"],
//     isDriverOnline: json["is_driver_online"],
//     isLive: json["is_live"],
//     isRide: json["is_ride"],
//     walletAmount: json["wallet_amount"],
//     userimage: json["userimage"],
//     socketId: json["socket_id"],
//     firebaseId: json["firebase_id"],
//     facebookId: json["facebook_id"],
//     googleId: json["google_id"],
//     id: json["_id"],
//     email: json["email"],
//     mobile: json["mobile"],
//     location: List<double>.from(json["location"].map((x) => x.toDouble())),
//     type: json["type"],
//     createdAt: DateTime.parse(json["createdAt"]),
//     v: json["__v"],
//   );
//
//   Map<String, dynamic> toJson() => {
//     "name": name,
//     "username": username,
//     "licence_number": licenceNumber,
//     "user_country": userCountry,
//     "rating": rating,
//     "gender": gender,
//     "dob": dob,
//     "otp": otp,
//     "isotp_verified": isotpVerified,
//     "is_driver_online": isDriverOnline,
//     "is_live": isLive,
//     "is_ride": isRide,
//     "wallet_amount": walletAmount,
//     "userimage": userimage,
//     "socket_id": socketId,
//     "firebase_id": firebaseId,
//     "facebook_id": facebookId,
//     "google_id": googleId,
//     "_id": id,
//     "email": email,
//     "mobile": mobile,
//     "location": List<dynamic>.from(location.map((x) => x)),
//     "type": type,
//     "createdAt": createdAt.toIso8601String(),
//     "__v": v,
//   };
// }
