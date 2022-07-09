import 'dart:convert';
import 'dart:typed_data';
import 'package:armadatest2/Driving_mode_main_screen.dart';
import 'package:armadatest2/flight_status.dart';
import 'package:armadatest2/my_flutter_app_icons.dart';
import 'package:armadatest2/widgets/alertDialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'ArmadaBrain.dart';

const Color interactive_color = Colors.blue;

class ChatPage extends StatefulWidget {
  final BluetoothDevice server;

  const ChatPage({this.server});

  @override
  _ChatPage createState() => new _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  ArmadaBrain armada_brain = ArmadaBrain();

  int _index = 0;
  String temp = "";
  String humi = "";
  String pinNum = "";
  static final clientID = 0;
  static final maxMessageLength = 4096 - 3;
  BluetoothConnection connection;

  String _messageBuffer = '';
  bool isArm = false;
  bool isTakeOff = false;
  bool isStartMIssion = false;
  bool isEmergencyLand = false;
  bool isConnecting = true;
  bool button12 = false;
  bool button11 = false;

  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(milliseconds: 1500),
      backgroundColor: Colors.blue.shade400,
      content: Text(
        message,
        style: TextStyle(fontSize: 18.0, fontFamily: "Ubuntu"),
      ),
    ));
  }

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection.input.listen(_onDataReceived).onDone(() {
        // Example: Detect which side closed the connection
        // There should be `isDisconnecting` flag to show are we are (locally)
        // in middle of disconnecting process, should be set before calling
        // `dispose`, `finish` or `close`, which all causes to disconnect.
        // If we except the disconnection, `onDone` should be fired as result.
        // If we didn't except this (no flag set), it means closing by remote.
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = null;
    }

    super.dispose();
  }

  Future<void> _showMyDialog(String command, String showScaffold) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Alert!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Based on safety conditions..'),
                Text('Would you like to approve this command?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                return;
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).backgroundColor,
      child: Center(
        child: isConnecting
            ? Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                        backgroundColor: Colors.grey.shade100),
                    SizedBox(
                      height: 16.0,
                    ),
                    Text(
                      'Wait until connected...',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Ubuntu",
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              )
            : isConnected
                ? Scaffold(
                    appBar: PreferredSize(
                      preferredSize: Size.fromHeight(48),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: AppBar(
                          leading: Image.asset("images/armada_logo.png"),
                          elevation: 0.0,
                          centerTitle: true,
                          title: Text("Flight Mode"),
                          actions: [
                            IconButton(
                              icon: Icon(
                                MyFlutterApp.steering_wheel,
                                size: 28,
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Driving_Mode_Screen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    body: Container(
                      color: Theme.of(context).backgroundColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              child: Divider(
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 15.0,
                                    width: 350.0,
                                    child: (isConnecting
                                        ? Center(
                                        child: Text('Connecting to ' +
                                            widget.server.name +
                                            '...'))
                                        : isConnected
                                        ? Center(
                                        child: Text(
                                          'Connected with ' +
                                              widget.server.name,
                                          style: TextStyle(
                                              fontFamily: "Ubuntu",
                                              fontSize: 14.0,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade800),
                                        ))
                                        : Text('Disconnected from ' +
                                        widget.server.name)),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 48.0),
                              child: SizedBox(
                                child: Divider(
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 58.0, top: 20.0),
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Flight_Status(),
                                  ),
                                ),
                                child: Stack(
                                  children: <Widget>[
                                    Container(
                                      height: 130.0,
                                      width: 300.0,
                                      child: Image.asset(
                                          "images/Armada_model_1.png"),
                                    ),
                                    CircularPercentIndicator(
                                      radius: 60.0,
                                      lineWidth: 7.0,
                                      animation: true,
                                      percent: 1.0,
                                      center: new Text(
                                        "100%",
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.0,
                                            color: Colors.green),
                                      ),
                                      footer: new Text(
                                        "Battery",
                                        style: new TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11.0,
                                            color: Colors.green,
                                            fontFamily: "Actor"),
                                      ),
                                      circularStrokeCap: CircularStrokeCap.round,
                                      progressColor: Colors.green,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 38.0),
                              child: SizedBox(
                                child: Divider(
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        isArm == false
                                            ? armada_brain.getInitial(0)
                                            : armada_brain.getActive(0),
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: "Actor",
                                            color: Colors.black,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 40.0),
                                  child: Column(
                                    children: <Widget>[
                                      CupertinoSwitch(
                                        trackColor: Colors.grey,
                                        value: isArm,
                                        onChanged: (value) {
                                          setState(() {
                                            isArm = value;
                                            if (value == true) {
                                              //Arming is ON
                                              _sendMessage("13 on");
                                              _showScaffold("Arming");
                                            } else {
                                              //Arming is OFF
                                              _sendMessage('13 off');
                                              _showScaffold("Disarming");
                                            }
                                          });
                                        },
                                        activeColor: interactive_color,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            /*SizedBox(
                                      width: 330.0,
                                      child: Divider(
                                        color: Colors.white70,
                                      ),
                                    ),*/
                            /*Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(left: 40.0),
                                          child: Column(
                                            children: <Widget>[
                                              Text(
                                                isTakeOff == false
                                                    ? armada_brain.getInitial(1)
                                                    : armada_brain.getActive(1),
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontFamily: "Actor",
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 40.0),
                                          child: Column(
                                            children: <Widget>[
                                              CupertinoSwitch(
                                                value: isTakeOff,
                                                onChanged: (value) {
                                                  setState(() {
                                                    isTakeOff = value;
                                                    if (value == true) {
                                                      //Take Off is ON
                                                      _sendMessage('12 on');
                                                      _showScaffold("Taking off activated"); //Taking off

                                                    } else {
                                                      //Take Off is OFF
                                                      _sendMessage('12 off');
                                                      _showScaffold("Landing activated"); //Landing

                                                    }
                                                  });
                                                },
                                                activeColor: interactive_color,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),*/
                            SizedBox(
                              child: Divider(
                                color: Colors.grey.shade800,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(left: 40.0),
                                  child: Column(
                                    children: <Widget>[
                                      Text(
                                        isStartMIssion == false
                                            ? armada_brain.getInitial(2)
                                            : armada_brain.getActive(2),
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: "Actor",
                                            color: Colors.black,
                                            fontWeight: FontWeight.w300),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 40.0),
                                  child: Column(
                                    children: <Widget>[
                                      CupertinoSwitch(
                                        trackColor: Colors.grey,
                                        value: isStartMIssion,
                                        onChanged: (value) {
                                          setState(() {
                                            isStartMIssion = value;
                                            if (value == true) {
                                              //Mission mode is ON
                                              _sendMessage('11 on');
                                              _showScaffold("Mission initiated");
                                            } else {
                                              //RTL is ON
                                              _sendMessage('11 off');
                                              _showScaffold(
                                                  "Return home initiated");
                                            }
                                          });
                                        },
                                        activeColor: interactive_color,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              child: Divider(
                                color: Colors.grey.shade800,
                              ),
                            ),
                            /*Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(left: 40.0),
                                          child: Column(
                                            children: <Widget>[
                                              Text(
                                                isEmergencyLand == false
                                                    ? armada_brain.getInitial(3)
                                                    : armada_brain.getActive(3),
                                                style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontFamily: "Actor",
                                                    color: interactive_color,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(right: 40.0),
                                          child: Column(
                                            children: <Widget>[
                                              CupertinoSwitch(
                                                value: isEmergencyLand,
                                                onChanged: (value) {
                                                  setState(() {
                                                    isEmergencyLand = value;
                                                    if (value == true) {
                                                      //Take Off is ON
                                                      _sendMessage('10 on');
                                                      _showScaffold("Landing executed");
                                                    } else {
                                                      //Take Off is OFF
                                                      _sendMessage('10 off');
                                                      _showScaffold("Landing stopped");
                                                    }
                                                  });
                                                },
                                                activeColor: interactive_color,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),*/

                            Padding(
                              padding: const EdgeInsets.only(top: 28.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size:
                                            Size(50, 50), // button width and height
                                        child: ClipOval(
                                          child: Material(
                                            color: Colors.blueGrey.withBlue(200),
                                            // button color
                                            child: InkWell(
                                              splashColor:
                                                  Colors.white70, // splash color
                                              onTap: () {
                                                _sendMessage('11 on');
                                                _showScaffold("Landing executed");
                                              }, // button pressed
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.flight_takeoff,
                                                    color: Colors.white,
                                                    size: 26,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 25.0, top: 10.0),
                                        child: Text(
                                          "TAKE OFF",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black,
                                              fontFamily: "Ubuntu",
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox.fromSize(
                                        size:
                                            Size(50, 50), // button width and height
                                        child: ClipOval(
                                          child: Material(
                                            color: Colors.blueGrey.withBlue(200),
                                            // button color
                                            child: InkWell(
                                              splashColor:
                                                  Colors.white70, // splash color
                                              onTap: () {
                                                _sendMessage('11 on');
                                                _showScaffold("Landing executed");
                                              }, // button pressed
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.flight_land,
                                                    color: Colors.white,
                                                    size: 26,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            bottom: 25.0, top: 10.0),
                                        child: Text(
                                          "LAND",
                                          style: TextStyle(
                                              fontSize: 18.0,
                                              color: Colors.black,
                                              fontFamily: "Ubuntu",
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  )
                : Text(
                    'Got disconnected',
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Roboto",
                        color: Colors.red),
                  ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);

    if (~index != 0) {
      // \r\n
      setState(() {
        String received_data = _messageBuffer + dataString.substring(0, index);
        received_data = received_data.trim();
//        print(received_data);
//        print(received_data.substring(0, 4));
//        print(received_data.length);
        if (received_data.substring(0, 5) == 'temp:') {
          temp = received_data.substring(5, received_data.length);
        }

        if (received_data.substring(0, 5) == 'humi:') {
          humi = received_data.substring(5, received_data.length);
        }

        if (received_data == "13 on") {
          isArm = true;
        }
        if (received_data == "13 off") {
          isArm = false;
        }
        if (received_data == "12 on") {
          button12 = true;
        }
        if (received_data == "12 off") {
          button12 = false;
        }
        if (received_data == "11 on") {
          button11 = true;
        }
        if (received_data == "11 off") {
          button11 = false;
        }
        _messageBuffer = dataString.substring(index);
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  void _sendMessage(String text) async {
    text = text.trim();

    if (text.length > 0) {
      print(utf8.encode(text + "\r\n"));
      try {
        connection.output.add(utf8.encode(text + "\r\n"));
        await connection.output.allSent;

        setState(() {
//          messages.add(_Message(clientID, text));
        });
      } catch (e) {
        // Ignore error, but notify state
        setState(() {});
      }
    }
  }
}
