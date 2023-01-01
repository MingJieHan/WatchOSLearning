//
//  Watch2AppDelegate.m
//  Watch2 Watch App
//
//  Created by jia yu on 2022/12/5.
//

#import "SportsHRWatchAppDelegate.h"

@interface SportsHRWatchAppDelegate(){
}
@end

@implementation SportsHRWatchAppDelegate
@synthesize rootInterfaceController;

- (void)applicationDidFinishLaunching{
    NSLog(@"Watch2 Application Delegate start.");
    return;
}

- (void)applicationDidBecomeActive{
    return;
}

- (void)applicationWillResignActive{
    return;
}


- (void)applicationWillEnterForeground{
    return;
}


- (void)applicationDidEnterBackground{
    return;
}

// iOS app started a workout. -[HKHealthStore startWorkoutSession:] should be called from here
- (void)handleWorkoutConfiguration:(HKWorkoutConfiguration *)workoutConfiguration{
    return;
}

// app crashed while in a workout
- (void)handleActiveWorkoutRecovery{
    return;
}

// app had a WKExtendedRuntimeSession already running or scheduled at the time it was launched, or the app was registered as the default responder for this session. To recover the session or start the session as the session default provider, set a delegate on it before this method returns. If no delegate is set, the session will be ended.
- (void)handleExtendedRuntimeSession:(WKExtendedRuntimeSession *)extendedRuntimeSession{
    return;
}

// app brought frontmost due to auto-launching audio apps
- (void)handleRemoteNowPlayingActivity{
    return;
}

- (void)handleUserActivity:(nullable NSDictionary *)userInfo{
    return;
}

- (void)handleActivity:(NSUserActivity *)userActivity{
    return;
}

- (void)handleIntent:(INIntent *)intent completionHandler:(void(^)(INIntentResponse *intentResponse))completionHandler{
    return;
}

- (void)handleBackgroundTasks:(NSSet <WKRefreshBackgroundTask *> *)backgroundTasks{
    return;
}

- (void)deviceOrientationDidChange{
    return;
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    return;
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    return;
}

- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(WKBackgroundFetchResult result))completionHandler{
    return;
}

- (void)userDidAcceptCloudKitShareWithMetadata:(CKShareMetadata *)cloudKitShareMetadata{
    return;
}

@end
