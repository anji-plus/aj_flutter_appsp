import 'aj_flutter_appsp_lib.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Copyright © 2018 anji-plus
/// 安吉加加信息技术有限公司
/// http://www.anji-plus.com
/// All rights reserved.
/// AppSp method for flutter
class AjFlutterAppSp {
  static const MethodChannel _channel = const MethodChannel('aj_flutter_appsp');

  ///[appKey] Application unique key
  ///[host] Base request url
  ///[debug] Check log switch is opened，true indicates open
  static Future<String> init(
      {String appKey, String host, bool debug = true}) async {
    final String result = await _channel.invokeMethod(
        'init', {"appKey": appKey, "host": host, "debug": debug});
    return result;
  }

  ///Get version info
  static Future<SpRespUpdateModel> getUpdateModel() async {
    final String jsonStr = await _channel.invokeMethod('getUpdateModel');
    SpRespUpdateModel updateModel =
    SpRespUpdateModel.fromJson(json.decode(jsonStr));
    return updateModel;
  }

  ///Get Notice info
  static Future<SpRespNoticeModel> getNoticeModel() async {
    final String jsonStr = await _channel.invokeMethod('getNoticeModel');
    SpRespNoticeModel noticeModel =
    SpRespNoticeModel.fromJson(json.decode(jsonStr));
    return noticeModel;
  }
}