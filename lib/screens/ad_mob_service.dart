import 'dart:io';

import 'package:tablas_de_verdad_2025/const/const.dart';

class AdmobService {
  /* static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(); */

  static String getVideoId() {
    if (Platform.isIOS) {
      return "";
    } else if (Platform.isAndroid) {
      if (IS_TESTING) {
        return "ca-app-pub-3940256099942544/1033173712";
      }
      return VIDEO_ID ?? "ca-app-pub-3940256099942544/1033173712";
    }
    return VIDEO_ID ?? "ca-app-pub-3940256099942544/1033173712";
  }

  static String getBannerId() {
    if (Platform.isIOS) {
      return "";
    } else if (Platform.isAndroid) {
      if (IS_TESTING) {
        return 'ca-app-pub-3940256099942544/6300978111';
      }
      return BANNER_ID;
    }
    return '';
  }
}
