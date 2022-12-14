import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../user/model/User.dart';
import '../user/screens/UserAccount.dart';
import '../user/screens/UserRideHistory.dart';
import '../user/screens/support/support_screen.dart';
import '../user/screens/userTerms.dart';
import '../utils/util.dart';
import 'SplashScreen.dart';
import 'drawerList_widget.dart';

class Custom_Drawer extends StatelessWidget {
  const Custom_Drawer({
    Key key,
    @required User user,
  })  : _user = user,
        super(key: key);

  final User _user;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 50),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.only(right: 20),
                      child: Neumorphic(
                        child: IconButton(
                            icon: const Icon(Icons.arrow_back_ios),
                            onPressed: () {
                              Navigator.pop(context);
                            }),
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      children: [
                        Image.network(
                          _user != null
                              ? _user.userimage
                              : "https://static.vecteezy.com/system/resources/previews/002/318/271/original/user-profile-icon-free-vector.jpg",
                          width: 100,
                          height: 100,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          _user != null ? _user.name : "",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: HexColor(textColor)),
                        ),
                        const SizedBox(
                          height: 3,
                        ),
                        SmoothStarRating(
                          starCount: 5,
                          isReadOnly: true,
                          color: Theme.of(context).accentColor,
                          rating: 4.5,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            DrawerListTile("Home", "assets/images/home_icon.svg", () {
              Navigator.pop(context);
            }),
            DrawerListTile("Rides", "assets/images/car_icon.svg", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserRideHistory()),
              );
            }),
            DrawerListTile("Account", "assets/images/account.svg", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserAccount()),
              );
            }),
            DrawerListTile("Support", "assets/images/support_icon.svg", () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SupportScreen()),
              );
            }),
            DrawerListTile("About", 'assets/images/about_icon.svg', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserTerms("About")),
              );
            }),
            DrawerListTile("Terms & Condition", 'assets/images/terms_icon.svg',
                () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const UserTerms("Terms & Conditions")),
              );
            }),
            DrawerListTile(
                "Privacy Policy", 'assets/images/privacy_policy_icon.svg', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const UserTerms("Privacy & Policy")),
              );
            }),
            DrawerListTile("Logout", 'assets/images/sign_out_icon.svg',
                () async {
              await logoutUser();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => SplashScreen()),
                  (Route<dynamic> route) => false);
            }),
          ],
        ),
      ),
    );
  }
}
