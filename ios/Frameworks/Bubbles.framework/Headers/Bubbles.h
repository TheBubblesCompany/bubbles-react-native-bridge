//
//  Bubbles.h
//  bubblesFramework
//
//  Created by Pierre RACINE on 08/10/2015.
//  Copyright © 2015 AbsolutLabs. All rights reserved.
//  @version 1.0


#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "BubbleServiceView.h"

@protocol BubblesDelegate <NSObject>

@optional

/****************** SERVICES ******************/
- (void) onServicesListLoaded: (NSDictionary*) services;
- (void) onServicesListFailed;
- (void) onHybridServiceReady;
- (void) onHybridServiceTimeout;
- (void) onClickNotification:(NSDictionary*)infos;
- (void) onOpenService:(NSString*)serviceId;
- (void) onCloseService;
/**********************************************/

-(void) bubblesDidReceiveNotification : (NSDictionary *) infos;
-(void) onNetworkAvailable:(BOOL)status;

@end


@interface Bubbles : NSObject

@property (nonatomic, weak) id<BubblesDelegate> delegate;

+ (void)initWithAPIKey:(NSString *)APIKey andUserId:(NSString*)userID andForceLocalizationPermission:(BOOL)forceLocalizationPermission andForceNotificationPermission:(BOOL)forceNotificationPermission andApplication:(UIApplication *)application;
+ (void)updateUserId:(NSString *)userId;
+ (void)setDebugLogEnabled:(BOOL)enable;
+ (void)didReceiveLocalNotification:(NSDictionary *)userInfo withApplicationState:(UIApplicationState)appState;
+ (void)setDelegate:(id<BubblesDelegate>)delegate;
+ (void)didEnterBackground;
+ (void)didBecomeActive;

/****************** SERVICES ******************/
+ (void) getServices;
+ (void) loadServiceWithId:(NSString*)serviceId;
+ (BubbleServiceView *) getWebviewService;
+ (void)releaseService;
/**********************************************/







@end
