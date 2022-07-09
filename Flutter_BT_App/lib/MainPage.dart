import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:armadatest2/widgets/SMContainer.dart';
import './DiscoveryPage.dart';
import './SelectBondedDevicePage.dart';
import './ChatPage.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  String _address = "...";
  String _name = "...";

  Timer _discoverableTimeoutTimer;
  int _discoverableTimeoutSecondsLeft = 0;

//  BackgroundCollectingTask _collectingTask;

  bool _autoAcceptPairingRequests = false;

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if (await FlutterBluetoothSerial.instance.isEnabled) {
        return false;
      }
      await Future.delayed(Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {
      // Update the address field
      FlutterBluetoothSerial.instance.address.then((address) {
        setState(() {
          _address = address;
        });
      });
    });

    FlutterBluetoothSerial.instance.name.then((name) {
      setState(() {
        _name = name;
      });
    });

    // Listen for futher state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;

        // Discoverable mode is disabled when Bluetooth gets disabled
        _discoverableTimeoutTimer = null;
        _discoverableTimeoutSecondsLeft = 0;
      });
    });
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
//    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1D1D),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Container(
            width: 300,
            height: 300,
            child: Column(
              children: [
                Image.asset("images/armada_logo.png"),
                Text(
                  "Future of air transportation today",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 23.0, color: Color(0xFFB3B3B3), fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          /*Divider(color: Colors.white),

                  Center(child: Text("General", style: TextStyle( fontSize: 21.0, color: Colors.white, fontFamily: "Actor", fontWeight: FontWeight.bold),)),
                  Divider(color: Colors.white,),

                  SwitchListTile(
                        title: const Text('Enable Bluetooth', style: TextStyle(color: Colors.white, fontSize: 18.5),),
                        value: _bluetoothState.isEnabled,
                        activeColor: Colors.blue,
                        onChanged: (bool value) {
                          // Do the request and update with the true value then
                          future() async {
                            // async lambda seems to not working
                            if (value)
                              await FlutterBluetoothSerial.instance.requestEnable();
                            else
                              await FlutterBluetoothSerial.instance.requestDisable();
                          }

                          future().then((_) {
                            setState(() {});
                          });
                        },
                  ),
                  ListTile(
                      title: const Text('Phone settings', style: TextStyle(fontSize: 18.5, color: Colors.white),),
                      subtitle: Text(_bluetoothState.toString(), style: TextStyle(color: Colors.white70),),
                      trailing: RaisedButton(
                        splashColor: Colors.lightGreenAccent,
                        child: Icon(Icons.settings, color: Colors.blueGrey[800],),
                        onPressed: () {
                          FlutterBluetoothSerial.instance.openSettings();
                        },
                      ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:28.0),
                  child: Divider(color: Colors.white70),
                ),
                Center(child: Text('Discover device and connect', style: TextStyle(color: Colors.white, fontSize: 23.0, fontFamily: "Actor", fontWeight: FontWeight.bold),)),
                Divider(color: Colors.white70),
                /*SwitchListTile(
                  title: const Text('Auto-try specific pin when pairing'),
                  subtitle: const Text('Pin 1234'),
                  value: _autoAcceptPairingRequests,
                  onChanged: (bool value) {
                    setState(() {
                      _autoAcceptPairingRequests = value;
                    });
                    if (value) {
                      FlutterBluetoothSerial.instance.setPairingRequestHandler((BluetoothPairingRequest request) {
                        print("Trying to auto-pair with Pin 1234");
                        if (request.pairingVariant == PairingVariant.Pin) {
                          return Future.value("1234");
                        }
                        return null;
                      });
                    }
                    else {
                      FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
                    }
                  },
                ),*/
                Padding(
                  padding: const EdgeInsets.only(top:8.0),
                  child: ListTile(
                    title: Text("Discover new devices", style: TextStyle(fontSize: 19.6, color: Colors.white),),
                    trailing: RaisedButton(
                      splashColor: Colors.lightGreenAccent,
                        child: Icon(Icons.bluetooth, color: Colors.blueGrey[800],),
                        onPressed: () async {
                          final BluetoothDevice selectedDevice =
                              await Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                            return DiscoveryPage();
                          }));

                          if (selectedDevice != null) {
                            print('Discovery -> selected ' + selectedDevice.address);
                          } else {
                            print('Discovery -> no device selected');
                          }
                        }),
                  ),
                ),*/
          Padding(
            padding: const EdgeInsets.only(top: 35.0),
            child: ListTile(
              title: Padding(
                padding: const EdgeInsets.only(left: 32.0, right: 32.0),
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15.0))),
                  elevation: 7.0,
                  color: Color(0xFF2D2D2D),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: const Text(
                      'CONNECT',
                      style: TextStyle(
                          color: Color(0xFFB3B3B3),
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  onPressed: () async {
                    final BluetoothDevice selectedDevice =
                        await Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                      return SelectBondedDevicePage(checkAvailability: false);
                    }));

                    if (selectedDevice != null) {
                      print('Connect -> selected ' + selectedDevice.address);
                      _startChat(context, selectedDevice);
                    } else {
                      print('Connect -> no device selected');
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ChatPage(server: server);
    }));
  }

  Future<void> _startBackgroundTask(
      BuildContext context, BluetoothDevice server) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error occured while connecting'),
          content: Text(""),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
