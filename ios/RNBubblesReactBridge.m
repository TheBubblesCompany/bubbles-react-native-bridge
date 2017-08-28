
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

RCT_EXPORT_METHOD(getVersion)
{
    [self sendEventWithName:@"getVersion" body:@{@"version": @"1.3.0"}];
}

RCT_EXPORT_METHOD(getBeaconsAround)
{
    BOOL foundBeacons;
    if (self.beacons.count > 0)
        foundBeacons = YES;
    else
        foundBeacons = NO;
    
    NSDictionary * dictionary = @{@"success" : [NSNumber numberWithBool:foundBeacons], @"beacons" : self.beacons};
    
    NSError * error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendEventWithName:@"getBeaconsAround" body:@{@"beaconsList":jsonString}];
    
}

RCT_EXPORT_METHOD(closeService)
{
    dispatch_async(dispatch_get_main_queue(),^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"closeService" object:nil];
    });
}

RCT_EXPORT_METHOD(getBluetoothState)
{
    NSString * bluetoothState;
    
    if (DATA.bluetoothEnable)
    {
        bluetoothState = @"true";
    }
    else
    {
        bluetoothState = @"false";
    }
    
    NSData *jsonData = [bluetoothState dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendEventWithName:@"getBluetoothState" body:@{@"isActivated":jsonString}];
    
}

RCT_EXPORT_METHOD(getLocalizationPermissionState)
{
    NSString * locState;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"localizationPermission"])
    {
        locState = @"false";
    }
    else
    {
        locState = @"true";
    }
    
    NSData *jsonData = [locState dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendEventWithName:@"getLocalizationPermissionState" body:@{@"isAuthorized":jsonString}];
}

RCT_EXPORT_METHOD(getNotificationPermissionState)
{
    NSString * notifState;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"notificationPermission"])
    {
        notifState = @"{\"is_authorized\":false}";
    }
    else
    {
        notifState = @"{\"is_authorized\":true}";
    }
    
    NSData *jsonData = [notifState dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString * jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendEventWithName:@"getNotificationPermissionState" body:@{@"isAuthorized":jsonString}];
}

RCT_EXPORT_METHOD(askForLocalizationPermission)
{
    NSLog(@"askForLocalizationPermission");
    
    [DATA.locationManager requestAlwaysAuthorization];
    
    if([DATA.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        [DATA.locationManager requestAlwaysAuthorization];
    
    NSDictionary * dictionary = @{@"success"    : [NSNumber numberWithBool:YES]};
    
    NSError * error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendEventWithName:@"getLocalizationPermissionState" body:@{@"isAuthorized":jsonString}];
}

RCT_EXPORT_METHOD(askForNotificationPermission)
{
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
    
    NSDictionary * dictionary = @{@"success"    : [NSNumber numberWithBool:YES]};
    
    NSError * error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    
    [self sendEventWithName:@"getNotificationPermissionState" body:@{@"isAuthorized":jsonString}];
}

RCT_EXPORT_METHOD(getServices)
{
    NSMutableDictionary * services = [[NSUserDefaults standardUserDefaults] objectForKey:@"servicesBridge"];
    
    NSMutableArray * service = [services objectForKey:@"service"];
    
    if (service)
    {
        NSDictionary * dictionary = @{@"success" : [NSNumber numberWithBool:YES], @"services" : service };
        
        NSError * error;
        NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [self sendEventWithName:@"getServices" body:@{@"success" : [NSNumber numberWithBool:YES], @"services" : jsonString }];
    }
    else
    {
        [self sendEventWithName:@"getServices" body:@{@"success" : [NSNumber numberWithBool:NO]}];
    }
}

RCT_EXPORT_METHOD(fetchServices)
{
    [DATA requestServices];
}

RCT_EXPORT_METHOD(openService:(NSString*)service_Id)
{
    
    NSLog(@"service_Id : %@", service_Id);
    
    NSMutableDictionary * services = [[NSUserDefaults standardUserDefaults] objectForKey:@"services"];
    
    BOOL flag = NO;
    if(services)
    {
        NSMutableDictionary * service = [services objectForKey:@"service"];
        
        for (NSMutableDictionary * srv in service) {
 
            if ([[srv objectForKey:@"id"] isEqualToString:service_Id])
            {
                flag = YES;
                
                break;
            }
        }
    }
    
    [[NSNotificationCenter defaultCenter]postNotificationName:@"openService" object:service_Id];

}

RCT_EXPORT_METHOD(openBluetoothSettings)
{
    
    NSLog(@"openBluetoothSettings");
    
    NSString *settingsUrl= @"App-Prefs:root=Bluetooth";
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(openURL:options:completionHandler:)]) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:settingsUrl] options:@{} completionHandler:^(BOOL success) {
            NSLog(@"URL opened");
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
             @"getVersion",
             @"getBluetoothState",
             @"getLocalizationPermissionState",
             @"getNotificationPermissionState",
             @"getBeaconsAround",
             @"askForLocalizationPermission",
             @"askForNotificationPermission",
             @"getServices",
             @"onServicesChange",
             @"fetchServices"];
}


-(instancetype)init
{
    self = [super init];
    if(self)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"bluetoothEnabled" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateBluetoothEnabled:) name:@"bluetoothEnabled" object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"bluetoothDisabled" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateBluetoothDisabled:) name:@"bluetoothDisabled" object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"locationEnabled" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(callHandlerOnLocalizationPermissionEnabled) name:@"locationEnabled" object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"locationDisabled" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(callHandlerOnLocalizationPermissionDisabled) name:@"locationDisabled" object:nil];
        
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
                        break;
                    }
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
        NSDictionary * dictionary = @{@"success" : [NSNumber numberWithBool:YES], @"services" : service};
        
        NSError * error;
        NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [self sendEventWithName:@"onServicesChange" body:@{@"success" : [NSNumber numberWithBool:YES], @"services" : jsonString }];
    }
    else
    {
        [self sendEventWithName:@"onServicesChange" body:@{@"success" : [NSNumber numberWithBool:NO]}];
    }
    
}

-(void)updateBluetoothEnabled:(NSNotification*)notification {
    
    [self callHandlerBluetoothStateChange:@"true"];
}

-(void)updateBluetoothDisabled:(NSNotification*)notification {
    
    [self callHandlerBluetoothStateChange:@"false"];
    
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
    
    if (_beacons.count > 0)
    {
        for (NSMutableDictionary * newBeacon in _beacons)
        {
            [self callHandlerWithBeacon: newBeacon];
            
        }
    }
}

-(void)callHandlerBluetoothStateChange:(NSString*)state
{
    
    NSString * jsonString;
    
    if ([state isEqualToString:@"true"])
    {
        jsonString = @"{\"isActivated\":true}";
    }
    else
    {
        jsonString = @"{\"isActivated\":false}";
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendEventWithName:@"onBluetoothStateChange" body:@{@"isActivated":json}];
}

-(void)callHandlerWithBeacon:(NSMutableDictionary *)beacon
{
    
    NSDictionary * dictionary = @{@"success" : [NSNumber numberWithBool:YES], @"beacon" : beacon};
    
    NSError * error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

-(void)callHandlerOnLocalizationPermissionEnabled
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"localizationDidChange" object:[NSNumber numberWithBool:YES]];
    
    NSDictionary * dictionary = @{@"success" : [NSNumber numberWithBool:YES]};
    
    NSError * error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendEventWithName:@"onLocalizationPermissionChange" body:@{@"isAuthorized":jsonString}];
}

-(void)callHandlerOnLocalizationPermissionDisabled
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"localizationDidChange" object:[NSNumber numberWithBool:NO]];
    
    
    NSDictionary * dictionary = @{@"success" : [NSNumber numberWithBool:NO]};
    
    NSError * error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendEventWithName:@"onLocalizationPermissionChange" body:@{@"isAuthorized":jsonString}];
}

-(void)callHandlerOnNotificationPermissionChange:(BOOL)success
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notificationDidChange" object:[NSNumber numberWithBool:success]];
    
    
    NSDictionary * dictionary = @{@"success" : [NSNumber numberWithBool:success]};
    
    NSError * error;
    NSData   *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [self sendEventWithName:@"onNotificationPermissionChange" body:@{@"isAuthorized":jsonString}];
    
}

@end

