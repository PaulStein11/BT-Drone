import 'package:flutter/material.dart';

class SMContainer extends StatelessWidget {
  final Widget child;
  SMContainer({Key key, this.child}) : super(key:key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.white70,
        boxShadow: [
          BoxShadow(
            blurRadius: 2.0,
            offset: Offset(-1, -1),
            color: Colors.white70
          ),
          BoxShadow(
            blurRadius: 2.0,
            offset: Offset(1,1),
            color: Colors.white70
          )
        ],
      ),
      child: child,
    );
  }
}
