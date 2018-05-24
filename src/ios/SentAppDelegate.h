#import <Cordova/CDVViewController.h>
#import <Cordova/CDVAppDelegate.h>
#import <SENTSDK/SENTSDK.h>
#import <SENTSDK/SENTConfig.h>
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
