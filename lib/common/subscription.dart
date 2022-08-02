import 'package:aimcabuser/user/cargo/screen/cargomainscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
enum SingingCharacter { lafayette, jefferson }
class SubScription extends StatefulWidget {
  const SubScription({Key key}) : super(key: key);

  @override
  State<SubScription> createState() => _SubScriptionState();
}

class _SubScriptionState extends State<SubScription> {
  SingingCharacter _character = SingingCharacter.lafayette;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.network(
                "https://media.istockphoto.com/photos/male-hand-pressing-subscription-button-with-the-word-subscribe-on-picture-id1264256508?k=20&m=1264256508&s=612x612&w=0&h=09GTgSMR0V3FRmS3XP6KyAGmLc4RZ-y9h6WVLgncx6Y=",
              ),
              Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black12, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10,25,10,25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("ONE day"),
                                Text("200")
                              ],
                            ),
                            const SizedBox(height: 10,),
                            const Text(". dhgjhg hhiu ftyfuy hoilk guh"),
                            const SizedBox(height: 10,),
                            const Text(". dhgjhg hhiu ftyfuy hoilk guh")
                          ],
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black12, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10,25,10,25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("ONE day"),
                                Text("200")
                              ],
                            ),
                            const SizedBox(height: 10,),
                            const Text(". dhgjhg hhiu ftyfuy hoilk guh"),
                            const SizedBox(height: 10,),
                            const Text(". dhgjhg hhiu ftyfuy hoilk guh")
                          ],
                        ),
                      ),
                    ),
                    Card(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.black12, width: 1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(10,25,10,25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                Text("ONE day"),
                                Text("200")
                              ],
                            ),
                            const SizedBox(height: 10,),
                            const Text(". dhgjhg hhiu ftyfuy hoilk guh"),
                            const SizedBox(height: 10,),
                            const Text(". dhgjhg hhiu ftyfuy hoilk guh")
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text('Agree to term and condition'),
                      leading: Radio<SingingCharacter>(
                        value: SingingCharacter.lafayette,
                        groupValue: _character,
                        onChanged: (SingingCharacter value) {
                          setState(() {
                            _character = value;
                          });
                        },
                      ),
                    ),
                    Container(
                      width: 450,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>const CargoScreen()));
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
                                vertical: 10, horizontal: 50),
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
            ],
          ),
        ),
      ),
    );
  }
}
