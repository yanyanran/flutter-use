#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>

@interface TestPlugin : NSObject <FlutterPlugin>
@end

@implementation TestPlugin

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"calendar_plugin" binaryMessenger:[registrar messenger]];
    TestPlugin* instance = [[TestPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall *)call result:(FlutterResult)result {
    if ([@"getPlatformVersion" isEqualToString:call.method]) {
        NSString *platformVersion = [UIDevice currentDevice].systemVersion;
        result([NSString stringWithFormat:@"iOS %@", platformVersion]);
    } else if ([@"addEventToCalendar" isEqualToString:call.method]){  // ***add
        if (call.arguments == nil) {
            result([FlutterError errorWithCode:@"Invalid parameters" message:@"Invalid parameters" details:nil]);
            return;
        }
    } else {
        result(FlutterMethodNotImplemented);
    }
}

@end
