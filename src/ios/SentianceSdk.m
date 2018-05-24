#import "SentianceSdk.h"
#import "SentAppDelegate.h"

#import <SENTSDK/SENTSDK.h>
#import <SENTSDK/SENTSDKStatus.h>
#import <SENTSDK/SENTPublicDefinitions.h>


@implementation SentianceSdk {
    NSString* sdkStatusUpdateCallbackId;
    NSString* initFinishedCallbackId;
    NSString* startFinishedCallbackId;
}

- (void)pluginInitialize {
    // init
}

- (void) initFinishedCallback:(BOOL) success issue:(SENTInitIssue) issue {
    if (initFinishedCallbackId != nil) {
        CDVPluginResult* result;
        if (success) {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        } else {
            result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                       messageAsString:[self covertInitIssueToString:issue]];
        }
        
        [result setKeepCallbackAsBool:TRUE];
        [self.commandDelegate sendPluginResult:result callbackId:initFinishedCallbackId];
    }
}

- (void) sdkStatusUpdateCallback:(SENTSDKStatus*) status {
    if (sdkStatusUpdateCallbackId != nil) {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_OK
                                   messageAsDictionary:[self convertSdkStatusToDict:status]];
        [result setKeepCallbackAsBool:TRUE];
        [self.commandDelegate sendPluginResult:result callbackId:sdkStatusUpdateCallbackId];
    }
}

- (void) startFinishedCallback:(SENTSDKStatus*) status {
    if (sdkStatusUpdateCallbackId != nil) {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_OK
                                   messageAsDictionary:[self convertSdkStatusToDict:status]];
        [result setKeepCallbackAsBool:TRUE];
        [self.commandDelegate sendPluginResult:result callbackId:startFinishedCallbackId];
    }
}

- (void)init:(CDVInvokedUrlCommand*)command {
    NSString* appId = [command.arguments objectAtIndex:0];
    NSString* secret = [command.arguments objectAtIndex:1];

    if (appId == nil || secret == nil) {
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_ERROR
                                   messageAsString:@"INVALID_CREDENTIALS"];
        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
        return;
    }

    [self.commandDelegate runInBackground: ^{
        SENTConfig *config = [[SENTConfig alloc] initWithAppId:appId secret:secret launchOptions:@{}];
        [config setDidReceiveSdkStatusUpdate:^(SENTSDKStatus* status){
            [self sdkStatusUpdateCallback:status];
        }];

        [[self getSDK] initWithConfig:config success:^{
            [self initFinishedCallback:TRUE issue:SENTInitIssueServiceUnreachable];
        } failure:^(SENTInitIssue issue){
            [self initFinishedCallback:FALSE issue:issue];
        }];

    }];
}

- (void)setOnStatusUpdateHandler:(CDVInvokedUrlCommand*)command {
    sdkStatusUpdateCallbackId = [command callbackId];
    
    if ([((SentAppDelegate*)[super appDelegate]) respondsToSelector:@selector(setOnSdkStatusUpdateHandler:)]) {
        // Only relevant for when init is called via the AppDelegate
        [((SentAppDelegate*)[super appDelegate]) setOnSdkStatusUpdateHandler:^(SENTSDKStatus* status) {
            [self sdkStatusUpdateCallback:status];
        }];
    } else
        NSLog(@"delegate doesn't respond to setOnSdkStatusUpdateHandler");
}

- (void)setInitFinishedHandler:(CDVInvokedUrlCommand*)command {
    initFinishedCallbackId = [command callbackId];
    
    if ([((SentAppDelegate*)[super appDelegate]) respondsToSelector:@selector(setInitFinishedListener:failure:)]) {
        // Only relevant for when init is called via the AppDelegate
        [((SentAppDelegate*)[super appDelegate]) setInitFinishedListener:^{
            [self initFinishedCallback:TRUE issue:SENTInitIssueServiceUnreachable];
        } failure:^(SENTInitIssue issue){
            [self initFinishedCallback:FALSE issue:issue];
        }];
    } else
        NSLog(@"delegate doesn't respond to setInitFinishedListener");
}

- (void)setStartFinishedHandler:(CDVInvokedUrlCommand*)command {
    startFinishedCallbackId = [command callbackId];

    if ([((SentAppDelegate*)[super appDelegate]) respondsToSelector:@selector(setStartFinishedListener:)]) {
        // Only relevant for when init is called via the AppDelegate
        [((SentAppDelegate*)[super appDelegate]) setStartFinishedListener:^(SENTSDKStatus* status) {
            [self startFinishedCallback:status];
        }];
    } else
        NSLog(@"delegate doesn't respond to setStartFinishedListener");
}

- (void)start:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        [self.commandDelegate runInBackground: ^{
            [[self getSDK] start:^(SENTSDKStatus* status) {
                [self startFinishedCallback:status];
            }];
        }];
    }];
}

- (void)stop:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        [[self getSDK] stop];
        CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)isInitialized:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_OK
                                   messageAsString: [[self getSDK] isInitialised] ? @"true" : @"false"];

        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)getSdkStatus:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsDictionary:[self convertSdkStatusToDict:[[self getSDK] getSdkStatus]]];

        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)getVersion:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_OK
                                   messageAsString:[[self getSDK] getVersion]];

        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)getUserId:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* result = [CDVPluginResult
                                   resultWithStatus:CDVCommandStatus_OK
                                   messageAsString:[[self getSDK] getUserId]];

        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)getUserAccessToken:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];

    [self.commandDelegate runInBackground: ^{
        [[self getSDK] getUserAccessToken:^(NSString* token) {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK
                                        messageAsDictionary:[self convertTokenToDict:token]];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        } failure:^() {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR
                                        messageAsString:@"Couldn't get access token"];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }];
    }];
}

- (void)addUserMetadataField:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    NSString* label = [command.arguments objectAtIndex:0];
    NSString* value = [command.arguments objectAtIndex:1];

    if (label == nil || value == nil) {
        CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        return;
    }

    [self.commandDelegate runInBackground: ^{
        @try {
            [[self getSDK] addUserMetadataField:label value:value];
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        } @catch (NSException *exception) {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
    }];
}

- (void)removeUserMetadataField:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    NSString* label = [command.arguments objectAtIndex:0];

    if (label == nil) {
        CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        return;
    }

    [self.commandDelegate runInBackground: ^{
        @try {
            [[self getSDK] removeUserMetadataField:label];
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        } @catch (NSException *exception) {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
    }];
}

- (void)addUserMetadataFields:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    NSDictionary* metadata = [command.arguments objectAtIndex:0];

    if (metadata == nil) {
        CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        return;
    }

    [self.commandDelegate runInBackground: ^{
        @try {
            [[self getSDK] addUserMetadataFields:metadata];
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        } @catch (NSException *exception) {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
    }];
}

- (void)startTrip:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    NSDictionary* metadata = [command.arguments objectAtIndex:0];
    NSNumber* hint = [command.arguments objectAtIndex:1];
    SENTTransportMode mode = [hint intValue] == -1 ? SENTTransportModeUnknown : (SENTTransportMode)hint;

    [self.commandDelegate runInBackground: ^{
        @try {
            [[self getSDK] startTrip:metadata transportModeHint:mode success:^{
                CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:result callbackId:callbackId];
            } failure:^(SENTSDKStatus *status) {
                CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:result callbackId:callbackId];
            }];
        } @catch (NSException *exception) {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
    }];
}

- (void)stopTrip:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    [self.commandDelegate runInBackground: ^{
        @try {
            [[self getSDK] stopTrip:^{
                CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK];
                [self.commandDelegate sendPluginResult:result callbackId:callbackId];
            } failure:^(SENTSDKStatus *status) {
                CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
                [self.commandDelegate sendPluginResult:result callbackId:callbackId];
            }];
        } @catch (NSException *exception) {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
    }];
}

- (void)setTripTimeoutListener:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        [[self getSDK] setTripTimeOutListener:^{
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK];
            [result setKeepCallbackAsBool:TRUE];
            [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
        }];
    }];
}

- (void)isTripOngoing:(CDVInvokedUrlCommand*)command {
    SENTTripType tripType = [[command.arguments objectAtIndex:0] integerValue];
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK
                                        messageAsString: [[self getSDK] isTripOngoing:tripType] ? @"true" : @"false"];
        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)submitDetections:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        [[self getSDK] submitDetections:^{
            CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
        } failure: ^{
            CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                          messageAsString:@"Couldn't submit all detections"];
            [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
        }];
    }];
}

- (void)getWiFiQuotaLimit:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
            messageAsNSUInteger:[[self getSDK] getWifiQuotaLimit]];
        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)getWiFiQuotaUsage:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
            messageAsNSUInteger:[[self getSDK] getWiFiQuotaUsage]];
        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)getMobileQuotaLimit:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
            messageAsNSUInteger:[[self getSDK] getMobileQuotaLimit]];
        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)getMobileQuotaUsage:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
            messageAsNSUInteger:[[self getSDK] getMobileQuotaUsage]];
        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)getDiskQuotaLimit:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
            messageAsNSUInteger:[[self getSDK] getDiskQuotaLimit]];
        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)getDiskQuotaUsage:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK 
            messageAsNSUInteger:[[self getSDK] getDiskQuotaUsage]];
        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (SENTSDK*)getSDK {
    if (((SentAppDelegate*)[super appDelegate]).sentianceSDK == nil)
        ((SentAppDelegate*)[super appDelegate]).sentianceSDK = [SENTSDK sharedInstance];
    return ((SentAppDelegate*)[super appDelegate]).sentianceSDK;
}

- (NSMutableDictionary*)convertSdkStatusToDict:(SENTSDKStatus*) status {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

    if (status == nil)
        return dict;

    [dict setValue:[self convertStartStatusToString:status.startStatus] forKey:@"startStatus"];
    [dict setValue:status.canDetect?@"true":@"false" forKey:@"canDetect"];
    [dict setValue:status.isRemoteEnabled?@"true":@"false" forKey:@"isRemoteEnabled"];
    [dict setValue:status.isLocationPermGranted?@"true":@"false" forKey:@"isLocationPermGranted"];
    [dict setValue:status.isBgAccessPermGranted?@"true":@"false" forKey:@"isBgAccessPermGranted"];
    [dict setValue:status.isAccelPresent?@"true":@"false" forKey:@"isAccelPresent"];
    [dict setValue:status.isGyroPresent?@"true":@"false" forKey:@"isGyroPresent"];
    [dict setValue:status.isGpsPresent?@"true":@"false" forKey:@"isGpsPresent"];
    [dict setValue:[self convertQuotaStatusToString:status.wifiQuotaStatus] forKey:@"wifiQuotaStatus"];
    [dict setValue:[self convertQuotaStatusToString:status.mobileQuotaStatus] forKey:@"mobileQuotaStatus"];
    [dict setValue:[self convertQuotaStatusToString:status.diskQuotaStatus] forKey:@"diskQuotaStatus"];

    return dict;
}

- (NSMutableDictionary*)convertTokenToDict:(NSString*) token {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

    if (token == nil) {
        return dict;
    }

    [dict setValue:token forKey:@"tokenId"];    

    return dict;
}


- (NSString*)covertInitIssueToString:(SENTInitIssue) issue {
    if (issue == SENTInitIssueInvalidCredentials) {
        return @"INVALID_CREDENTIALS";
    } else if (issue == SENTInitIssueChangedCredentials) {
        return @"CHANGED_CREDENTIALS";
    } else if (issue == SENTInitIssueServiceUnreachable) {
        return @"SERVICE_UNREACHABLE";
    } else
        return @"";
}

- (NSString*)convertQuotaStatusToString:(SENTQuotaStatus) status {
    switch (status) {
        case SENTQuotaStatusOK:
            return @"OK";
        case SENTQuotaStatusWarning:
            return @"WARNING";
        case SENTQuotaStatusExceeded:
            return @"EXCEEDED";
    }
}

- (NSString*)convertStartStatusToString:(SENTStartStatus) status {
    switch (status) {
        case SENTStartStatusNotStarted:
            return @"NOT_STARTED";
        case SENTStartStatusPending:
            return @"PENDING";
        case SENTStartStatusStarted:
            return @"STARTED";
    }
}

@end
