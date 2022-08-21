import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

import '../../screens/DashBoard.dart';

class RateUs extends StatefulWidget {
  const RateUs({Key key}) : super(key: key);

  @override
  State<RateUs> createState() => _RateUsState();
}

class _RateUsState extends State<RateUs> {
  final maxLines = 5;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.2,
            ),
            Lottie.network(
                'https://assets1.lottiefiles.com/packages/lf20_c7Gl35.json'),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Rate US Now",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Please rate us on Google Play Store",
                style: TextStyle(fontSize: 15),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            RatingBar.builder(
              initialRating: 3,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                print(rating);
              },
            ),
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.0, 20, 0, 5),
                child: Text("Review optional"),
              ),
            ),
            Container(
              margin: EdgeInsets.all(12),
              height: maxLines * 24.0,
              child: TextField(
                maxLines: maxLines,
                decoration: InputDecoration(
                  hintText: "Enter a message",
                  fillColor: Colors.grey[300],
                  filled: true,
                ),
              ),
            ),
            Container(
              width: 350,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>DashBoard()));
                },
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all<Color>(
                      Theme.of(context)
                          .colorScheme
                          .secondary),
                  shape: MaterialStateProperty.all<
                      RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12.0),
                      )),
                  padding: MaterialStateProperty.all<
                      EdgeInsetsGeometry>(
                    const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 50),
                  ),
                ),
                child: Text("Continue",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
