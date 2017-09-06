
#import "RNBubblesReactBridge.h"
#import <React/RCTLog.h>
#import <Bubbles/Bubbles.h>
#import <Bubbles/DataAccess.h>
#import <CoreLocation/CoreLocation.h>
#import <UserNotifications/UserNotifications.h>

@implementation RNBubblesReactBridge

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(log:(NSString *)log)
{
    NSLog(@"Bridge Log : %@", log);
}

RCT_EXPORT_METHOD(componentReady)
{
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"componentReady" object:nil];
    });
}

RCT_REMAP_METHOD(getVersion,
                 getVersionResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    RCTLogInfo(@"Ask getVersion");
    resolve(@"1.0.0");
}

RCT_REMAP_METHOD(getApplicationId,
                 getApplicationIdResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    RCTLogInfo(@"Ask getApplicationId");
    
    NSDictionary * dictionary = @{@"applicationId" : DATA.apiKey};
    
    NSError * error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    resolve(jsonString);
}

RCT_REMAP_METHOD(getDeviceId,
                 getDeviceIdResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    RCTLogInfo(@"Ask getDeviceId");
    
    NSDictionary * dictionary = @{@"deviceId" : DATA.uniqueId};
    
    NSError * error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    resolve(jsonString);
}

RCT_REMAP_METHOD(getUniqueDeviceId,
                 getUniqueDeviceIdResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    RCTLogInfo(@"Ask getUniqueDeviceId");
    
    NSDictionary * dictionary = @{@"isAuthorized" : @YES, @"uniqueDeviceId" : DATA.uniqueId};
    
    NSError * error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    resolve(jsonString);
}

RCT_REMAP_METHOD(getUserId,
                 getUserIdResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    RCTLogInfo(@"Ask getUserId");
    
    NSDictionary * dictionary = @{@"userId" : DATA.userId};
    
    NSError * error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    resolve(jsonString);
}

RCT_REMAP_METHOD(getBeaconsAround,
                 getBeaconsAroundResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    RCTLogInfo(@"Ask getBeaconsAround");
    NSDictionary * dictionary = @{@"beacons" : _beacons};
    
    NSError * error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    resolve(jsonString);
}

RCT_REMAP_METHOD(getLocalizationPermissionState,
                 getLocalizationPermissionStateResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    NSNumber *isAuthorizedField = [[NSUserDefaults standardUserDefaults] objectForKey:@"localizationPermission"];
    
    if (isAuthorizedField != nil && [isAuthorizedField boolValue] == NO)
    {
        NSError *error = [[NSError alloc] initWithDomain:NSMachErrorDomain
                                                    code:1 userInfo:nil];
        reject(@"PERMISSION_REJECTED", @"Permission rejected", error);
    }
    else
    {
        NSNumber *isAuthorized = [NSNumber numberWithBool:[isAuthorizedField boolValue]];
        NSDictionary *dictionary = @{@"isAuthorized": isAuthorized};
        
        NSError  *error;
        NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        resolve(jsonString);
    }
}

RCT_REMAP_METHOD(getNotificationPermissionState,
                 getNotificationPermissionStateResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    NSNumber *isAuthorizedField = [[NSUserDefaults standardUserDefaults] objectForKey:@"notificationPermission"];
    RCTLogInfo(@"getNotificationPermissionState:\n isAuthorizedField %@\n [isAuthorizedField boolValue] %i", isAuthorizedField, [isAuthorizedField boolValue]);
    if (isAuthorizedField != nil && [isAuthorizedField boolValue] == NO)
    {
        NSError *error = [[NSError alloc] initWithDomain:NSMachErrorDomain
                                                    code:1 userInfo:nil];
        reject(@"PERMISSION_REJECTED", @"Permission rejected", error);
    }
    else
    {
        NSNumber *isAuthorized = [NSNumber numberWithBool:[isAuthorizedField boolValue]];
        NSDictionary *dictionary = @{@"isAuthorized": isAuthorized};
        
        NSError  *error;
        NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        resolve(jsonString);
    }
}

RCT_EXPORT_METHOD(askForLocalizationPermission)
{
    RCTLogInfo(@"askForLocalizationPermission");
    [DATA.locationManager requestAlwaysAuthorization];
    
    if([DATA.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [DATA.locationManager requestAlwaysAuthorization];
}

RCT_EXPORT_METHOD(askForNotificationPermission)
{
    RCTLogInfo(@"askForNotificationPermission");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  if (!error) {
                                      
                                      if (DATA.debug)
                                          NSLog(@"request authorization succeeded!");
                                      
                                      if (granted)
                                      {
                                          [self callHandlerOnNotificationPermissionChange:YES];
                                          
                                          [[NSUserDefaults standardUserDefaults]setObject:@"true" forKey:@"notificationPermission"];
                                          [[NSUserDefaults standardUserDefaults]synchronize];
                                          
                                      }
                                      else
                                      {
                                          [self callHandlerOnNotificationPermissionChange:NO];
                                          
                                          [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"notificationPermission"];
                                          [[NSUserDefaults standardUserDefaults]synchronize];
                                      }
                                  }
                              }];
    });
}

RCT_REMAP_METHOD(getServices,
                  getServicesResolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSMutableDictionary *services = [[NSUserDefaults standardUserDefaults] objectForKey:@"servicesBridge"];
    
    NSMutableArray *service = [services objectForKey:@"service"];
    
    NSDictionary *dictionary = @{@"services" : service };
    
    NSError  *error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    resolve(jsonString);
}

RCT_EXPORT_METHOD(closeService)
{
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"closeService" object:nil];
    });
}

RCT_REMAP_METHOD(getBluetoothState,
                 getBluetoothStateResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    NSNumber     *isActivated = [NSNumber numberWithBool:DATA.bluetoothEnable];
    NSDictionary *dictionary = @{@"isActivated": isActivated};
    
    NSError  *error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    resolve(jsonString);
}

RCT_EXPORT_METHOD(fetchServices)
{
    [DATA requestServices];
}

RCT_EXPORT_METHOD(openService: (NSString *)service_Id
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"openService: %@", service_Id);
    NSMutableDictionary *services = [[NSUserDefaults standardUserDefaults] objectForKey:@"services"];
    
    BOOL flag = NO;
    if(services)
    {
        NSMutableDictionary *service = [services objectForKey:@"service"];
        
        for (NSMutableDictionary *srv in service) {
 
            if ([[srv objectForKey:@"id"] isEqualToString:service_Id])
            {
                flag = YES;
                
                break;
            }
        }
    }
    
    if (flag) {
        resolve(@"");
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"openService" object:service_Id];
    } else {
        NSError *error = [[NSError alloc] initWithDomain:NSMachErrorDomain
                                                    code:1 userInfo:nil];
        reject(@"UNKNOWN_SERVICE", @"unknown service", error);
    }
}

RCT_REMAP_METHOD(openBluetoothSettings,
                 openBluetoothSettingsResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *settingsUrl= @"App-Prefs:root=Bluetooth";
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:settingsUrl] options:@{} completionHandler:^(BOOL success) {
            NSLog(@"URL opened");
            
            if (success) {
                resolve(@"");
            } else {
                NSError *error = [[NSError alloc] initWithDomain:NSMachErrorDomain
                                                            code:1 userInfo:nil];
                reject(@"OPENING_SETTINGS_FAILED", @"Opening settings failed", error);
            }
        }];
    }
}





static RNBubblesReactBridge * _bubblesReactBridge;

+ (RNBubblesReactBridge *) bubblesReactBridge
{
    if(!_bubblesReactBridge)
        _bubblesReactBridge = [[RNBubblesReactBridge alloc]init];
    
    return _bubblesReactBridge;
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"onBluetoothStateChange",
             @"openService",
             @"onLocalizationPermissionChange",
             @"onNotificationPermissionChange",
             @"onSendUniqueId",
             @"getVersion",
             @"getBluetoothState",
             @"getLocalizationPermissionState",
             @"getNotificationPermissionState",
             @"getBeaconsAround",
             @"askForLocalizationPermission",
             @"askForNotificationPermission",
             @"getServices",
             @"onServicesChange",
             @"onBeaconChange",
             @"fetchServices"];
}


-(instancetype)init
{
    self = [super init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"bluetoothEnabled" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateBluetoothEnabled) name:@"bluetoothEnabled" object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"bluetoothDisabled" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateBluetoothDisabled) name:@"bluetoothDisabled" object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"locationEnabled" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocalizationPermissionEnabled) name:@"locationEnabled" object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"locationDisabled" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLocalizationPermissionDisabled) name:@"locationDisabled" object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onChangeBeacons" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateBeacons:) name:@"onChangeBeacons" object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"onServicesChange" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(callHandlerOnServicesChange) name:@"onServicesChange" object:nil];
        
        
        _beacons = [[NSMutableArray alloc] init];
        
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastBeacons"];
        NSMutableArray * arrlastBeacons = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        
        NSMutableArray * lastBeaconsTemp = [NSKeyedUnarchiver unarchiveObjectWithData:
                                            [NSKeyedArchiver archivedDataWithRootObject:arrlastBeacons]];
        
        for (NSMutableArray * arrayBeacon in lastBeaconsTemp)
        {
            CLBeacon * beacon = [arrayBeacon objectAtIndex:0];
            NSMutableDictionary * dictBeacon = [arrayBeacon objectAtIndex:1];
            
            if (![[dictBeacon objectForKey:@"minor"] isEqualToString:@"0"] &&
                ![[dictBeacon objectForKey:@"major"] isEqualToString:@"0"] ) {
                
                if (![[dictBeacon objectForKey:@"event"] isEqualToString:@"EXIT"])
                {
                    
                    NSString * beaconUUID = beacon.proximityUUID.UUIDString;
                    NSString* UUIDstr = [beaconUUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    
                    NSMutableDictionary * newBeacon = [NSMutableDictionary new];
                    
                    NSString * beaconMinor = [dictBeacon objectForKey:@"minor"];
                    NSString * beaconMajor = [dictBeacon objectForKey:@"major"];
                    
                    if (beaconMinor.length == 1)
                        beaconMinor = [NSString stringWithFormat:@"000%@", beaconMinor];
                    else if (beaconMinor.length == 2)
                        beaconMinor = [NSString stringWithFormat:@"00%@", beaconMinor];
                    else if (beaconMinor.length == 3)
                        beaconMinor = [NSString stringWithFormat:@"0%@", beaconMinor];
                    
                    if (beaconMajor.length == 1)
                        beaconMajor = [NSString stringWithFormat:@"000%@", beaconMajor];
                    else if (beaconMajor.length == 2)
                        beaconMajor = [NSString stringWithFormat:@"00%@", beaconMajor];
                    else if (beaconMajor.length == 3)
                        beaconMajor = [NSString stringWithFormat:@"0%@", beaconMajor];
                    
                    [newBeacon setObject:beaconMinor forKey:@"minor"];
                    [newBeacon setObject:beaconMajor forKey:@"major"];
                    [newBeacon setObject:[dictBeacon objectForKey:@"event"] forKey:@"event"];
                    [newBeacon setObject:UUIDstr forKey:@"uuid"];
                    
                    
                    [_beacons addObject:newBeacon];
                }
            }
        }
        
        _lastBeacons = [NSMutableArray new];
        _lastBeacons = [NSMutableArray arrayWithArray:_beacons];
        
    }
    
    return self;
    
}

-(void)updateBeacons:(NSNotification*)notification {
    
    [_beacons removeAllObjects];
    _beacons = [NSMutableArray new];
    
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastBeacons"];
    NSMutableArray * arrlastBeacons = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSMutableArray * lastBeaconsTemp = [NSKeyedUnarchiver unarchiveObjectWithData:
                                        [NSKeyedArchiver archivedDataWithRootObject:arrlastBeacons]];
    
    for (NSMutableArray * arrayBeacon in lastBeaconsTemp)
    {
        CLBeacon * beacon = [arrayBeacon objectAtIndex:0];
        NSMutableDictionary * dictBeacon = [arrayBeacon objectAtIndex:1];
        
        if (![[dictBeacon objectForKey:@"minor"] isEqualToString:@"0"] &&
            ![[dictBeacon objectForKey:@"major"] isEqualToString:@"0"] ) {
            
            
            if (![[dictBeacon objectForKey:@"event"] isEqualToString:@"EXIT"])
            {
                NSString * beaconUUID = beacon.proximityUUID.UUIDString;
                NSString* UUIDstr = [beaconUUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
                
                NSMutableDictionary * newBeacon = [NSMutableDictionary new];
                
                NSString * beaconMinor = [dictBeacon objectForKey:@"minor"];
                NSString * beaconMajor = [dictBeacon objectForKey:@"major"];
                
                if (beaconMinor.length == 1)
                    beaconMinor = [NSString stringWithFormat:@"000%@", beaconMinor];
                else if (beaconMinor.length == 2)
                    beaconMinor = [NSString stringWithFormat:@"00%@", beaconMinor];
                else if (beaconMinor.length == 3)
                    beaconMinor = [NSString stringWithFormat:@"0%@", beaconMinor];
                
                if (beaconMajor.length == 1)
                    beaconMajor = [NSString stringWithFormat:@"000%@", beaconMajor];
                else if (beaconMajor.length == 2)
                    beaconMajor = [NSString stringWithFormat:@"00%@", beaconMajor];
                else if (beaconMajor.length == 3)
                    beaconMajor = [NSString stringWithFormat:@"0%@", beaconMajor];
                
                [newBeacon setObject:beaconMinor forKey:@"minor"];
                [newBeacon setObject:beaconMajor forKey:@"major"];
                [newBeacon setObject:[dictBeacon objectForKey:@"event"] forKey:@"event"];
                [newBeacon setObject:UUIDstr forKey:@"uuid"];
                
                [_beacons addObject:newBeacon];
                
            }
        }
    }
    
    
    if (_beacons.count > 0)
    {
        for (NSMutableDictionary * newBeacon in _beacons)
        {
            BOOL contain = NO;
            id lastObj = [_lastBeacons lastObject];
            for (NSMutableDictionary * lastBeacon in _lastBeacons)
            {
                if ([[lastBeacon objectForKey:@"minor"] isEqualToString:[newBeacon objectForKey:@"minor"]] &&
                    [[lastBeacon objectForKey:@"major"] isEqualToString:[newBeacon objectForKey:@"major"]])
                {
                    contain = YES;
                    
                    if(![[lastBeacon objectForKey:@"event"] isEqualToString:[newBeacon objectForKey:@"event"]])
                    {
                        [self callHandlerWithBeacon: newBeacon];
                        break;
                    }
                }
                
                if ([lastObj isEqual:lastBeacon] && !contain) // ENTER
                {
                    [self callHandlerWithBeacon:newBeacon];
                }
            }
        }
        
        NSMutableArray * lastBeaconTemp = [_lastBeacons mutableCopy];
        for (NSMutableDictionary * lastBeacon in _lastBeacons)
        {
            for (NSMutableDictionary * newBeacon in _beacons)
            {
                if ([[lastBeacon objectForKey:@"minor"] isEqualToString:[newBeacon objectForKey:@"minor"]] &&
                    [[lastBeacon objectForKey:@"major"] isEqualToString:[newBeacon objectForKey:@"major"]])
                {
                    [lastBeaconTemp removeObject:lastBeacon];
                    
                    break;
                }
            }
        }
        
        for (NSMutableDictionary * beacon in lastBeaconTemp)
        {
            NSMutableDictionary * newBeacon = [beacon mutableCopy];
            [newBeacon setObject:@"EXIT" forKey:@"event"];
            [self callHandlerWithBeacon:newBeacon];
        }
    }
    
    _lastBeacons = [NSMutableArray new];
    _lastBeacons = [NSMutableArray arrayWithArray:_beacons];
    
}

-(void)callHandlerOnServicesChange
{
    NSMutableDictionary * services = [[NSUserDefaults standardUserDefaults] objectForKey:@"servicesBridge"];
    NSMutableArray * service = [services objectForKey:@"service"];
    
    if (service)
    {
        NSDictionary *dictionary = @{@"services" : service};
        
        NSError  *error;
        NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [self sendEventWithName:@"onServicesChange" body:jsonString];
    }
    
}

-(void)updateBluetoothEnabled {
    
    [self callHandlerBluetoothStateChange:YES];
}

-(void)updateBluetoothDisabled {
    
    [self callHandlerBluetoothStateChange:NO];
    
    [_beacons removeAllObjects];
    _beacons = [NSMutableArray new];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastBeacons"];
    NSMutableArray * arrlastBeacons = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    NSMutableArray * lastBeaconsTemp = [NSKeyedUnarchiver unarchiveObjectWithData:
                                        [NSKeyedArchiver archivedDataWithRootObject:arrlastBeacons]];
    
    for (NSMutableArray * arrayBeacon in lastBeaconsTemp)
    {
        CLBeacon * beacon = [arrayBeacon objectAtIndex:0];
        NSMutableDictionary * dictBeacon = [arrayBeacon objectAtIndex:1];
        
        if (![[dictBeacon objectForKey:@"minor"] isEqualToString:@"0"] &&
            ![[dictBeacon objectForKey:@"major"] isEqualToString:@"0"] ) {
            
            NSString * beaconUUID = beacon.proximityUUID.UUIDString;
            NSString* UUIDstr = [beaconUUID stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            NSMutableDictionary * newBeacon = [NSMutableDictionary new];
            
            NSString * beaconMinor = [dictBeacon objectForKey:@"minor"];
            NSString * beaconMajor = [dictBeacon objectForKey:@"major"];
            
            
            if (beaconMinor.length == 1)
                beaconMinor = [NSString stringWithFormat:@"000%@", beaconMinor];
            else if (beaconMinor.length == 2)
                beaconMinor = [NSString stringWithFormat:@"00%@", beaconMinor];
            else if (beaconMinor.length == 3)
                beaconMinor = [NSString stringWithFormat:@"0%@", beaconMinor];
            
            if (beaconMajor.length == 1)
                beaconMajor = [NSString stringWithFormat:@"000%@", beaconMajor];
            else if (beaconMajor.length == 2)
                beaconMajor = [NSString stringWithFormat:@"00%@", beaconMajor];
            else if (beaconMajor.length == 3)
                beaconMajor = [NSString stringWithFormat:@"0%@", beaconMajor];
            
            [newBeacon setObject:beaconMinor forKey:@"minor"];
            [newBeacon setObject:beaconMajor forKey:@"major"];
            [newBeacon setObject:@"EXIT" forKey:@"event"];
            [newBeacon setObject:UUIDstr forKey:@"uuid"];
            
            [_beacons addObject:newBeacon];
        }
    }
}

-(void)callHandlerWithBeacon:(NSMutableDictionary *)beacon
{
    NSLog(@"callHandlerWithBeacon: %@", beacon);
    NSError  *error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:beacon options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendEventWithName:@"onBeaconChange" body:jsonString];
}

-(void)callHandlerBluetoothStateChange:(BOOL)state
{
    NSNumber *isActivated = [NSNumber numberWithBool:state];
    NSDictionary *dictionary = @{@"isActivated": isActivated};
    
    NSError  *error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendEventWithName:@"onBluetoothStateChange" body:jsonString];
}

-(void)updateLocalizationPermissionEnabled {
    [self callHandlerOnLocalizationPermissionChange:YES];
}

-(void)updateLocalizationPermissionDisabled {
    [self callHandlerOnLocalizationPermissionChange:NO];
}

-(void)callHandlerOnLocalizationPermissionChange:(BOOL)state
{
    NSDictionary *dictionary;
    if (!state) {
        dictionary = [self generateEventErrorMessage:@"PERMISSION_REJECTED" message:@"Permission rejected"];
    }
    else {
        NSNumber *isAuthorized = [NSNumber numberWithBool:state];
        dictionary = @{@"isAuthorized": isAuthorized};
    }
    
    NSError  *error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendEventWithName:@"onLocalizationPermissionChange" body:jsonString];
}

-(void)callHandlerOnNotificationPermissionChange:(BOOL)state
{
    NSDictionary *dictionary;
    if (!state) {
        dictionary = [self generateEventErrorMessage:@"PERMISSION_REJECTED" message:@"Permission rejected"];
    }
    else {
        NSNumber *isAuthorized = [NSNumber numberWithBool:state];
        dictionary = @{@"isAuthorized": isAuthorized};
    }
    
    NSError  *error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendEventWithName:@"onNotificationPermissionChange" body:jsonString];
}

-(NSDictionary*)generateEventErrorMessage:(NSString*) code message:(NSString*) message {
    return @{@"error": @{@"code": code, @"message": message}};
}

@end

