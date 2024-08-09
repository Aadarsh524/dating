// platform_mobile.dart
import 'dart:io' show Platform;

String getApiEndpoint() {
  try {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8001/api';
    } else if (Platform.isIOS) {
      return 'http://localhost:8001/api'; // Changed from 10.0.2.2 to localhost for iOS
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'http://localhost:8001/api';
    } else {
      return 'http://testdeploy.runasp.net';
    }
  } catch (e) {
    // If Platform is not available, return a default value
    return 'http://testdeploy.runasp.net';
  }
}
