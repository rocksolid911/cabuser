import 'package:aimcabuser/user/cargo/screen/rateus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../screens/DashBoard.dart';

class DeliveryComplete extends StatefulWidget {
  const DeliveryComplete({Key key}) : super(key: key);

  @override
  _DeliveryCompleteState createState() => _DeliveryCompleteState();
}

class _DeliveryCompleteState extends State<DeliveryComplete> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //1st container with right image
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F4F4),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network("https://icon-library.com/images/right-icon/right-icon-19.jpg",
                      width: MediaQuery.of(context).size.width * 0.2,
                      height: MediaQuery.of(context).size.width * 0.2),
                  const SizedBox(height: 15,),
                  const Text(
                    "Successfully delivered",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 15,),
                  const Text(
                    'We have successfully delivered your product',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            //row with two columns
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0,10,14,10),
              child: Row(
                children: [
                  //left column
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Receiver Name",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8E8E8E),
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          "Siddhant Saraf",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  //right column
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Mobile Number",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8E8E8E),
                          ),
                        ),
                        SizedBox(height: 5,),
                        Text(
                          "9888888888",
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //column with two text fields
            Padding(
              padding:const EdgeInsets.fromLTRB(14.0,10,14,10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  const [
                  Text(
                    "Address",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
                  SizedBox(height: 5,),
                  Text(
                    "Siddhant Saraf,Sector-1,Gurgaon,Haryana",
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            //column with one text field and one image
             Padding(
              padding: const EdgeInsets.fromLTRB(14.0,10,14,10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Product Name",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  //image with height and width
                  Image.network("https://thumbs.dreamstime.com/b/delivery-mail-man-giving-parcel-box-to-recipient-young-owner-accepting-cardboard-boxes-package-post-shipment-home-men-136453686.jpg",
                      width: MediaQuery.of(context).size.width ,
                      height: MediaQuery.of(context).size.width * 0.6),
                ],
              ),
            ),
            //text button
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0,15,14,0),
              child: Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RateUs(),
                      ),
                    );
                  },
                  child: const Text(
                    "Rate us",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0,5,14,10),
              child: Align(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>DashBoard()));
                  },
                  child: const Text(
                    "Back to Home",
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF8E8E8E),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
