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
      body: new Container(
        padding: EdgeInsets.all(15.0),

        child: Padding(
          padding: const EdgeInsets.only(left: 17.0, right: 17.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SafeArea(
                      child: Container(
                        width: 250,
                        height: 250,
                        child: Image.asset("images/armada_logo.png"),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Text(
                      "Future of air transportation today",
                      style: TextStyle(fontSize: 23.0, color: Colors.black, fontWeight: FontWeight.w300, fontFamily: "Actor"),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 35.0),
                child: ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(left: 28.0, right: 28.0),
                    child: RaisedButton(
                      elevation: 10.0,
                      color: Colors.grey.shade800,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: const Text(
                          'CONNECT',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Actor"),
                        ),
                      ),
                      onPressed: () async {
                        final BluetoothDevice selectedDevice =
                            await Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) {
                          return SelectBondedDevicePage(
                              checkAvailability: false);
                        }));

                        if (selectedDevice != null) {
                          print(
                              'Connect -> selected ' + selectedDevice.address);
                          _startChat(context, selectedDevice);
                        } else {
                          print('Connect -> no device selected');
                        }
                      },
                    ),
                  ),
                ),
              ),

              ListTile(
                title: Text(
                  "Discover devices",
                  style: TextStyle(fontSize: 16.0, color: Colors.black, fontFamily: "Actor"),
                ),
                trailing: RaisedButton(
                    color: Colors.grey.shade800,
                    splashColor: Colors.lightGreenAccent,
                    child: Icon(
                      Icons.bluetooth,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      final BluetoothDevice selectedDevice =
                          await Navigator.of(context)
                              .push(MaterialPageRoute(builder: (context) {
                        return DiscoveryPage();
                      }));

                      if (selectedDevice != null) {
                        print(
                            'Discovery -> selected ' + selectedDevice.address);
                      } else {
                        print('Discovery -> no device selected');
                      }
                    }),
              ),
            ],
          ),
        ),
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
        });
  }
}
