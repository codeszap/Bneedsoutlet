import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:bneedsoutlet/screens/print_page.dart';
import 'package:bneedsoutlet/screens/salesEntry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../style/Colors.dart';
import 'Drawer.dart';


class ShowPrinter extends StatefulWidget {
  const ShowPrinter({Key? key}) : super(key: key);

  @override
  _ShowPrinterState createState() => _ShowPrinterState();
}

class _ShowPrinterState extends State<ShowPrinter> {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  List<BluetoothDevice> _devices = [];
  BluetoothDevice? _selectedDevice;
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      // todo
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            // print("Bluetooth device state: connected");
            Fluttertoast.showToast(msg: 'Bluetooth device state: connected');
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            // print("Bluetooth device state: disconnect requested");
            Fluttertoast.showToast(msg: 'Bluetooth device state: disconnect requested');
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            // print("Bluetooth device state: Bluetooth turning off");
            Fluttertoast.showToast(msg: 'Bluetooth device state: Bluetooth turning off');
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            // print("Bluetooth device state: Bluetooth off");
            Fluttertoast.showToast(msg: 'Bluetooth device state: Bluetooth off');
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            // print("Bluetooth device state: Bluetooth on");
            Fluttertoast.showToast(msg: 'Bluetooth device state: Bluetooth on');
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            // print("Bluetooth device state: error");
            Fluttertoast.showToast(msg: 'Bluetooth device state: error');
          });
          break;
        default:
        // print(state);
          break;
      }
    });

    if (!mounted) return;

    setState(() {
      _devices = devices;
    });

    if (isConnected!) {
      setState(() {
        _connected = true;
      });
      _print();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.BodyColor,
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: const Text(
          'Show Available Printer',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.CommonColor,
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the desired icon color
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Confirm Exit',style: TextStyle(fontSize: 18),),
                    content: const SingleChildScrollView(child: Center(child: Text('Are you sure you want to exit?',style: TextStyle(fontSize:16),))),
                    actions: [
                      TextButton(
                        child: const Text('Yes',style: TextStyle(fontSize: 20,color: Colors.teal),),
                        onPressed: () async {
                          // SharedPreferences Userprefs = await SharedPreferences.getInstance();
                          // await Userprefs.clear();
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const LoginPage(),
                          //   ),
                          // );
                        },
                      ),
                      TextButton(
                        child: const Text('No',style: TextStyle(fontSize: 18,color: Colors.red),),
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: initPlatformState,
        child: ListView.builder(
          itemCount: _devices.length,
          itemBuilder: (context, index) {
            final device = _devices[index];
            return ListTile(
              title: Text(
                device.name!,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18,),
              ),
              onTap: () => _connectToDevice(device),
              trailing: _connected && _selectedDevice == device
                  ? const Icon(
                Icons.bluetooth_connected,
                color: Colors.green, // Display green icon when connected
              )
                  : const Icon(
                Icons.bluetooth,
                color: Colors.red, // Display red icon when not connected
              ),
            );
          },
        ),
      ),
    );
  }

  void _connectToDevice(BluetoothDevice device) {
    if (_connected && _selectedDevice == device) {
      _print();
      // Fluttertoast.showToast(msg: "print");
    } else {
      setState(() {
        _selectedDevice = device;
      });
      _connect();
      // Fluttertoast.showToast(msg: "Else part");
    }
  }

  void _connect() {
    if (_selectedDevice == null) {
      show('No device selected');
      //  Fluttertoast.showToast(msg: "No device selected");
    } else {
      bluetooth.isConnected.then((isConnected) {
        if (!isConnected!) {
          bluetooth.connect(_selectedDevice!).then((value) async {
            setState(() {
              _connected = true;
            });
            Fluttertoast.showToast(msg: "Connected to ${_selectedDevice?.name ?? 'Unknown Device'}");

            SharedPreferences PrintModePrefs = await SharedPreferences.getInstance();
            String? PrintMode = PrintModePrefs.getString("printMode");

            if(PrintMode =='2'){
              PrintPage().twoinch();
            }else
            {
              PrintPage().threeinch();
            }
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SalesEntry(),
              ),

            );
          }).catchError((error) {
            setState(() {
              _connected = false;
              print('Error connecting');
            });
          });
        }
      });
    }
  }



  void _disconnect() {
    bluetooth.disconnect();
    setState(() {
      _connected = false;
      _selectedDevice = null;
    });
  }


  void _print() async {
    if (_connected == true) {
      try {
        SharedPreferences PrintModePrefs = await SharedPreferences.getInstance();
        String? PrintMode = PrintModePrefs.getString("printMode");
        if(PrintMode =='2'){
          PrintPage().twoinch();
        }else
        {
          PrintPage().threeinch();
        }
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SalesEntry(),
          ),

        );

        // Fluttertoast.showToast(msg: "already connected");
      } catch (e) {
        // Handle any errors that occur during navigation
        print("Error navigating to SalesEntry: $e");
        Fluttertoast.showToast(msg: '$_selectedDevice');
      }
    } else {
      /*show('Printer not connected');*/
      Fluttertoast.showToast(msg: '$_selectedDevice');
      Fluttertoast.showToast(msg: '$_connected');
    }
  }


  Future show(String message, {Duration duration = const Duration(seconds: 3)}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        duration: duration,
      ),
    );
  }
}
