//
//  NSOC.h
//  WatchApp Watch App
//
//  Created by jia yu on 2022/11/25.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <HealthKit/HealthKit.h>
#import <CoreLocation/CoreLocation.h>

@class CLLocation;
typedef void (^CoreSportsHRForWatchOS_HtmlHandler) (NSString * _Nonnull result);
typedef void (^CoreSportsHRForWatchOS_HRHandler) (int bpm);
typedef void (^CoreSportsHRForWatchOS_AuthorizationHandler) (BOOL completed);
typedef void (^CoreSportsHRForWatchOS_UpdateLocationsHandler) (NSArray <CLLocation *>* _Nullable locations,
                                                               NSString * _Nullable errorString);

API_AVAILABLE(watchos(2.0)) API_UNAVAILABLE(ios)
@interface CoreSportsHRForWatchOS : NSObject
+(CoreSportsHRForWatchOS * _Nonnull )shared;

//YES that mean can request,
-(BOOL)SpO2Authorization;
-(BOOL)HRAuthorization;

-(BOOL)requestSpO2AuthorizationWith:(CoreSportsHRForWatchOS_AuthorizationHandler _Nonnull )handler;
-(BOOL)requestHRAuthorizationWith:(CoreSportsHRForWatchOS_AuthorizationHandler _Nonnull )handler;
-(BOOL)requestAuthorizationWith:(CoreSportsHRForWatchOS_AuthorizationHandler _Nonnull )handler;

-(void)httpWithHandler:(CoreSportsHRForWatchOS_HtmlHandler _Nonnull )handler;

-(void)workingOutStart;
-(void)workingOutStop;

-(BOOL)hrStartWithHandler:(CoreSportsHRForWatchOS_HRHandler _Nonnull )handler;
-(void)hrStop;

-(BOOL)locationStartWithHandler:(CoreSportsHRForWatchOS_UpdateLocationsHandler _Nonnull)handler;
-(void)locationStop;

@property (nonatomic) float volume; //0 -> 1.f default is 0.2
@property (nonatomic,readonly) AVAudioPlayer * _Nullable audioPlayer;
-(BOOL)audioStart:(NSURL * _Nonnull )audioURL;
-(void)audioStop;

+(NSString * _Nullable )saveHRfile:(NSArray * _Nullable )HRsArray withSpeeds:(NSArray * _Nullable )speedsArray;
+(NSString * _Nullable )saveLocation:(NSArray * _Nullable)timeArray withLongitude:(NSArray * _Nullable)longitudeArray withLatitude:(NSArray * _Nullable)latitudeArray withAltitude:(NSArray * _Nullable)altitudeArray;
@end
