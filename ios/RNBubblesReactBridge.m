
#import "RNBubblesReactBridge.h"

@implementation RNBubblesReactBridge

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(getVersion)
{
    NSLog(@"Test getVersion");
    [self sendEventWithName:@"getVersion" body:@{@"version": @"1.3.0"}];
}

- (NSArray<NSString *> *)supportedEvents
{
    return @[@"getVersion"];
}

@end
