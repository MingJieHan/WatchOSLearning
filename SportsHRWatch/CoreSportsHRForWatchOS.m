//
//  NSOC.m
//  WatchApp Watch App
//
//  Created by jia yu on 2022/11/25.
//

#import "CoreSportsHRForWatchOS.h"

CoreSportsHRForWatchOS *staticOC API_AVAILABLE(watchos(2.0)) API_UNAVAILABLE(ios);

@interface CoreSportsHRForWatchOS()<AVAudioPlayerDelegate,CLLocationManagerDelegate,HKWorkoutSessionDelegate,NSURLSessionTaskDelegate>{
    NSURLSessionDataTask *task1;
    
    HKHealthStore *store;
    HKWorkoutSession *session;
    
    HKAnchoredObjectQuery *hrQuery;
    HKAnchoredObjectQuery *spo2Query;
    HKSampleType *typeHR;
    HKSampleType *typeSpO2;
    HKUnit *heartRateUnit;
    HKUnit *spO2Unit;
    
    CoreSportsHRForWatchOS_UpdateLocationsHandler locationHandler;
    CLLocationManager *locationManager;
    BOOL locationUpdating;
    
    
    NSTimer *debugTimer;
}
@end

@implementation CoreSportsHRForWatchOS
@synthesize volume;
@synthesize audioPlayer;

+(CoreSportsHRForWatchOS *)shared{
    if (nil == staticOC){
        staticOC = [[CoreSportsHRForWatchOS alloc] init];
    }
    return staticOC;
}

-(id)init{
    self = [super init];
    if (self){
        volume = 0.2f;
    }
    return self;
}

-(BOOL)SpO2Authorization{
    if (nil == store){
        store = [[HKHealthStore alloc] init];
    }
    if (nil == typeSpO2){
        typeSpO2 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    }
    HKAuthorizationStatus authorizationSpO2 = [store authorizationStatusForType:typeSpO2];
    switch (authorizationSpO2) {
        case HKAuthorizationStatusSharingAuthorized:
            return YES;
        case HKAuthorizationStatusSharingDenied:
            return NO;
        case HKAuthorizationStatusNotDetermined:
            return NO;
        default:
            break;
    }
}

-(BOOL)HRAuthorization{
    if (nil == store){
        store = [[HKHealthStore alloc] init];
    }
    if (nil == typeHR){
        typeHR = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    }
    HKAuthorizationStatus authorization = [store authorizationStatusForType:typeHR];
    switch (authorization) {
        case HKAuthorizationStatusSharingAuthorized:
            return YES;
        case HKAuthorizationStatusSharingDenied:
            return NO;
        case HKAuthorizationStatusNotDetermined:
            return NO;
        default:
            break;
    }
    return NO;
}

-(BOOL)requestAuthorizationWith:(CoreSportsHRForWatchOS_AuthorizationHandler)handler withSet:(NSSet *)set{
    if (nil == store){
        store = [[HKHealthStore alloc] init];
    }
    [store requestAuthorizationToShareTypes:set readTypes:set completion:^(BOOL success, NSError * _Nullable error) {
        if (error){
            NSLog(@"Authorization Error:%@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(NO);
            });
            return;
        }
        if (success){
            NSLog(@"HealthKit Authorization passed.");
            dispatch_async(dispatch_get_main_queue(), ^{
                //给了读取心率的权限后，继续系统环境检查
                handler(YES);
            });
        }else{
            NSLog(@"Authorization Unsuccess.");
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(NO);
            });
        }
        return;
    }];
    return YES;
}

-(BOOL)requestSpO2AuthorizationWith:(CoreSportsHRForWatchOS_AuthorizationHandler _Nonnull )handler{
    if (nil == typeSpO2){
        typeSpO2 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    }
    NSSet *set = [[NSSet alloc] initWithArray:@[typeSpO2]];
    return [self requestAuthorizationWith:handler withSet:set];
}

-(BOOL)requestHRAuthorizationWith:(CoreSportsHRForWatchOS_AuthorizationHandler _Nonnull )handler{
    if (nil == typeHR){
        typeHR = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    }
    NSSet *set = [[NSSet alloc] initWithArray:@[typeHR]];
    return [self requestAuthorizationWith:handler withSet:set];
}

-(BOOL)requestAuthorizationWith:(CoreSportsHRForWatchOS_AuthorizationHandler _Nonnull )handler{
    if (nil == typeSpO2){
        typeSpO2 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    }
    if (nil == typeHR){
        typeHR = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    }
    NSSet *set = [[NSSet alloc] initWithArray:@[typeHR,typeSpO2]];
    return [self requestAuthorizationWith:handler withSet:set];
}

-(void)httpWithHandler:(CoreSportsHRForWatchOS_HtmlHandler)handler{
    //https://developer.apple.com/documentation/watchos-apps/making-default-and-ephemeral-requests?language=objc
    NSString *url = @"https://www.hanmingjie.com/";
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionConfiguration *conf = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    conf.allowsCellularAccess = YES;
    conf.waitsForConnectivity = YES;
    conf.timeoutIntervalForRequest = 10;
    conf.timeoutIntervalForResource = 30;
    conf.requestCachePolicy = NSURLRequestReloadIgnoringCacheData;
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.qualityOfService = NSQualityOfServiceUserInitiated;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:conf delegate:nil delegateQueue:queue];
    task1 = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error){
            handler([error localizedDescription]);
            NSLog(@"dataTask Error:%@", [error localizedDescription]);
            return;
        }
        NSString *s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        handler(s);
        NSLog(@"print in Object-C:%@", s);
        return;
    }];
    
    if (@available(watchOS 8.0, *)) {
        task1.delegate = self;
    }
    NSLog(@"task1 started.");
    [task1 resume];
}

-(void)audioStop{
    if (nil == audioPlayer){
        return;
    }
    [audioPlayer pause];
    [audioPlayer stop];
    audioPlayer = nil;
    NSError *error = nil;
    BOOL res = [AVAudioSession.sharedInstance setActive:NO error:&error];
    if (NO == res || nil != error){
        NSLog(@"Audio stop failed.");
    }
    return;
}

-(BOOL)audioStart:(NSURL * _Nonnull )audioURL{
    if (nil == audioURL){
        return NO;
    }
    NSError *err = nil;
    BOOL res = [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeMoviePlayback options:AVAudioSessionCategoryOptionMixWithOthers error:&err];
    if (NO == res || nil != err){
        NSLog(@"setCategory failed.");
        return NO;
    }
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&err];
    audioPlayer.volume = volume;
    audioPlayer.delegate = self;
    [audioPlayer prepareToPlay];
    return [audioPlayer play];
}

-(void)dealloc{
    NSLog(@"released");
}

-(void)spo2{
    if (nil == typeSpO2){
        typeSpO2 = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    }
    spO2Unit = [HKUnit percentUnit];
    NSDate *startDate = [NSDate date];
    NSPredicate *datePredicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:nil options:HKQueryOptionStrictStartDate];
    
    NSSet *devicesSet = [NSSet setWithArray:@[[HKDevice localDevice]]];
    NSPredicate *devicePredicate = [HKQuery predicateForObjectsFromDevices:devicesSet];
    NSPredicate *p = [NSCompoundPredicate andPredicateWithSubpredicates:@[datePredicate,devicePredicate]];

    CoreSportsHRForWatchOS * __strong strongSelf = self;
    spo2Query = [[HKAnchoredObjectQuery alloc] initWithType:typeSpO2 predicate:p anchor:nil limit:HKObjectQueryNoLimit resultsHandler:^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
            if (error){
                NSLog(@"SpO2历史查询错误 Query Error:%@", error);
                return;
            }else{
                NSLog(@"在最近的1000秒内，查到了:%lu个SpO2信息。", (unsigned long)sampleObjects.count);
                NSLog(@"Last %@", sampleObjects.lastObject);        //最近一个
                NSLog(@"First %@", sampleObjects.firstObject);      //
            }
        }];
    spo2Query.updateHandler = ^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable addedObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
        HKSample *sample = addedObjects.firstObject;
        if (addedObjects.count > 1){
            NSLog(@"Debug");
        }
        if ([sample isKindOfClass:[HKQuantitySample class]]){
            HKQuantitySample *s = (HKQuantitySample *)sample;
            double f = [s.quantity doubleValueForUnit:strongSelf->spO2Unit];
            NSLog(@"SpO2:%.0f", f);
//            self->hr = (NSInteger)f;
//            self->hrDate = s.startDate;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [strongSelf setTitle:@"Collecting"];
//                [strongSelf refresh];
//            });
//            [strongSelf sentHRResult];
        }else{
            NSLog(@"Other type result.");
        }
        return;
    };
    NSLog(@"SpO2 query action.");
    [store executeQuery:spo2Query];
    
}

-(BOOL)hrStartWithHandler:(CoreSportsHRForWatchOS_HRHandler)handler{
    if (NO == [self HRAuthorization]){
        NSLog(@"HR Authorization Denied.");
        return NO;
    }
    if (nil == typeHR){
        typeHR = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    }
    NSDate *startDate = [NSDate dateWithTimeIntervalSinceNow:-60]; //1分钟内的HR认为有效
    NSPredicate *datePredicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:nil options:HKQueryOptionStrictStartDate];
    
    NSSet *devicesSet = [NSSet setWithArray:@[[HKDevice localDevice]]];
    NSPredicate *devicePredicate = [HKQuery predicateForObjectsFromDevices:devicesSet];
    NSPredicate *p = [NSCompoundPredicate andPredicateWithSubpredicates:@[datePredicate, devicePredicate]];

    CoreSportsHRForWatchOS * __strong strongSelf = self;
    
    hrQuery = [[HKAnchoredObjectQuery alloc] initWithType:typeHR predicate:p anchor:nil limit:HKObjectQueryNoLimit resultsHandler:^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
            if (error){
                NSLog(@"HR history Query Error:%@", error);
                return;
            }else{
                NSLog(@"Found %lu HR in 60 seconds.", (unsigned long)sampleObjects.count);
                if (nil == strongSelf->heartRateUnit){
                    strongSelf->heartRateUnit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
                }
                HKQuantitySample *last = sampleObjects.lastObject;
                NSLog(@"Last HR: %.0f in %@", [last.quantity doubleValueForUnit:strongSelf->heartRateUnit], last.endDate);
                HKQuantitySample *first = sampleObjects.firstObject;
                NSLog(@"First HR: %.0f in %@", [first.quantity doubleValueForUnit:strongSelf->heartRateUnit], first.endDate);
            }
        }];
    
    hrQuery.updateHandler = ^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable addedObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
        if (0 == addedObjects.count){
            NSLog(@"Added HR is empty.");
            return;
        }
        HKSample *sample = addedObjects.firstObject;
        if (addedObjects.count > 1){
            NSLog(@"HR Debug");
        }
        if (nil == sample){
            NSLog(@"HR sample is nil.");
            return;
        }
        if ([sample isKindOfClass:[HKQuantitySample class]]){
            HKQuantitySample *s = (HKQuantitySample *)sample;
            if (nil == strongSelf->heartRateUnit){
                strongSelf->heartRateUnit = [[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]];
            }
            double f = [s.quantity doubleValueForUnit:strongSelf->heartRateUnit];
//            NSLog(@"HR:%.0f", f);
//            self->hr = (NSInteger)f;
//            self->hrDate = s.startDate;
            dispatch_async(dispatch_get_main_queue(), ^{
                handler((int)f);
            });
        }else{
            NSLog(@"HR Other type result.");
        }
        return;
    };
    NSLog(@"HR query action.");
    
    [store executeQuery:hrQuery];
    return YES;
}

-(void)hrStop{
    if (NO == [NSThread isMainThread]){
        NSLog(@"Warning: HR stop can NOT in thread.");
    }
    NSLog(@"HR stoped.");
    [store stopQuery:hrQuery];
    hrQuery = nil;
    return;
}

-(void)locationStop{
    [locationManager stopUpdatingLocation];
    locationManager = nil;
    locationUpdating = NO;
    return;
}

-(void)startUpdateWithMainThread{
    if (locationUpdating){
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->locationUpdating){
            return;
        }
        self->locationUpdating = YES;
//        NSLog(@"start updateing location.");
        [self->locationManager startUpdatingLocation];
        
    });
}

-(void)continueLocationStartInThread{
    BOOL enable = [CLLocationManager locationServicesEnabled];
    if (NO == enable){
        NSLog(@"Location service disabled");
        locationHandler(nil, @"Location Services Disabled");
        locationManager = nil;
        locationUpdating = NO;
        return;
    }
    if (nil == locationManager){
        locationUpdating = NO;
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.delegate = self;
        locationManager.distanceFilter = 0.3f;
        locationManager.allowsBackgroundLocationUpdates = YES;
    }
    CLAuthorizationStatus status = [locationManager authorizationStatus];
    switch (status) {
#ifdef API_UNAVAILABLE_BEGIN //(MacOS)
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self startUpdateWithMainThread];
            break;
#endif //API_UNAVAILABLE_END
        case kCLAuthorizationStatusAuthorizedAlways:
            [self startUpdateWithMainThread];
            break;
        case kCLAuthorizationStatusNotDetermined:
            [locationManager requestWhenInUseAuthorization];
            break;
        case kCLAuthorizationStatusDenied:
            locationHandler(nil, @"Location Denied");
            locationManager = nil;
            locationUpdating = NO;
            break;
        case kCLAuthorizationStatusRestricted:
            locationHandler(nil, @"Location Restricted");
            locationManager = nil;
            locationUpdating = NO;
            break;
        default:
            break;
    }
    return;
}
-(BOOL)locationStartWithHandler:(CoreSportsHRForWatchOS_UpdateLocationsHandler _Nonnull)handler{
    locationHandler = handler;
    if (NO == [NSThread isMainThread]){
        NSLog(@"locationStartWithHandler not call in MainThread");
        return NO;
    }
    if (nil == locationManager){
        locationUpdating = NO;
        locationManager = [[CLLocationManager alloc] init];
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        locationManager.delegate = self;
        locationManager.distanceFilter = 0.3f;
        locationManager.allowsBackgroundLocationUpdates = YES;
    }
    [NSThread detachNewThreadWithBlock:^{
        [self continueLocationStartInThread];
    }];
    return YES;
}

-(void)workingOutStart{
    HKWorkoutConfiguration *configuration = [[HKWorkoutConfiguration alloc] init];
    configuration.activityType = HKWorkoutActivityTypeWalking;
    configuration.locationType = HKWorkoutSessionLocationTypeOutdoor;
    if (nil == store){
        store = [[HKHealthStore alloc] init];
    }

    if (nil == session){
        NSError *error = nil;
        session = [[HKWorkoutSession alloc] initWithHealthStore:store configuration:configuration error:&error];
        session.delegate = self;
        if (error){
            NSLog(@"HKWorkoutSession init error:%@", error.description);
        }
    }
    [session startActivityWithDate:nil];
}

-(void)workingOutStop{
    NSLog(@"WorkingOut Stop action.");
    [session stopActivityWithDate:NSDate.now];
}

+(NSString * _Nullable)saveHRfile:(NSArray * _Nullable )HRsArray withSpeeds:(NSArray * _Nullable )speedsArray{
    NSString *hrFile = [NSHomeDirectory() stringByAppendingString:@"/Documents/hr.dat"];
    if ([NSFileManager.defaultManager fileExistsAtPath:hrFile]){
        [NSFileManager.defaultManager removeItemAtPath:hrFile error:nil];
    }
    FILE *fp = fopen([hrFile UTF8String], "wb");
    for (int i=0;i<HRsArray.count;i++){
        NSInteger hr = [[HRsArray objectAtIndex:i] integerValue];
        float speed = [[speedsArray objectAtIndex:i] floatValue];
        fwrite(&hr, sizeof(hr), 1, fp);
        fwrite(&speed, sizeof(speed), 1, fp);
    }
    fclose(fp);
    return hrFile;
}

+(NSString * _Nullable )saveLocation:(NSArray * _Nullable)timeArray withLongitude:(NSArray * _Nullable)longitudeArray withLatitude:(NSArray * _Nullable)latitudeArray withAltitude:(NSArray * _Nullable)altitudeArray{
    NSString *currentFile = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@.dat", [NSDate date]];
    if ([NSFileManager.defaultManager fileExistsAtPath:currentFile]){
        [NSFileManager.defaultManager removeItemAtPath:currentFile error:nil];
    }
    FILE *locationFile_fp = fopen([currentFile UTF8String], "wb");
    if (nil == locationFile_fp){
        NSLog(@"Error aboutn Map recording file open is nil.");
    }

    for (int index = 0;index<timeArray.count; index++){
        double t = [[timeArray objectAtIndex:index] doubleValue];
        double longitude = [[longitudeArray objectAtIndex:index] doubleValue];
        double latitude = [[latitudeArray objectAtIndex:index] doubleValue];
        double altitude = [[altitudeArray objectAtIndex:index] doubleValue];
        fwrite(&t, sizeof(t), 1, locationFile_fp);
        fwrite(&latitude, sizeof(latitude), 1, locationFile_fp);
        fwrite(&longitude, sizeof(longitude), 1, locationFile_fp);
        fwrite(&altitude, sizeof(altitude), 1, locationFile_fp);
    }
    fclose(locationFile_fp);
    return currentFile;
}


#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    return;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error{
    return;
}

#pragma mark - CLLocationManagerDelegate
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    if (0 == locations.count){
        return;
    }
    locationHandler(locations, nil);
    return;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    locationHandler(nil, [error localizedDescription]);
    return;
}


- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager API_AVAILABLE(ios(14.0), macos(11.0), watchos(7.0), tvos(14.0)){
    [self startUpdateWithMainThread];
    return;
}

#pragma mark - HKWorkoutSessionDelegate
- (void)workoutSession:(HKWorkoutSession *)workoutSession
      didChangeToState:(HKWorkoutSessionState)toState
             fromState:(HKWorkoutSessionState)fromState
                  date:(NSDate *)date{
    if (HKWorkoutSessionStateRunning == toState && HKWorkoutSessionStateNotStarted == fromState){
        NSLog(@"%@ workout started.", date);
        return;
    }
    if (HKWorkoutSessionStateStopped == toState && HKWorkoutSessionStateRunning == fromState){
        NSLog(@"%@ workout stoped.", date);
        [workoutSession end];
        return;
    }
    if (HKWorkoutSessionStateEnded == toState){
        NSLog(@"%@ workout ended", date);
        session = nil;
        return;
    }
    return;
}

- (void)workoutSession:(HKWorkoutSession *)workoutSession didFailWithError:(NSError *)error{
    if (error){
        NSLog(@"%@", [error description]);
    }
    return;
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    if (error){
        NSLog(@"URLSession Error:%@", error);
    }
    return;
}
- (void)URLSession:(NSURLSession *)session taskIsWaitingForConnectivity:(NSURLSessionTask *)task
API_AVAILABLE(macos(10.13), ios(11.0), watchos(4.0), tvos(11.0)){
    NSLog(@"waiting for connectivity.");
    return;
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
                                 didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (NS_SWIFT_SENDABLE ^)(NSURLSessionResponseDisposition disposition))completionHandler{
    return;
}

@end
