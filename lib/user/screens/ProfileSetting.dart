import 'package:dio/dio.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../utils/util.dart';
import '../model/User.dart';
import '../model/UserRegisterModal.dart';
import 'DashBoard.dart';

class ProfileSetting extends StatefulWidget {
  @override
  _ProfileSettingState createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  bool isEdit = false;
  bool isMale = true;

  final DateFormat formatter = DateFormat('dd-MMMM-yyyy');
  TextEditingController usernameEdit = TextEditingController();
  TextEditingController passwordEdit = TextEditingController();
  TextEditingController mobileEdit = TextEditingController();
  TextEditingController nameEdit = TextEditingController();
  TextEditingController genderEdit = TextEditingController();
  TextEditingController dobEdit = TextEditingController();
  TextEditingController emailEdit = TextEditingController();
  TextEditingController dob = TextEditingController();
   DateTime _selectedDate;
   User _user;
  final _formKey = GlobalKey<FormState>();
  @override
  void initState() {

    getUser().then((value) => {
      print(value.dob),
      print(value.name),
      print(value.email),
      setState(() {
        nameEdit.text = value.name;
        emailEdit.text = value.email;
        mobileEdit.text = value.mobile;
        nameEdit.text = value.name;
        usernameEdit.text = value.username;
        isMale = value.gender == "Male" ? true : false;
        dob.text = value.dob;
       _user = value;
        _selectedDate = DateTime.parse(value.dob);
      }),

          // if (value != null)
          //   {
          //     setState(() {
          //       _selectedDate = DateTime.parse(value.dob);
          //     }),
          //
          //   }
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size sizeScreen = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin:
                      const EdgeInsets.only(top: 10, left: 15, right: 15, bottom: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          child: Neumorphic(
                              child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: Theme.of(context).accentColor,
                          size: 25,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ))),
                      Text(
                        "Profile",
                        style: GoogleFonts.poppins(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).accentColor),
                      ),
                      TextButton(
                          onPressed: () {
                            print(usernameEdit.text);
                            setState(() {
                              isEdit = !isEdit;
                              if (isEdit) {
                                showSuccess(context, "Now you can edit");
                              }
                            });
                          },
                          child: Text(
                            "Edit",
                            style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.normal,
                                color: HexColor(textColor)),
                          ))
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Neumorphic(
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: isEdit?TextFormField(
                              enabled: isEdit,
                              controller: nameEdit,
                              validator: (value) {
                                Pattern pattern = r'^[a-z A-Z,.\-]+$';
                                RegExp regex = RegExp(pattern.toString());
                                if (!regex.hasMatch(value)) {
                                  return 'Enter Valid Full name';
                                } else {
                                  return null;
                                }
                              },
                              decoration:  const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  labelText: "Enter your full name"),
                            ):TextFormField(
                              enabled: isEdit,
                              controller: nameEdit,
                              validator: (value) {
                                Pattern pattern = r'^[a-z A-Z,.\-]+$';
                                RegExp regex = RegExp(pattern.toString());
                                if (!regex.hasMatch(value)) {
                                  return 'Enter Valid Full name';
                                } else {
                                  return null;
                                }
                              },
                              decoration:  const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                //  labelText:  "Enter your full name",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Neumorphic(
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: isEdit?TextFormField(
                              enabled: isEdit,
                              controller: emailEdit,
                              keyboardType: TextInputType.emailAddress,
                              decoration:  const InputDecoration(
                                isDense: true,
                                labelText: "Enter your email id",
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                              ),
                            ):TextFormField(
                              enabled: isEdit,
                              controller: emailEdit,
                              keyboardType: TextInputType.emailAddress,
                              decoration:  const InputDecoration(
                                isDense: true,
                               // labelText: emailEdit.text,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Neumorphic(
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: isEdit?TextFormField(
                              enabled: isEdit,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              controller: usernameEdit,
                              decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  labelText: "Enter User Name"),
                            ):TextFormField(
                              enabled: isEdit,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              controller: usernameEdit,
                              decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                 // labelText: "Enter User Name",
                                ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Neumorphic(
                          child: Container(
                            margin: const EdgeInsets.all(10),
                            child: isEdit?TextFormField(
                              keyboardType: TextInputType.phone,
                              enabled: isEdit,
                              // validator: MultiValidator([
                              //   MinLengthValidator(10,
                              //       errorText: 'Please enter valid mobile '),
                              //   MaxLengthValidator(10,
                              //       errorText: 'Please enter valid mobile ')
                              // ]),
                              validator: (value) {
                                if (value.length !=10 ) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              controller: mobileEdit,
                              decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  labelText: "Enter Mobile"),
                            ):TextFormField(
                              keyboardType: TextInputType.phone,
                              enabled: isEdit,
                              validator: MultiValidator([
                                MinLengthValidator(10,
                                    errorText: 'Please enter valid mobile '),
                                MaxLengthValidator(10,
                                    errorText: 'Please enter valid mobile ')
                              ]),
                              controller: mobileEdit,
                              decoration: const InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                 // labelText: "Enter Mobile",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            Container(
                                alignment: Alignment.topLeft,
                                margin: const EdgeInsets.only(left: 10),
                                child: Text(
                                  "Gender",
                                  style: GoogleFonts.poppins(
                                      color: HexColor(textColor), fontSize: 15),
                                )),
                            RadioListTile(
                                title: Text("Male",
                                    style: GoogleFonts.poppins(
                                        color: HexColor(textColor),
                                        fontSize: 12)),
                                value: true,
                                groupValue: isMale,
                                onChanged: (val) {
                                  if (isEdit) {
                                    setState(() {
                                      isMale = true;
                                    });
                                  }
                                }),
                            RadioListTile(
                                title: Text(
                                  "Female",
                                  style: GoogleFonts.poppins(
                                      color: HexColor(textColor), fontSize: 12),
                                ),
                                value: false,
                                groupValue: isMale,
                                onChanged: (val) {
                                  if (isEdit) {
                                    setState(() {
                                      isMale = false;
                                    });
                                  }
                                })
                          ],
                        ),
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: () async {
                            if (isEdit) {
                              final DateTime picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.parse(_user.dob),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              var dateVal = DateTime.now();
                              if (picked != null) {
                                if (dateVal.year - picked.year >= 18) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                } else {
                                  showError(context,
                                      "Please select date of birth for 18+");
                                }
                              }
                            }
                          },
                          child: Neumorphic(
                            child: Container(
                              height: 50,
                              width: double.infinity,
                              alignment: Alignment.centerLeft,
                              margin: const EdgeInsets.all(10),
                              child: Text(
                                // _selectedDate == null
                                //     ? "Enter dob"
                                //     : dob.text,
                                dob.text,
                                style: TextStyle(
                                    fontSize: 15, color: HexColor(textColor)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    child: NeumorphicButton(
                        child: Container(
                            padding: const EdgeInsets.all(5),
                            width: sizeScreen.width,
                            child: Center(
                                child: Text(
                              "UPDATE",
                              style: GoogleFonts.poppins(
                                  color: HexColor("#8B9EB0"), fontSize: 15),
                            ))),
                        onPressed: () async {
                          if (_selectedDate != null) {
                            String token = await getToken();
                            if (_formKey.currentState.validate()) {
                              showLoader(context);
                              final DateFormat formatter =
                                  DateFormat('yyyy-MM-dd');
                              //   showPickup();
                              var dio = Dio();
                              dio.options.baseUrl = appUrl;
                              showLoader(context);
                              var token = await getToken();

                              var response = await dio.post(
                                '/profile-update/${_user.sId}',
                                data: {
                                  "name": nameEdit.value.text.toLowerCase(),
                                  "username":
                                      usernameEdit.value.text.toLowerCase(),
                                  "email": emailEdit.value.text.toLowerCase(),
                                  "mobile": mobileEdit.value.text.toLowerCase(),
                                  "gender": isMale ? "Male" : "Female",
                                  "dob": formatter.format(_selectedDate),
                                },
                                options: Options(
                                  headers: {
                                    "Authorization": token // set content-length
                                  },
                                ),
                              );
                              print(response.data.toString());

                              dissmissLoader(context);
                              if (response != null) {
                                UserRegisterModal userRegistration =
                                    UserRegisterModal.fromJson(response.data);
                                if (userRegistration.status) {
                                  _user.name =
                                      nameEdit.value.text.toLowerCase();
                                  _user.username =
                                      usernameEdit.value.text.toLowerCase();
                                  _user.email =
                                      emailEdit.value.text.toLowerCase();
                                  _user.mobile =
                                      mobileEdit.value.text.toLowerCase();
                                  _user.gender = isMale ? "Male" : "Female";
                                  _user.dob = formatter.format(_selectedDate);
                                  setUserWithoutToken(_user.toJson());
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DashBoard()),
                                      (Route<dynamic> route) => false);
                                } else {
                                  showError(
                                      context,
                                      userRegistration.msg != null
                                          ? userRegistration.msg
                                          : "error in updating");
                                }
                              }
                            }
                          } else {
                            showError(context, "please select valid date");
                          }
                        }),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
