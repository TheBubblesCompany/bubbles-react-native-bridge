//
//  DataAccess.h
//  BubblesTwo
//
//  Created by Pierre RACINE on 30/03/2016.
//  Copyright © 2016 Absolutlabs. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define DATA  [DataAccess dataAccess]

@class CLLocation;

@interface DataAccess : NSObject

+ (DataAccess *) dataAccess;


@property BOOL debug;
@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) NSString * latitude;
@property (nonatomic, strong) NSString * longitude;

//Header Parameters

@property (nonatomic) NSInteger apiVersion;
@property (nonatomic, strong) NSString * apiKey;
@property (nonatomic, strong) NSString * deviceId;
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * uniqueId;
@property (nonatomic, strong) NSString * applicationLanguage;

@property (nonatomic) BOOL bluetoothEnable;


#pragma mark - Request

- (void) requestDeviceId;

- (void) getAPIkey:(NSString*)apiKey andUserId:(NSString*)userID;

- (void) requestServices;

- (void) confirmLocalization;
- (void) confirmNotification;


-(void)requestPOSTWithUrl:(NSString *)stringURL andDictionaryPost:(NSDictionary *)dictionaryPost
                  success:(void (^)(NSURLSessionDataTask * sessionDataTask, id response))success
                  failure:(void (^)(NSURLSessionDataTask * sessionDataTask, NSString *error))failure;

-(void)requestGETWithUrl:(NSString *)stringURL andDictionaryPost:(NSDictionary *)dictionaryPost
                 success:(void (^)(NSURLSessionDataTask * sessionDataTask, id response))success
                 failure:(void (^)(NSURLSessionDataTask * sessionDataTask, NSString *error))failure;

-(void)requestPUTWithUrl:(NSString *)stringURL andDictionaryPost:(NSDictionary *)dictionaryPost
                 success:(void (^)(NSURLSessionDataTask * sessionDataTask, id response))success
                 failure:(void (^)(NSURLSessionDataTask * sessionDataTask, NSString *error))failure;




@end
