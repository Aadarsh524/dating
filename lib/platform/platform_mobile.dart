// platform_mobile.dart
import 'dart:io' show Platform;

String getApiEndpoint() {
  try {
    if (Platform.isAndroid) {
      return 'http://testdeploy.runasp.net/api';
    } else if (Platform.isIOS) {
      return 'http://testdeploy.runasp.net/api';
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'http://testdeploy.runasp.net/api';
    } else {
      return 'http://testdeploy.runasp.net/api';
    }
  } catch (e) {
    // If Platform is not available, return a default value
    return 'http://testdeploy.runasp.net/api';
  }
}
