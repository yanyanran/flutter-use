// AppDelegate.h
#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

@interface AppDelegate : FlutterAppDelegate

- (int)getBatteryLevel;
- (NSString *)getFromOCClientMessage;

@end
