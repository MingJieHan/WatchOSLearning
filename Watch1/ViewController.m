//
//  ViewController.m
//  Watch1
//
//  Created by jia yu on 2022/11/28.
//

#import "ViewController.h"
#import <SportsHRWatch/SportsHRWatch.h>

@interface ViewController (){

}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSURL *url = [NSURL URLWithString:@"https://www.hanmingjie.com/"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    [task resume];
    
//    [CoreSportsHRForWatchOS.shared hrStartWithHandler:^(int bpm) {
//
//    }];
}
@end
