import 'dart:ffi';
import 'package:ffi/ffi.dart';

final DynamicLibrary usbDeviceInfoLib =
    DynamicLibrary.open('native/Biometrics.dll'); // Update the path

typedef GetUsbDeviceInfoC = Int32 Function(Pointer<Utf16>);
typedef GetUsbDeviceInfoDart = int Function(Pointer<Utf16>);

class UsbDeviceInfo {
  static UsbDeviceInformation? getUsbDeviceInfo() {
    final buffer = calloc<Utf16>(256);

    final result = getUsbDeviceInfoLib(buffer);

    if (result == 0) {
      final charCodes = buffer.cast<Uint16>();
      final charList = charCodes.asTypedList(256);

      final length = charList.indexOf(0);

      final friendlyName = String.fromCharCodes(charList, 0, length);

      // Parse the friendlyName and extract other details
      String manufacturer = ''; // Extract this from friendlyName
      String hardwareId = ''; // Extract this from friendlyName
      int pid = 0; // Extract this from friendlyName

      final usbInfo = UsbDeviceInformation(
        friendlyName: friendlyName,
        manufacturer: manufacturer,
        hardwareId: hardwareId,
        pid: pid,
      );

      calloc.free(buffer);
      return usbInfo;
    } else {
      print('Error retrieving USB Device Information.');
      return null;
    }
  }

  static getUsbDeviceInfoLib(Pointer<Utf16> buffer) {}
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
