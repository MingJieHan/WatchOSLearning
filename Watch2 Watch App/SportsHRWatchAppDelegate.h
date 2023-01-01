//
//  Watch2AppDelegate.h
//  Watch2 Watch App
//
//  Created by jia yu on 2022/12/5.
//

//https://developer.apple.com/documentation/watchkit/wkapplicationdelegate?language=objc

#import <WatchKit/WatchKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface SportsHRWatchAppDelegate : NSObject <WKApplicationDelegate>
@property(nonatomic, readonly, nullable) WKInterfaceController *rootInterfaceController;

@end
NS_ASSUME_NONNULL_END
