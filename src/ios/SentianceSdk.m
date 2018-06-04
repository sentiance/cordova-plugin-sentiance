#import "SentianceSdk.h"
#import "SentAppDelegate.h"
#import <SENTTransportDetectionSDK/SENTSDK.h>
#import <SENTTransportDetectionSDK/SENTConfig.h>
#import <SENTTransportDetectionSDK/SENTInitIssue.h>
#import <SENTTransportDetectionSDK/SENTTrip.h>


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

- (void)stopAfter:(CDVInvokedUrlCommand*)command {
    int seconds = [[command.arguments objectAtIndex:0] intValue];

    [self.commandDelegate runInBackground: ^{
        [[self getSDK] stopAfter:seconds];
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
        [[self getSDK] getUserAccessToken:^(SENTToken* token) {
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
        [[self getSDK] addUserMetadataField:label value:value success:^() {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        } failure:^() {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }];
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
        [[self getSDK] removeUserMetadataField:label success:^() {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        } failure:^() {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }];
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
        [[self getSDK] addUserMetadataFields:metadata success:^() {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        } failure:^() {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }];
    }];
}

- (void)startTrip:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    NSDictionary* metadata = [command.arguments objectAtIndex:0];
    NSNumber* hint = [command.arguments objectAtIndex:1];
    SENTTransportMode mode = [hint intValue] == -1 ? SENTTransportModeUnknown : (SENTTransportMode)hint;

    [self.commandDelegate runInBackground: ^{
        @try {
            [[self getSDK] startTrip:metadata transportModeHint:mode];
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

- (void)stopTrip:(CDVInvokedUrlCommand*)command {
    NSString* callbackId = [command callbackId];
    [self.commandDelegate runInBackground: ^{
        @try {
            SENTTrip* tripObj = [[self getSDK] stopTrip];
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK
                                        messageAsDictionary:[self convertTripToDict:tripObj]];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        } @catch (NSException *exception) {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_ERROR];
            [self.commandDelegate sendPluginResult:result callbackId:callbackId];
        }
    }];
}

- (void)setTripTimeoutListener:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        [[self getSDK] setTripTimeOutListener:^(SENTTrip *trip) {
            CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK
                                        messageAsDictionary:[self convertTripToDict:trip]];
            [result setKeepCallbackAsBool:TRUE];
            [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
        }];
    }];
}

- (void)isTripOngoing:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK
                                        messageAsString: [[self getSDK] isTripOngoing] ? @"true" : @"false"];
        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)registerExternalEvent:(CDVInvokedUrlCommand*)command {
    NSNumber* typeInt = [command.arguments objectAtIndex:0];
    NSNumber* timestamp = [command.arguments objectAtIndex:1];
    NSString* Id = [command.arguments objectAtIndex:2];
    NSString* label = [command.arguments objectAtIndex:3];
    SENTExternalEventType type = (SENTExternalEventType)[typeInt intValue];

    [self.commandDelegate runInBackground: ^{
        [[self getSDK] registerExternalEvent:type timestamp:[timestamp longLongValue] id:Id label:label];
        CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)deregisterExternalEvent:(CDVInvokedUrlCommand*)command {
    NSNumber* typeInt = [command.arguments objectAtIndex:0];
    NSNumber* timestamp = [command.arguments objectAtIndex:1];
    NSString* Id = [command.arguments objectAtIndex:2];
    NSString* label = [command.arguments objectAtIndex:3];
    SENTExternalEventType type = (SENTExternalEventType)[typeInt intValue];

    [self.commandDelegate runInBackground: ^{
        [[self getSDK] deregisterExternalEvent:type timestamp:[timestamp longLongValue] id:Id label:label];
        CDVPluginResult* result = [CDVPluginResult
                                        resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:result callbackId:[command callbackId]];
    }];
}

- (void)submitDetections:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        [[self getSDK] submitDetections:^(BOOL status, NSError* error) {
            CDVPluginResult* result;
            if (status) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            } else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                          messageAsString:@"Couldn't submit all detections"];
            }
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

- (void)getWiFiLastSeenTimestamp:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground: ^{
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
            messageAsNSUInteger:[[self getSDK] getWiFiLastSeenTimestamp]];
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

- (NSMutableDictionary*)convertTokenToDict:(SENTToken*) token {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

    if (token == nil)
        return dict;

    NSTimeInterval interval = [token.expiryDate timeIntervalSince1970];
    NSInteger time = interval * 1000;

    [dict setValue:token.tokenId forKey:@"tokenId"];
    [dict setValue:[NSNumber numberWithLongLong:(long)time] forKey:@"expiryDate"];

    return dict;
}

- (NSMutableDictionary*)convertTripToDict:(SENTTrip*) trip {
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];

    if (trip == nil)
        return dict;

    [dict setValue:trip.tripId forKey:@"tripId"];
    [dict setValue:[NSNumber numberWithLongLong:trip.start] forKey:@"start"];
    [dict setValue:[NSNumber numberWithLongLong:trip.stop] forKey:@"stop"];
    [dict setValue:[NSNumber numberWithLongLong:trip.distance] forKey:@"distance"];
    [dict setValue:trip.pWaypointsArray forKey:@"waypoints"];

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
