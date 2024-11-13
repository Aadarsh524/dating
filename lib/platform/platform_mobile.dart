// platform_mobile.dart
import 'dart:io' show Platform;

String getApiEndpoint() {
  try {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8001/api';
    } else if (Platform.isIOS) {
      return 'http://10.0.2.2:8001/api';
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'https://dating-aybxhug7hfawfjh3.centralindia-01.azurewebsites.net/api';
    } else {
      return 'https://dating-aybxhug7hfawfjh3.centralindia-01.azurewebsites.net/api';
    }
  } catch (e) {
    // If Platform is not available, return a default value
    return 'https://dating-aybxhug7hfawfjh3.centralindia-01.azurewebsites.net/api';
  }
}
