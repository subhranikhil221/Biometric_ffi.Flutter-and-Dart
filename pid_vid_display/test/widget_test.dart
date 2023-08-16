// ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pid_vid_display/main.dart';
import 'package:pid_vid_display/usb_device_info.dart'
    as usb_info; // Use 'as' to create a prefix

void main() =>
    testWidgets('USB Device Info Display Test', (WidgetTester tester) async {
      // Initialize the usbInfo variable
      final usbInfo = usb_info.UsbDeviceInfo.getUsbDeviceInfo();

      // Build a testable widget that wraps MyApp
      await tester.pumpWidget(
        MaterialApp(
          home: MyApp(),
        ),
      );

      // Verify that the USB device information is displayed.
      expect(find.text('USB Device Info'), findsOneWidget); // App title

      // Use null-aware operators to handle late initialization
      expect(
          find.text('Friendly Name: ${usbInfo?.friendlyName}'), findsOneWidget);
      expect(
          find.text('Manufacturer: ${usbInfo?.manufacturer}'), findsOneWidget);
      expect(find.text('Hardware ID: ${usbInfo?.hardwareId}'), findsOneWidget);
      expect(find.text('PID: ${usbInfo?.pid}'), findsOneWidget);
    });
