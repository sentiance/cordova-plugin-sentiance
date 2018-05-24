#import <Cordova/CDV.h>
#import "CallbackBindings.h"

@interface SentianceSdk : CDVPlugin

- (void)init:(CDVInvokedUrlCommand*)command;
- (void)setOnStatusUpdateHandler:(CDVInvokedUrlCommand*)command;
- (void)setInitFinishedHandler:(CDVInvokedUrlCommand*)command;
- (void)setStartFinishedHandler:(CDVInvokedUrlCommand*)command;
- (void)start:(CDVInvokedUrlCommand*)command;
- (void)stop:(CDVInvokedUrlCommand*)command;
- (void)isInitialized:(CDVInvokedUrlCommand*)command;
- (void)getSdkStatus:(CDVInvokedUrlCommand*)command;
- (void)getVersion:(CDVInvokedUrlCommand*)command;
- (void)getUserId:(CDVInvokedUrlCommand*)command;
- (void)getUserAccessToken:(CDVInvokedUrlCommand*)command;
- (void)addUserMetadataField:(CDVInvokedUrlCommand*)command;
- (void)removeUserMetadataField:(CDVInvokedUrlCommand*)command;
- (void)addUserMetadataFields:(CDVInvokedUrlCommand*)command;
- (void)startTrip:(CDVInvokedUrlCommand*)command;
- (void)stopTrip:(CDVInvokedUrlCommand*)command;
- (void)setTripTimeoutListener:(CDVInvokedUrlCommand*)command;
- (void)isTripOngoing:(CDVInvokedUrlCommand*)command;
- (void)submitDetections:(CDVInvokedUrlCommand*)command;
- (void)getWiFiQuotaLimit:(CDVInvokedUrlCommand*)command;
- (void)getWiFiQuotaUsage:(CDVInvokedUrlCommand*)command;
- (void)getMobileQuotaLimit:(CDVInvokedUrlCommand*)command;
- (void)getMobileQuotaUsage:(CDVInvokedUrlCommand*)command;
- (void)getDiskQuotaLimit:(CDVInvokedUrlCommand*)command;
- (void)getDiskQuotaUsage:(CDVInvokedUrlCommand*)command;

@end
