#import <Cordova/CDVViewController.h>
#import <Cordova/CDVAppDelegate.h>
#import <SENTTransportDetectionSDK/SENTSDK.h>
#import <SENTTransportDetectionSDK/SENTConfig.h>
#import "CallbackBindings.h"

@interface SentAppDelegate : CDVAppDelegate <CallbackBindings> {}
@property SENTSDK* sentianceSDK;

typedef enum initState
{
    STATE_NOT_INITIALIZED,
    STATE_SUCCESS,
    STATE_FAILED
} InitState;

-(NSString*)getAppID;
-(NSString*)getSecret;
-(BOOL)isAutostartEnabled;
@end
