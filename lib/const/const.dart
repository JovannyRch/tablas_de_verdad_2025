final IS_TESTING = true;

const Map<String, String> esSettings = {
  "id": "com.jovannyrch.tablasdeverdad",
  "title": "Tablas de Verdad",
  "ADMOB_ID": "ca-app-pub-4665787383933447~4689744776",
  "VIDEO_ID": "ca-app-pub-4665787383933447/1003394249",
  "STEP_BY_STEP": "ca-app-pub-4665787383933447/9789289099",
  "SHARE_AND_SAVE_ID": "ca-app-pub-4665787383933447/8643480964",
  "BANNER_1": "ca-app-pub-4665787383933447/9637438366",
};

const Map<String, String> enSettings = {
  "id": "com.jovannyrch.tablasdeverdad.en",
  "title": "Truth Tables",
  "ADMOB_ID": "ca-app-pub-4665787383933447~1652617896",
  "VIDEO_ID": "ca-app-pub-4665787383933447/2599030026",
  "STEP_BY_STEP": "ca-app-pub-4665787383933447/2599030026", //TODO: Set a new id
  "SHARE_AND_SAVE_ID":
      "ca-app-pub-4665787383933447/2599030026", //TODO: Set a new id
  "BANNER_1": "ca-app-pub-4665787383933447/5463223780",
};

const Map<String, String> proSettings = {
  "id": "com.jovannyrch.tablasdeverdad.es.pro",
  "title": "Tablas de Verdad | Pro",

  "ADMOB_ID": "ca-app-pub-4665787383933447~4689744776",
  "VIDEO_ID": "ca-app-pub-4665787383933447/1003394249",
  "STEP_BY_STEP": "ca-app-pub-4665787383933447/9789289099",
  "SHARE_AND_SAVE_ID": "ca-app-pub-4665787383933447/8643480964",
  "BANNER_1": "ca-app-pub-4665787383933447/9637438366",
};

final settings = enSettings;

String? APP_ID = settings["id"];
String? APP_NAME = settings["title"];
String? DEFAULT_LANG = settings["lang"];
String? ADMOB_ID = settings["ADMOB_ID"];
String? VIDEO_ID = settings["VIDEO_ID"];
String STEP_BY_STEP_ID = settings["STEP_BY_STEP"]!;
String SHARE_AND_SAVE_ID = settings["SHARE_AND_SAVE_ID"]!;
String BANNER_ID = settings["BANNER_1"]!;
