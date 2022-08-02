import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, left: 20),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Theme.of(context).accentColor,
        child: Builder(
          builder: (context) => IconButton(
            icon: CircleAvatar(
              radius: 22,
              backgroundColor: Theme.of(context).accentColor,
              child: const Icon(
                Icons.menu,
                color: Colors.white,
              ),
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
    );
  }
}