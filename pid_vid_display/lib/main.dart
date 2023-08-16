import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'usb_device_info.dart'; // Uncomment this line to import the FFI bindings

void main() {
  runApp(MyApp());
}

final DynamicLibrary usbDeviceInfoLib = DynamicLibrary.open(
  'S:\\WINDOWS_FFI\\Biometric_ffi\\pid_vid_display\\native\\Biometrics.dll', // Update the path
);

typedef GetUsbDeviceInfoC = Int32 Function(Pointer<Utf16>);
typedef GetUsbDeviceInfoDart = int Function(Pointer<Utf16>);

class UsbDeviceInfo {
  static GetUsbDeviceInfoDart get getUsbDeviceInfo =>
      usbDeviceInfoLib.lookupFunction<GetUsbDeviceInfoC, GetUsbDeviceInfoDart>(
          'getUsbDeviceInfo');
}

class UsbDeviceInformation {
  final String friendlyName;
  final String manufacturer;
  final String hardwareId;
  final int pid;

  UsbDeviceInformation({
    required this.friendlyName,
    required this.manufacturer,
    required this.hardwareId,
    required this.pid,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USB Device Info',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late UsbDeviceInformation usbInfo;

  @override
  void initState() {
    super.initState();
    _getUsbDeviceInfo();
  }

  Future<void> _getUsbDeviceInfo() async {
    final buffer = calloc<Utf16>(256);

    final result = UsbDeviceInfo.getUsbDeviceInfo(buffer);

    if (result == 0) {
      final charCodes = buffer.cast<Uint16>();
      final charList = charCodes.asTypedList(256);

      final length = charList.indexOf(0);

      final friendlyName = String.fromCharCodes(charList, 0, length);

      // Parse the friendlyName and extract other details
      String manufacturer = ''; // Extract this from friendlyName
      String hardwareId = ''; // Extract this from friendlyName
      int pid = 0; // Extract this from friendlyName

      setState(() {
        usbInfo = UsbDeviceInformation(
          friendlyName: friendlyName,
          manufacturer: manufacturer,
          hardwareId: hardwareId,
          pid: pid,
        );
      });
    } else {
      print('Error retrieving USB Device Information.');
    }

    calloc.free(buffer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('USB Device Info'),
      ),
      body: Center(
        // ignore: unnecessary_null_comparison
        child: usbInfo != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Friendly Name: ${usbInfo.friendlyName}'),
                  Text('Manufacturer: ${usbInfo.manufacturer}'),
                  Text('Hardware ID: ${usbInfo.hardwareId}'),
                  Text('PID: ${usbInfo.pid}'),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}
