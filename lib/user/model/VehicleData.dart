class RideData {
  bool status;
  List<Data> data;
  String msg;

  RideData({this.status, this.data, this.msg});

  RideData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data.add(Data.fromJson(v));
      });
    }
    msg = json['msg'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    data['msg'] = msg;
    return data;
  }
}

class Data {
  String vehicleType;
  int amount;
  String image;
  String sId;
  String createdAt;
  int iV;

  Data(
      {this.vehicleType,
        this.amount,
        this.image,
        this.sId,
        this.createdAt,
        this.iV});

  Data.fromJson(Map<String, dynamic> json) {
    vehicleType = json['vehicle_type'];
    amount = json['amount'];
    image = json['image'];
    sId = json['_id'];
    createdAt = json['createdAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['vehicle_type'] = vehicleType;
    data['amount'] = amount;
    data['image'] = image;
    data['_id'] = sId;
    data['createdAt'] = createdAt;
    data['__v'] = iV;
    return data;
  }
}