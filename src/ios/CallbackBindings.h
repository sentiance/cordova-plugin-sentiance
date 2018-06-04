#import <SENTTransportDetectionSDK/SENTInitIssue.h>
#import <SENTTransportDetectionSDK/SENTSDKStatus.h>

@protocol CallbackBindings <NSObject>
@optional
- (void)setInitFinishedListener:(void (^)())success failure:(void (^)(SENTInitIssue issue))failure;
@optional
- (void)setStartFinishedListener:(void (^)(SENTSDKStatus* status))callback;
@optional
- (void)setOnSdkStatusUpdateHandler:(void (^)(SENTSDKStatus* status))callback;

@end