//
//  SENTPublicDefinitions.h
//  SENTSDK
//
//  Created by Emu on 28/07/2017.
//  Copyright © 2018 Sentiance. All rights reserved.
//

#ifndef SENTPublicDefinitions_h
#define SENTPublicDefinitions_h

typedef NS_ENUM(NSUInteger, SENTInitIssue) {
    SENTInitIssueInvalidCredentials,
    SENTInitIssueChangedCredentials,
    SENTInitIssueServiceUnreachable
};

typedef NS_ENUM(NSUInteger, SENTStartStatus) {
    SENTStartStatusNotStarted,
    SENTStartStatusPending,
    SENTStartStatusStarted
};

typedef NS_ENUM(NSUInteger, SENTTransportMode) {
    SENTTransportModeUnknown = 1,
    SENTTransportModeCar = 2,
    SENTTransportModeBicycle = 3,
    SENTTransportModeOnFoot = 4,
    SENTTransportModeTrain = 5,
    SENTTransportModeTram = 6,
    SENTTransportModeBus = 7,
    SENTTransportModePlane = 8,
    SENTTransportModeBoat = 9,
    SENTTransportModeMetro = 10,
    SENTTransportModeRunning = 11
};

typedef NS_ENUM(NSUInteger, SENTExternalEventType) {
    SENTExternalEventTypeOther = 1,
    SENTExternalEventTypeBeacon = 2,
    SENTExternalEventTypeCustomRegion = 3
};

typedef NS_ENUM(NSUInteger, SENTTripType) {
    SENTTripTypeSDK = 1,
    SENTTripTypeExternal = 2
};

#endif /* SENTPublicDefinitions_h */
