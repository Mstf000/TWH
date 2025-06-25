import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermission() async {
  // Check if permission is granted
  final permissionStatus = await Permission.notification.request();

  // If permission is granted, schedule notification
  if (permissionStatus.isGranted) {
    // Proceed with scheduling notification
  } else {
    // Handle permission denial (show a message to the user)
    print('Permission denied');
  }
}
