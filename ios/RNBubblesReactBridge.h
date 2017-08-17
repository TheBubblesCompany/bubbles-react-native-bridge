
#if __has_include("RCTBridgeModule.h")
#import "RCTBridgeModule.h"
#else
#import <React/RCTBridgeModule.h>
#endif

#import <React/RCTEventEmitter.h>
#import <Bubbles/Bubbles.h>

@interface RNBubblesReactBridge : RCTEventEmitter <RCTBridgeModule>

+ (RNBubblesReactBridge *) bubblesReactBridge;
-(void)log:(NSString*)log;
-(void)getVersion;
-(void)closeService:(RCTResponseSenderBlock)callback;
-(void)getBeaconsAround:(RCTResponseSenderBlock)callback;
-(void)getBluetoothState:(RCTResponseSenderBlock)callback;
-(void)getLocalizationPermissionState:(RCTResponseSenderBlock)callback;
-(void)getNotificationPermissionState:(RCTResponseSenderBlock)callback;
-(void)componentReady;
-(void)askForLocalizationPermission;
-(void)askForNotificationPermission;
-(void)getServices;
-(void)fetchServices;
-(void)openService:(NSString*)service_Id;
-(void)openBluetoothSettings;


@property (strong, nonatomic) NSMutableArray * beacons;
@property (strong, nonatomic) NSMutableArray * lastBeacons;

@end
  
