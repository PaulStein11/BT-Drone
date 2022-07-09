import 'package:armadatest2/ChatPage.dart';
import 'package:flutter/material.dart';

class Function_Mode_Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column (
      children: <Widget>[
        OutlineButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage())),
          child: Text ("FLIGHT MODE", style: TextStyle (
            fontSize: 18.0,
            fontFamily: "Actor",
            color: Colors.white70,
          ),),
        ),
        OutlineButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage())),
          child: Text ("DRIVE MODE", style: TextStyle (
            fontSize: 18.0,
            fontFamily: "Actor",
            color: Colors.white70,
          ),),
        ),
      ],
    );
  }
}
