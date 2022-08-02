class RideEstimate {
  bool status;
  List<Data> data;
  String msg;

  RideEstimate({this.status, this.data, this.msg});

  RideEstimate.fromJson(Map<String, dynamic> json) {
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
  String image;
  double distance;
  double time;
  double amount;

  Data({this.vehicleType, this.image, this.distance, this.time, this.amount});

  Data.fromJson(Map<String, dynamic> json) {
    vehicleType = json['vehicle_type'];
    image = json['image'];
    distance = double.parse(json['Distance'].toString());
    time =double.parse( json['Time'].toString());
    amount =double.parse( json['Amount'].toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vehicle_type'] = vehicleType;
    data['image'] = image;
    data['Distance'] = distance;
    data['Time'] = time;
    data['Amount'] = amount;
    return data;
  }
}