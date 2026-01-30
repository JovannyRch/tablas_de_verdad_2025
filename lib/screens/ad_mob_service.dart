import 'dart:io';

import 'package:tablas_de_verdad_2025/const/const.dart';

class AdmobService {
  /* static const MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(); */

  static String getAdmobId() {
    if (Platform.isIOS) {
      return "";
    } else if (Platform.isAndroid) {
      if (IS_TESTING) {
        return Platform.isAndroid
            ? 'ca-app-pub-7319269804560504/8512599311'
            : 'ca-app-pub-3940256099942544/4411468910';
      }
      return ADMOB_ID ?? "ca-app-pub-3940256099942544~3347511713";
    }
    return '';
  }

  static String getStepByStepId() {
    if (Platform.isIOS) {
      return "";
    } else if (Platform.isAndroid) {
      if (IS_TESTING) {
        return "ca-app-pub-3940256099942544/1033173712";
      }
      return STEP_BY_STEP_ID;
    }
    return '';
  }

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

  static String? getShareAndSaveId() {
    if (Platform.isIOS) {
      return "";
    } else if (Platform.isAndroid) {
      if (IS_TESTING) {
        return "ca-app-pub-3940256099942544/1033173712";
      }
      return SHARE_AND_SAVE_ID;
    }
    return null;
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

  static String getRewardPdfId() {
    if (Platform.isIOS) {
      return "";
    }
    if (Platform.isAndroid) {
      if (IS_TESTING) {
        return 'ca-app-pub-3940256099942544/5224354917';
      }
      return "ca-app-pub-4665787383933447/1174950441";
    }
    return '';
  }
}
