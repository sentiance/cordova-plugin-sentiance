//
//  SENTSDKStatus.h
//  SENTSDK
//
//  Created by Gustavo Nascimento on 12/15/16.
//  Copyright © 2018 Sentiance. All rights reserved.
//

@import Foundation;
#import "SENTPublicDefinitions.h"

typedef NS_ENUM(NSUInteger, SENTQuotaStatus) {
    SENTQuotaStatusOK = 1,
    SENTQuotaStatusWarning = 2,
    SENTQuotaStatusExceeded = 3
};

/*
 * SENTSDKStatus interface declaration
 */
@interface SENTSDKStatus : NSObject

@property(nonatomic, assign) BOOL canDetect;        // true only if detections are possible (i.e. there are no issues blocking detection)
@property(nonatomic, assign) BOOL isRemoteEnabled;        // true if kill-switch is not enabled
@property(nonatomic, assign) BOOL isLocationPermGranted;        // true if location permissions are granted. If false, canDetect will be false.
@property(nonatomic, assign) BOOL isBgAccessPermGranted;        // true if SDK is allowed to run in the background (iOS)
@property(nonatomic, assign) BOOL isAccelPresent;        // true if device has an accelerometer
@property(nonatomic, assign) BOOL isGyroPresent;        // true if device has a gyroscope
@property(nonatomic, assign) BOOL isGpsPresent;          // true if device has a GPS unit
@property(nonatomic, assign) SENTQuotaStatus wifiQuotaStatus; // indicates WiFi quota state
@property(nonatomic, assign) SENTQuotaStatus mobileQuotaStatus; // indicates mobile data quota state
@property(nonatomic, assign) SENTQuotaStatus diskQuotaStatus; // indicates disk quota state
@property(nonatomic, assign) SENTStartStatus startStatus; // indicates the status of the SDK

- (BOOL) isEqualToSDKStatus:(SENTSDKStatus*) sdkStatus;

@end
