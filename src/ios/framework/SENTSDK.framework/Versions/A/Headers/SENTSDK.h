//
//  SENTSDK.h
//  SENTSDK
//
//  Created by Emu on 28/07/2017.
//  Copyright © 2018 Sentiance. All rights reserved.
//

@import Foundation;

#import "SENTPublicDefinitions.h"
#import "SENTConfig.h"
#import "SENTSDKStatus.h"

extern NSString * const SENTSDKVersion;

@interface SENTSDK : NSObject

/**
 Method to call the shared instance of the SDK.
 */
+ (instancetype) sharedInstance;


/**
 SDK intialization method. It sets up the modules internally and handles user authentication.
 
 @param config The configuration used to authenticate the user.
 @param success The success block called when init succeeded.
 @param failure The failure block called when init failed. It takes a SENTInitIssue issue indicating the reason of the failure.
 @warning Init should only be called once, unless initialisation fails.
 */
- (void) initWithConfig: (SENTConfig *) config success:(void (^)(void))success failure:(void (^)(SENTInitIssue issue))failure;


/**
 Start the SDK.
 
 @param completion The completion block called when the SDK has started. SENTSDKStatus object indicates any issue that occured when the SDK started.
 @warning start should be called only after the SDK has been successfully initialised.
 */
- (void) start: (void (^)(SENTSDKStatus* status))completion;


/**
 Stop the SDK.
 */
- (void) stop;


/**
 Returns the user ID.
 */
- (NSString *) getUserId;

/**
 Returns the users Access Token if the user is authenticated
 */
- (void) getUserAccessToken:(void (^)(NSString *token))success failure:(void (^)(void))failure;

/**
 Interface method to set metadata for user.
 Metadata is any additional data that enclosing app is willing to set for this user/app combination
 This metadata could contain vital information related to procesing wrt to the enclosing app.

@param label Field name for the new entry.
@param value Value for the new entry.

*/
- (void) addUserMetadataField: (NSString*) label value:(NSString*) value;

/**
 Interface method to set metadata for user.
 Metadata is any additional data that enclosing app is willing to set for this user/app combination
 This metadata could contain vital information related to procesing wrt to the enclosing app.

 @param metadata key value pair data from enclosing app, could have any structure as long as it can be contained in a dictionary.

 */
- (void) addUserMetadataFields: (NSDictionary *) metadata;

/**
 Method to remove user data field to the sdk metadata (locally as well as on backend).

 @param label Field name for the new entry.

 */
- (void) removeUserMetadataField:(NSString*)label;

/**
 Start a Trip manually
 */
- (void)startTrip:(NSDictionary*)metadata transportModeHint:(SENTTransportMode)mode success:(void (^)(void))success failure:(void (^)(SENTSDKStatus* status))failure;


/**
 Stop a trip.
 */
- (void) stopTrip:(void (^)(void))success failure:(void (^)(SENTSDKStatus* status))failure;

/**
 Set a trip timeout block
 */
- (void) setTripTimeOutListener: (void (^)(void)) tripDidTimeOut;


/**
 Interface method to check if trip is in progress or not.
 */
- (BOOL) isTripOngoing:(SENTTripType)tripType;

/**
 Submits all the pending detections  to backend, without considering any quota related updates and returns the status of these submissions via a callback to the enclosing app.

 @param success Success block which is to be called when forced submission completes.
 @param failure Failure block which is to be called when forced submission completes.

 */
- (void) submitDetections:(void (^)(void))success failure:(void (^)(void))failure;

/**
 Return true if sdk has ever initialized successfully or not
 */
- (BOOL) isInitialised;
/**
 Get SDK status information
 */
- (SENTSDKStatus*) getSdkStatus;
/**
 Get SDK version
 */
- (NSString *) getVersion;
/**
 Get SDK WiFi quota limit
 */
- (long) getWifiQuotaLimit;
/**
 Get SDK WiFi quota usage
 */
- (long) getWiFiQuotaUsage;
/**
 Get SDK mobile data quota limit
 */
- (long) getMobileQuotaLimit;
/**
 Get SDK mobile data quota usage
 */
- (long) getMobileQuotaUsage;
/**
 Get SDK disk quota limit
 */
- (long) getDiskQuotaLimit;
/**
 Get SDK disk quota usage
 */
- (long) getDiskQuotaUsage;

@end
