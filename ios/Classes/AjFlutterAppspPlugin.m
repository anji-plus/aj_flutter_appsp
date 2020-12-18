#import "AjFlutterAppspPlugin.h"
#import <AJSDKAppSp/AJSDKAppSp-Swift.h>
@implementation AjFlutterAppspPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"aj_flutter_appsp"
            binaryMessenger:[registrar messenger]];
  AjFlutterAppspPlugin* instance = [[AjFlutterAppspPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    // 初始化版本
    if ([call.method isEqualToString: @"init"]){
        NSString *appKey = call.arguments[@"appKey"];
        NSString *host = call.arguments[@"host"];
        NSString *debug = call.arguments[@"debug"];
        if (host != nil && host.length > 0) {
            [[AppSpService shareService] initConfigWithAppkey:appKey debug:debug :host];
        } else {
            [[AppSpService shareService] initConfigWithAppkey:appKey debug:debug :nil];
        }
    } else if ([call.method isEqualToString: @"getUpdateModel"]) {
    // 版本更新
      __weak typeof(self) weakSelf = self;
      [[AppSpService shareService] checkVersionUpdateWithSuccess:^(NSDictionary* repData) {
          result([weakSelf formateDictToJSonString:repData]);
      } failure:^(NSDictionary* errorData) {
          result([weakSelf formateDictToJSonString:errorData]);
      }];
    } else if ([call.method isEqualToString:@"getNoticeModel"]) {
    //获取公告信息
      __weak typeof(self) weakSelf = self;
      [[AppSpService shareService] getNoticeInfoWithSuccess:^(NSDictionary* repData) {
          result([weakSelf formateDictToJSonString:repData]);
      } failure:^(NSDictionary* errorData) {
          result([weakSelf formateDictToJSonString:errorData]);
      }];
      
    } else {
      result(FlutterMethodNotImplemented);
    }
}

//字典转jsonstring
- (NSString *)formateDictToJSonString:(NSDictionary*) dict {
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (error != nil) {
        return @"";
    } else {
        return jsonStr;
    }
}

@end
