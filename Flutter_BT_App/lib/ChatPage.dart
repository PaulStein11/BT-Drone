import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'ArmadaBarin.dart';

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
  bool isTakeOff = false;
  bool isStartMission = false;
  bool isReturnHome = false;
  bool isEmergencyLand = false;
  bool isConnecting = true;
  bool button12 = false;
  bool button11 = false;

  bool get isConnected => connection != null && connection.isConnected;

  bool isDisconnecting = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void _showScaffold(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      duration: Duration(milliseconds: 1200),
      backgroundColor: Colors.green,
      content: Column(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(message),
              ),
            ],
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      /*appBar: AppBar(
        title: (isConnecting
            ? Text('Connecting to ' + widget.server.name + '...')
            : isConnected
                ? Text('Connected with ' + widget.server.name)
                : Text('Disconnected from ' + widget.server.name)),
      ),*/
      body: new Container(
          decoration: BoxDecoration(
            gradient: new LinearGradient(
                colors: [const Color(0xFF43413d), const Color(0xFF0d0c0c)],
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp),
          ),
          child: Center(
              child: isConnecting
                  ? Text(
                      'Wait until connected...',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Antonio",
                        color: Colors.white,
                      ),
                    )
                  : isConnected
                      ? Column(
                          children: <Widget>[
                            SafeArea(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Container(
                                    height: 60.0,
                                    width: 60.0,
                                    child:
                                        Image.asset("images/armada_logo.png"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 36.0),

                                      child: Text(
                                        "FLIGHT MODE",
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontFamily: "Actor",
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  Icon(
                                    CupertinoIcons.battery_full,
                                    color: Colors.lightGreenAccent,
                                    size: 30.0,
                                  )
                                ],
                              ),
                            ),
                            Row(),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 5.0, bottom: 5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Card(
                                    color: Color(0xFF1d1b1b),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Icon(
                                              Icons.cloud_queue,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            '$humi\%',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Actor",
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    color: Color(0xFF1d1b1b),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Row(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: Icon(
                                              CupertinoIcons.brightness,
                                              color: Colors.orange,
                                            ),
                                          ),
                                          Text(
                                            '$temp\u00b0C',
                                            style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Actor",
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox.fromSize(
                              size: Size(45, 45), // button width and height
                              child: ClipOval(
                                child: Material(
                                  color: Colors.white, // button color
                                  child: InkWell(
                                    splashColor: Colors.blue, // splash color
                                    onTap: () {}, // button pressed
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Icon(
                                          Icons.power_settings_new,
                                          color: Color(0xFF1d1b1b),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  height: 130.0,
                                  width: 300.0,
                                  child:
                                      Image.asset("images/Armada_model_1.png"),
                                )
                              ],
                            ),
                            Divider(
                              color: Colors.white,
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    height: 25.0,
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
                                                    fontSize: 16.0,
                                                    color: Colors.white),
                                              ))
                                            : Text('Disconnected from ' +
                                                widget.server.name)),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 350.0,
                              child: Divider(
                                color: Colors.white70,
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
                                        isTakeOff == false
                                            ? armada_brain.getInitial(0)
                                            : armada_brain.getActive(0),
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
                                              _sendMessage('13 on');
                                              _showScaffold("Taking off");
                                            } else {
                                              //Take Off is OFF
                                              _sendMessage('13 off');
                                              _showScaffold("Landing");
                                            }
                                          });
                                        },
                                        activeColor: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 330.0,
                              child: Divider(
                                color: Colors.white70,
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
                                        "START MISSION",
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
                                        value: isStartMission,
                                        onChanged: (value) {
                                          setState(() {
                                            isStartMission = value;
                                            if (value == true) {
                                              //Take Off is ON
                                              _sendMessage('12 on');
                                            } else {
                                              //Take Off is OFF
                                              _sendMessage('12 off');
                                            }
                                          });
                                        },
                                        activeColor: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 330.0,
                              child: Divider(
                                color: Colors.white70,
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
                                        "RETURN HOME",
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
                                        value: isReturnHome,
                                        onChanged: (value) {
                                          setState(() {
                                            isReturnHome = value;
                                            if (value == true) {
                                              //Take Off is ON
                                              _sendMessage('11 on');
                                            } else {
                                              //Take Off is OFF
                                              _sendMessage('11 off');
                                            }
                                          });
                                        },
                                        activeColor: Colors.green,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 330.0,
                              child: Divider(
                                color: Colors.blue,
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
                                        "EMERGENCY LAND",
                                        style: TextStyle(
                                            fontSize: 18.0,
                                            fontFamily: "Actor",
                                            color: Colors.blue,
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
                                            } else {
                                              //Take Off is OFF
                                              _sendMessage('10 off');
                                            }
                                          });
                                        },
                                        activeColor: Colors.blue,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Text(
                          'Got disconnected',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Roboto"),
                        ))),
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
          isTakeOff = true;
        }
        if (received_data == "13 off") {
          isTakeOff = false;
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
