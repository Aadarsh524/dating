// platform_mobile.dart
import 'dart:io' show Platform;

String getApiEndpoint() {
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8001/api';
  } else if (Platform.isIOS) {
    return 'http://10.0.2.2:8001/api';
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    return 'http://localhost:8001/api';
  } else {
    return 'http://localhost:8001/api';
  }
}
