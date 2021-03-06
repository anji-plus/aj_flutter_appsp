import 'dart:io';
import 'dart:ui';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:aj_flutter_appsp_example/commons.dart';
import 'package:aj_flutter_appsp_example/navigator_utils.dart';
import '../button_factory.dart';
import 'package:aj_flutter_appsp_example/button_factory.dart';

// ignore: must_be_immutable
class VersionUpdateDialogNew extends Dialog {
  String title;
  String message;
  String negativeText;
  String positiveText;
  String iconPath;
  Function onCloseEvent;
  double minHeight;
  Color titleColor;
  Color buttonColor;
  double barHeight = 48;
  double radius = 20;
  bool mustUpdate;
  bool isExternalUrl;
  String url;
  List<String> versionMsgList;

  VersionUpdateDialogNew({
    Key key,
    this.iconPath,
    this.negativeText,
    this.positiveText,
    this.minHeight = 60,
    this.url = '',
    this.mustUpdate = false,
    this.isExternalUrl = false,
    this.versionMsgList,
    this.titleColor,
    this.buttonColor,
  })  : assert(minHeight > 0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return new VersionUpdateWidget(
      iconPath: iconPath,
      negativeText: negativeText,
      positiveText: positiveText,
      url: url,
      minHeight: minHeight,
      mustUpdate: mustUpdate,
      isExternalUrl: isExternalUrl,
      versionMsgList: versionMsgList,
      titleColor: titleColor,
      buttonColor: buttonColor,
    );
  }
}

class VersionUpdateWidget extends StatefulWidget {
  String title;
  String message;
  String negativeText;
  String positiveText;
  String iconPath;
  double minHeight;
  Color titleColor;
  Color buttonColor;
  double barHeight = 48;
  double radius = 20;
  double rate;
  String url;
  bool mustUpdate;
  bool isExternalUrl;
  List<String> versionMsgList;

  VersionUpdateWidget({
    Key key,
    this.iconPath,
    this.negativeText,
    this.positiveText,
    this.minHeight = 60,
    this.url = '',
    this.rate = 0.0,
    this.mustUpdate = false,
    this.isExternalUrl = false,
    this.versionMsgList,
    this.titleColor,
    this.buttonColor = Colors.blue,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    if (Platform.isIOS) {
      return new _iOSVersionUpdateWidgetState();
    }
    return new _VersionUpdateWidgetState();
  }
}

class _VersionUpdateWidgetState extends State<VersionUpdateWidget> {
  static const apkInstallChannel =
  const MethodChannel(Commons.apkinstallChannel);
  static const String apkInstallMethod = Commons.apkInstallMethod;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> getVersionLayout() {
    var scale = MediaQuery.of(context).textScaleFactor;
    List<Widget> list = [];
    List<Widget> msgItems = [];
    list.add(SizedBox(
      height: 12,
    ));


    if (widget.versionMsgList != null) {
      msgItems = widget.versionMsgList.map((msg) {
        return Container(
          constraints: BoxConstraints(minHeight: 24),
          child: new Text(
            msg,
            style: TextStyle(fontSize: 15.0 / scale, color: Color(0xFF666666)),
          ),
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(left: 12, right: 12,),
        );
      }).toList();
    }
    list.addAll(msgItems);
    list.add(SizedBox(
      height: 20,
    ));
    if (widget.isExternalUrl != true) {
      list.add(Container(
        margin: EdgeInsets.only(left: 6, right: 6),
        child: LinearProgressIndicator(
          backgroundColor: widget.buttonColor,
          valueColor: AlwaysStoppedAnimation<Color>(widget.titleColor),
          value: widget.rate,
        ),
      ));
    }
    list.add(SizedBox(
      height: 12,
    ));
    return list;
  }

  Widget getDivider({double height = 1.0}) {
    return Container(
      color: Color(0xFFf0f0f0),
      height: height,
    );
  }

  Widget _buildOperationBar() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Expanded(
            flex: 1,
            child: _getNegativeWidget(),
          ),
          new Expanded(
            flex: 1,
            child: _getPositiveWidget(),
          ),
        ]);
  }

  Widget _getNegativeWidget() {
    var scale = MediaQuery.of(context).textScaleFactor;
    return Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.only(bottomLeft: Radius.circular(widget.radius)),
        ),
        child: Container(
          alignment: Alignment.center,
          height: widget.barHeight,
          child: InkWell(
              child: Center(
                child: Text(widget.mustUpdate ? "退出" : '取消',
                    style: TextStyle(
                        color: Color(0xFF333333), fontSize: 16.0 / scale)),
              ),
              onTap: () {
                print('AAAAAAAAAAA');
                if (widget.mustUpdate) {
                  NavigatorUtils.popApp();
                } else {
                  Navigator.of(context).pop();
                }
              },
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(widget.radius))),
        ));
  }

  Widget _getPositiveWidget() {
    var scale = MediaQuery.of(context).textScaleFactor;
    return Material(
        color: widget.buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.only(bottomRight: Radius.circular(widget.radius)),
        ),
        child: Container(
          alignment: Alignment.center,
          height: widget.barHeight,
          child: InkWell(
              child: Center(
                child: Text('更新',
                    style:
                    TextStyle(color: Colors.white, fontSize: 16.0 / scale)),
              ),
              onTap: () {
                //开始下载
                if (widget.isExternalUrl == false) {
                  downloadFile(widget.url);
                } else {
                  //跳转到外部浏览器下载
                  NavigatorUtils.launchInBrowser(widget.url);
                }
              },
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(widget.radius))),
        ));
  }

  bool updateButtonEnable = true;
  Map<String, String> _fileMap = new Map();

  //用dio实现文件下载
  downloadFile(String apkUrl) async {
    if (!updateButtonEnable) {
      return;
    }
    if (_fileMap["path"] != null) {
      _pushAndInstall();
      return;
    }
    setState(() {
      updateButtonEnable = false;
    });
    Dio dio = new Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    // 获取本地文档目录
    String dir = (await getExternalStorageDirectory()).path;
    //保证唯一
    File file = new File('$dir/AJ_' +
        new DateTime.now().millisecondsSinceEpoch.toString() +
        '.apk');
    Response response = await dio.download(apkUrl, file.path,
        onReceiveProgress: (received, total) {
          print("total" + total.toString() + " received " + received.toString());
          double ratio = received / total;
          setState(() {
            widget.rate = ratio;
          });
          ratio = ratio * 100;
          print("rate" + ratio.toString() + "%");
          if (ratio >= 100) {
            setState(() {
              updateButtonEnable = true;
            });
            _notifyInstall(file);
          }
        });
  }

  _notifyInstall(File file) async {
    print("dart -_versionUpdate");
//      在通道上调用此方法
    Map<String, String> argument = new Map();
    argument["path"] = file.path;
    setState(() {
      _fileMap = argument;
    });
    _pushAndInstall();
  }

  _pushAndInstall() async {
    try {
      await apkInstallChannel.invokeMethod(apkInstallMethod, _fileMap);
    } on PlatformException catch (e) {
      print("dart -PlatformException ");
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    var scale = MediaQuery.of(context).textScaleFactor;
    return new Material(
      color: Colors.transparent,
      child:new Stack(
        alignment: Alignment.center,
        children: [

          //整个白色块的定义 (包含内容部分和 升级提示语)
          new Positioned(
            top: 200,
            left: 10,
            right: 10,
            child: new Column(
              children: [
                new Container(
                  width:400,
                  height: widget.versionMsgList.length>=5?300:250,
                  margin: const EdgeInsets.only(left: 20.0, right: 20.0,),
                  decoration: ShapeDecoration(
                    color: Color(0xffffffff),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(widget.radius),
                      ),
                    ),
                  ),

                  //标题和内容
                  child: new Container(height: 150,
                    margin: EdgeInsets.only(top: widget.versionMsgList.length>=5?45:60,bottom: 50),
                    child:
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        new Container(margin: EdgeInsets.only(bottom: 10),child: new Text("哇,发现新版本了!",style: TextStyle(fontSize: 16/scale),),),
                        new Container(height:widget.versionMsgList.length>=5? 90:60,child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.versionMsgList.length,
                          itemBuilder: (context,index){
                            return new Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text.rich(TextSpan(text: widget.versionMsgList[index],style: TextStyle(fontSize: 12/scale,color: Colors.grey),),maxLines: 10,));
                          },
                        ),)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          //上面的logo部分
          new Positioned(
              top:100,
              child:new Image.asset("images/version.png",width: 250/scale,height: 250/scale,scale: scale,)
          ),

          //右上角X的定义
          new Positioned(
              top:220,
              right: 45,
              child: new GestureDetector(child: new Container(width: 15,height: 15,child: new Image.asset("images/icon_dissmiss.png",)),
                onTap: (){
                  if (widget.mustUpdate) {
                    NavigatorUtils.popApp();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
              )
          ),

          //进度条的定义
          new Positioned(
              left: 40,
              right: 40,
              top: widget.versionMsgList.length>=5?450:400,
              child: widget.isExternalUrl != true?
              LinearProgressIndicator(
                backgroundColor: widget.buttonColor,
                valueColor:
                AlwaysStoppedAnimation<Color>(widget.titleColor),
                value: widget.rate,
              )
                  : new SizedBox(height: 0.1,)),

          //立即下载按钮的定义
          new Positioned(
              top:widget.versionMsgList.length>=5?500-widget.barHeight/2:475-widget.barHeight,
              child:
              new Container(
                alignment: Alignment.center,
                height: widget.barHeight,
                width: 200,
                margin: EdgeInsets.only(left: 20,right: 20),
                child: new GestureDetector(
                    onTap: () {
                      //开始下载
                      if (widget.isExternalUrl == false) {
                        downloadFile(widget.url);
                      } else {
                        //跳转到外部浏览器下载
                        NavigatorUtils.launchInBrowser(widget.url);
                      }
                    },child: ButtonFactory.getRoundLargeBtn(
                    context,
                    text: "立即更新",
                    highlightGradientColors: [
                      Color.fromRGBO(156, 124, 254, 1),
                      Color.fromRGBO(103, 104, 254, 1)
                    ],
                    textColor: Colors.white,
                    fontSize: 18,
                    height: widget.barHeight,
                    radius: widget.barHeight / 2,
                    onTap: (){
                      //开始下载
                      if (widget.isExternalUrl == false) {
                        downloadFile(widget.url);
                      } else {
                        //跳转到外部浏览器下载
                        NavigatorUtils.launchInBrowser(widget.url);
                      }
                    }
                )),
              )
          ),
        ],
      ),
    );
  }
}

class _iOSVersionUpdateWidgetState extends State<VersionUpdateWidget> {
  @override
  void initState() {
    super.initState();
  }

  List<Widget> getVersionLayout() {
    var scale = MediaQuery.of(context).textScaleFactor;
    List<Widget> list = [];
    List<Widget> msgItems = [];
    list.add(SizedBox(
      height: 12,
    ));
    if (widget.versionMsgList != null) {
      msgItems = widget.versionMsgList.map((msg) {
        return Container(
          constraints: BoxConstraints(minHeight: 24),
          child: new Text(
            msg,
            style: TextStyle(fontSize: 15.0 / scale, color: Color(0xFF666666)),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 12, right: 12),
        );
      }).toList();
    }
    list.addAll(msgItems);
    list.add(SizedBox(
      height: 12,
    ));
    return list;
  }

  Widget getDivider({double height = 1.0}) {
    return Container(
      color: Color(0xFFf0f0f0),
      height: height,
    );
  }

  Widget _buildOperationBar() {
    //widget.mustUpdate
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          widget.mustUpdate
              ? Container()
              : new Expanded(
            flex: 1,
            child: _getNegativeWidget(),
          ),
          new Expanded(
            flex: 1,
            child: _getPositiveWidget(),
          ),
        ]);
  }

  Widget _getNegativeWidget() {
    var scale = MediaQuery.of(context).textScaleFactor;
    return Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.only(bottomLeft: Radius.circular(widget.radius)),
        ),
        child: Container(
          alignment: Alignment.center,
          height: widget.barHeight,
          child: InkWell(
              child: Center(
                child: Text('取消',
                    style: TextStyle(
                        color: Color(0xFF333333), fontSize: 16.0 / scale)),
              ),
              onTap: () {
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(widget.radius))),
        ));
  }

  Widget _getPositiveWidget() {
    var scale = MediaQuery.of(context).textScaleFactor;
    return Material(
        color: widget.buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius: widget.mustUpdate
              ? BorderRadius.only(
              bottomLeft: Radius.circular(widget.radius),
              bottomRight: Radius.circular(widget.radius))
              : BorderRadius.only(bottomRight: Radius.circular(widget.radius)),
        ),
        child: Container(
          alignment: Alignment.center,
          height: widget.barHeight,
          child: InkWell(
              child: Center(
                child: Text('更新',
                    style:
                    TextStyle(color: Colors.white, fontSize: 16.0 / scale)),
              ),
              onTap: () {
                NavigatorUtils.gotoAppstore(context, widget.url);
              },
              borderRadius: widget.mustUpdate
                  ? BorderRadius.only(
                  bottomLeft: Radius.circular(widget.radius),
                  bottomRight: Radius.circular(widget.radius))
                  : BorderRadius.only(
                  bottomRight: Radius.circular(widget.radius))),
        ));
  }

  @override
  Widget build(BuildContext context) {
    var scale = MediaQuery.of(context).textScaleFactor;
    return new WillPopScope(
      child: new Padding(
        padding: const EdgeInsets.only(left: 40.0, right: 40.0),
        child: new Material(
          type: MaterialType.transparency,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                decoration: ShapeDecoration(
                  color: Color(0xffffffff),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(widget.radius),
                    ),
                  ),
                ),
                child: new Column(
                  children: <Widget>[
                    new Container(
                      child: new Text(
                        '新版发布',
                        style: TextStyle(
                            fontSize: 20.0 / scale, color: widget.titleColor),
                      ),
                      height: 36,
                      margin: EdgeInsets.only(top: 6),
                      alignment: Alignment.center,
                    ),
                    new Container(
                      constraints: BoxConstraints(minHeight: widget.minHeight),
                      child: Column(
                        children: getVersionLayout(),
                      ),
                    ),
                    getDivider(),
                    this._buildOperationBar(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onWillPop: () {
        if (widget.mustUpdate) {
          NavigatorUtils.popApp();
        } else {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
