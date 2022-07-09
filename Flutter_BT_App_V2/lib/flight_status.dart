import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Flight_Status extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        title: Text("Flight status"),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 2, 15, 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Divider(color: Colors.grey.shade800),
              Text(
                "Battery",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.0,
                    color: Colors.grey.shade700),
              ),
              Divider(color: Colors.grey.shade800),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.battery_full,
                            color: Colors.green,
                            size: 50.0,
                          ),
                          Text(
                            "100 %",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 50,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            "220 V",
                            style: TextStyle(fontSize: 32.0),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            "50Mhz",
                            style: TextStyle(fontSize: 32.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 18.0, bottom: 18.0),
                    child: Row(
                      children: [
                        Text(
                          "Time remaining:",
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800),
                        ),
                        Text(
                          " 1 hour",
                          style: TextStyle(
                              fontSize: 18.3,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey.shade800),
              Text(
                "Data flight",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.0,
                    color: Colors.grey.shade700),
              ),
              Divider(color: Colors.grey.shade800),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top:18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("Altitude (Rel)(m)", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: Colors.grey.shade800),),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("0.0", style: TextStyle(fontSize: 16.0)),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("GPS connected", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("15", style: TextStyle(fontSize: 16.0)),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top:18.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("Ground Speed (m/s)", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("0.0", style: TextStyle(fontSize: 16.0)),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("Flight time", style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: Colors.grey.shade800)),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("00:00:00", style: TextStyle(fontSize: 16.0)),
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Divider(color: Colors.grey.shade800),
              Text(
                "Telemetry",
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18.0,
                    color: Colors.grey.shade700),
              ),
              Divider(color: Colors.grey.shade800),
            ],
          ),
        ),
      ),
    );
  }
}
