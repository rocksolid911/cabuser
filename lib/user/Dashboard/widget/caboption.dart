import 'package:flutter/material.dart';

class CabOption extends StatefulWidget {
  const CabOption({
    Key key,
  }) : super(key: key);

  @override
  State<CabOption> createState() => _CabOptionState();
}

class _CabOptionState extends State<CabOption> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 15,
              color: Colors.white60,
              child: Container(
                margin:const EdgeInsets.fromLTRB(20, 0, 50, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Image.network("https://imgd.aeplcdn.com/600x337/n/cw/ec/41197/hyundai-verna-right-front-three-quarter7.jpeg?q=75",
                          height: 70,
                          width: 70,
                        ),
                        const Text("Prime sedan"),
                      ],
                    ),
                    Column(children: const [
                      Text("Price"),
                      Text("30.50")
                    ],)
                  ],
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 15,
              color: Colors.white60,
              child: Container(
                margin:const EdgeInsets.fromLTRB(20, 0, 50, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Image.network("https://imgd.aeplcdn.com/600x337/n/cw/ec/41197/hyundai-verna-right-front-three-quarter7.jpeg?q=75",
                          height: 70,
                          width: 70,
                        ),
                        const Text("Coop"),
                      ],
                    ),
                    Column(children: const [
                      Text("Price"),
                      Text("30.50")
                    ],)
                  ],
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 15,
              color: Colors.white60,
              child: Container(
                margin:const EdgeInsets.fromLTRB(20, 0, 50, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Image.network("https://imgd.aeplcdn.com/600x337/n/cw/ec/41197/hyundai-verna-right-front-three-quarter7.jpeg?q=75",
                          height: 70,
                          width: 70,
                        ),
                        const Text("SUV"),
                      ],
                    ),
                    Column(children: const [
                      Text("Price"),
                      Text("30.50")
                    ],)
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}