import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

String getApiEndpoint() {
  if (Platform.isAndroid) {
    print("android");
    return 'http://10.0.2.2:8001/api';
  } else if (Platform.isIOS) {
    return 'http://10.0.2.2:8001/api';
  } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    print('web');
    return 'http://localhost:8001/api';
  } else if (kIsWeb) {
    return 'http://localhost:8001/api';
  } else {
    return 'http://localhost:8001/api';
  }
}
