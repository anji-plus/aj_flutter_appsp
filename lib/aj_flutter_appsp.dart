import 'aj_flutter_appsp_lib.dart';

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

/// Copyright ? 2018 anji-plus
/// �����Ӽ���Ϣ�������޹�˾
/// http://www.anji-plus.com
/// All rights reserved.
/// AppSp����
class AjFlutterAppSp {
  static const MethodChannel _channel = const MethodChannel('aj_flutter_appsp');

  ///���û�����ַ������ڿ������Գ������õ�������ʱ��ǵøĳ�������ַ��������ò�Ҫ�Ա�¶set����
  ///[appKey] Ӧ��Ψһ��ʶ
  ///[host] �������������ַ
  ///[debug] �Ƿ����־���أ�trueΪ��
  static Future<String> init(
      {String appKey, String host, bool debug = true}) async {
    final String result = await _channel.invokeMethod(
        'init', {"appKey": appKey, "host": host, "debug": debug});
    return result;
  }

  ///��ȡ�汾��Ϣ
  static Future<SpRespUpdateModel> getUpdateModel() async {
    final String jsonStr = await _channel.invokeMethod('getUpdateModel');
    SpRespUpdateModel updateModel =
        SpRespUpdateModel.fromJson(json.decode(jsonStr));
    return updateModel;
  }

  ///��ȡ������Ϣ
  static Future<SpRespNoticeModel> getNoticeModel() async {
    final String jsonStr = await _channel.invokeMethod('getNoticeModel');
    SpRespNoticeModel noticeModel =
        SpRespNoticeModel.fromJson(json.decode(jsonStr));
    return noticeModel;
  }
}
