import 'package:armadatest2/ChatPage.dart';
import 'package:flutter/material.dart';

import 'my_flutter_app_icons.dart';

class Driving_Mode_Screen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(48),
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: AppBar(
            leading: Image.asset("images/armada_logo.png"),
            elevation: 0.0,
            centerTitle: true,
            title: Text("Driving Mode"),
            actions: [
              IconButton(
                  icon: Icon(
                    MyFlutterApp.feather_wing,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
        ),
      ),
      body: Container(
        color: Theme.of(context).backgroundColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      MyFlutterApp.up_circle,
                      size: 35,
                    ))
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      MyFlutterApp.left_circle,
                      size: 35,
                    )),
                Container(
                  height: 130.0,
                  width: 220.0,
                  child: Image.asset("images/Armada_model_1.png"),
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      MyFlutterApp.right_circle,
                      size: 35,
                    )),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      MyFlutterApp.down_circle,
                      size: 35,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
