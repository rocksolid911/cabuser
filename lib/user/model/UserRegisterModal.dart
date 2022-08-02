class UserRegisterModal {
  bool status;
  String token;
  Data data;
  String msg;

  UserRegisterModal({this.status, this.token, this.data, this.msg});

  UserRegisterModal.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    token = json['token'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['token'] = token;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['msg'] = msg;
    return data;
  }
}

class Data {
  String name;
  String username;
  String licenceNumber;
  String password;
  String gender;
  String dob;
  String otp;
  bool isotpVerified;
  bool isDriverOnline;
  bool isLive;
  bool isRide;
  int walletAmount;
  String userimage;
  String socketId;
  String facebookId;
  String googleId;
  String sId;
  String email;
  String mobile;
  List<double> location;
  String type;
  String createdAt;
  int iV;

  Data(
      {this.name,
        this.username,
        this.licenceNumber,
        this.password,
        this.gender,
        this.dob,
        this.otp,
        this.isotpVerified,
        this.isDriverOnline,
        this.isLive,
        this.isRide,
        this.walletAmount,
        this.userimage,
        this.socketId,
        this.facebookId,
        this.googleId,
        this.sId,
        this.email,
        this.mobile,
        this.location,
        this.type,
        this.createdAt,
        this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    username = json['username'];
    licenceNumber = json['licence_number'];
    password = json['password'];
    gender = json['gender'];
    dob = json['dob'];
    otp = json['otp'];
    isotpVerified = json['isotp_verified'];
    isDriverOnline = json['is_driver_online'];
    isLive = json['is_live'];
    isRide = json['is_ride'];
    walletAmount = json['wallet_amount'];
    userimage = json['userimage'];
    socketId = json['socket_id'];
    facebookId = json['facebook_id'];
    googleId = json['google_id'];
    sId = json['_id'];
    email = json['email'];
    mobile = json['mobile'];
    location = json['location'].cast<double>();
    type = json['type'];
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['username'] = username;
    data['licence_number'] = licenceNumber;
    data['password'] = password;
    data['gender'] = gender;
    data['dob'] = dob;
    data['otp'] = otp;
    data['isotp_verified'] = isotpVerified;
    data['is_driver_online'] = isDriverOnline;
    data['is_live'] = isLive;
    data['is_ride'] = isRide;
    data['wallet_amount'] = walletAmount;
    data['userimage'] = userimage;
    data['socket_id'] = socketId;
    data['facebook_id'] = facebookId;
    data['google_id'] = googleId;
    data['_id'] = sId;
    data['email'] = email;
    data['mobile'] = mobile;
    data['location'] = location;
    data['type'] = type;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    return data;
  }
}