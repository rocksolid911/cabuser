import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/util.dart';

class DrawerListTile extends StatelessWidget {
  final String _title;
  final String _icon;
  final Function _function;

  const DrawerListTile(this._title, this._icon, this._function, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _function.call(),
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Row(
          children: [
            Neumorphic(
                style: NeumorphicStyle(color: HexColor("#E3EDF7")),
                child: Container(
                    padding: const EdgeInsets.all(10),
                    child: SvgPicture.asset(_icon))),
            const SizedBox(
              width: 20,
            ),
            Text(_title,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: HexColor("#8B9EB0")))
          ],
        ),
      ),
    );
  }
}