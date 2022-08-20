import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static var ISFIRSTTIME = "ISFIRSTTIME";
  static var PREFERENCE_USER_ID = "PREFERENCE_USER_ID";
  static var PREFERENCE_USER_NAME = "PREFERENCE_USER_NAME";
  static var PREFERENCE_USER_VERIFIED = "PREFERENCE_USER_VERIFIED";

  static var DROPLOCATION = "cargo_drop_location";
  static var PREFERENCE_Email_ID = "PREFERENCE_Email_ID";
  static var PREFERENCE_Phone = "PREFERENCE_Phone";
  static var PREFERENCE_Phonee = "PREFERENCE_Phonee";

  static var PREFERENCE_Address = "PREFERENCE_Address";
  static var PREFERENCE_Avatar = "PREFERENCE_Avatar";
  static var PREFERENCE_IS_LOGIN = "PREFERENCE_IS_LOGIN";
  static var PREFERENCE_IS_AUTO_LOGIN = "isAutoLogin";
  static var TOKEN = "TOKEN";
  static var FCMTOKEN = "FCMTOKEN";

  static var USER_TYPE = "USER_TYPE";
  static var PREFERENCE_CATEGORY_ID = "PREFERENCE_CATEGORY_ID";
  static var PREFERENCE_FAVORITE_ID = "PREFERENCE_FAVORITE_ID";

  static SharedPref instancee;

  static SharedPreferences _preferences;

  SharedPref() {
    setPref();
  }

  static Future<void> setPref() async {
    _preferences = _preferences ?? await SharedPreferences.getInstance();
  }

  static SharedPref getInstance() {
    if (instancee == null) {
      return instancee = SharedPref();
    } else {
      return instancee;
    }
  }

  //----------setters----------
//   Future setUserData(String data) async {
//     await setString(PREFERENCE_USER_ID, data);
//   }
  Future setUserId(String id) async {
    await setString(PREFERENCE_USER_ID, id);
  }

  Future setUserName(String name) async {
    await setString(PREFERENCE_USER_NAME, name);
  }

  Future setUserVerified(int userverified) async {
    await setInt(PREFERENCE_USER_VERIFIED, userverified);
  }

  Future setDroploc(String d_loc) async {
    await setString(DROPLOCATION, d_loc);
  }

  Future setEmailId(String email) async {
    await setString(PREFERENCE_Email_ID, email);
  }

  Future setPhone(String phone) async {
    await setString(PREFERENCE_Phone, phone);
  }

  Future setPhonee(String phonee) async {
    await setString(PREFERENCE_Phonee, phonee);
  }

  Future setAddress(String address) async {
    await setString(PREFERENCE_Address, address);
  }

  Future setToken(String token) async {
    await setString(TOKEN, token);
  }

  Future setFcmToken(String fcmToken) async {
    await setString(FCMTOKEN, fcmToken);
  }

  Future setUserType(String type) async {
    await setString(USER_TYPE, type);
  }

  Future setBoolean(String key, bool value) async {
    await _preferences?.setBool(key, value);
  }

  Future setString(String key, String value) async {
    await _preferences?.setString(key, value);
  }

  Future setInt(String key, int value) async {
    await _preferences?.setInt(key, value);
  }

  Future setCategoryId(String id) async {
    await setString(PREFERENCE_CATEGORY_ID, id);
  }

  Future setFavoriteId(String id) async {
    await setString(PREFERENCE_FAVORITE_ID, id);
  }

  //-------getters-------------
  String getUserId() => getString(PREFERENCE_USER_ID);

  String getUserName() => getString(PREFERENCE_USER_NAME);

  int getUserVerified() => getInt(PREFERENCE_USER_VERIFIED);

  String getDroploc() => getString(DROPLOCATION);

  String getEmailId() => getString(PREFERENCE_Email_ID);

  String getPhone() => getString(PREFERENCE_Phone);

  String getPhonee() => getString(PREFERENCE_Phonee);

  String getAddress() => getString(PREFERENCE_Address);

  String getCategoryId() => getString(PREFERENCE_CATEGORY_ID);

  String getFavoriteId() => getString(PREFERENCE_FAVORITE_ID);

  String getUserType() => getString(USER_TYPE);

  bool getBoolean(String key) => _preferences?.getBool(key) ?? false;

  String getToken() => _preferences?.getString(TOKEN);

  String getFcmToken() => _preferences?.getString(FCMTOKEN);

  String getString(String key) {
    var v = _preferences?.getString(key);
    if (v == null) {
      return "";
    }
    return v;
  }

  int getInt(String key) {
    var v = _preferences?.getInt(key);
    if (v == null) {
      return 0;
    }
    return v;
  }

  Future<bool> clear() async {
    var d = await _preferences?.clear();
    return d;
  }
}