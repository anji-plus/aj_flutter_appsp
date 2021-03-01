#import "AjFlutterAppspPlugin.h"
#import <AJSDKAppSpOc/AppSpService.h>
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
            [[AppSpService shareService] initConfig:appKey withDebug:debug withHost:host];
        } else {
            [[AppSpService shareService] initConfig:appKey withDebug:debug withHost:nil];
        }
    } else if ([call.method isEqualToString: @"getUpdateModel"]) {
    // 版本更新
      __weak typeof(self) weakSelf = self;
      [[AppSpService shareService] checkVersionUpdate:^(NSDictionary *repData) {
          result([weakSelf formateDictToJSonString:repData]);
      } withFailure:^(NSDictionary *repData) {
          result([weakSelf formateDictToJSonString:repData]);
      }];
    } else if ([call.method isEqualToString:@"getNoticeModel"]) {
    //获取公告信息
      __weak typeof(self) weakSelf = self;
      [[AppSpService shareService] getNoticeInfo:^(NSDictionary *repData) {
          result([weakSelf formateDictToJSonString:repData]);
      } withFailure:^(NSDictionary *repData) {
          result([weakSelf formateDictToJSonString:repData]);
      }];
      
    } else if ([@"launchUrl" isEqualToString:call.method]) {
    //跳转外部链接
        NSDictionary *arguments = [call arguments];
        NSString *utlString = arguments[@"url"];
        [self launchURL:utlString result:result];
      
    } else {
      result(FlutterMethodNotImplemented);
    }
}

//跳转
- (void)launchURL:(NSString *)urlString result:(FlutterResult)result {
    NSURL *url = [NSURL URLWithString:urlString];
    if([[UIApplication sharedApplication] canOpenURL:url]){
        [[UIApplication sharedApplication] openURL:url];
    }
    result(@"");
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
