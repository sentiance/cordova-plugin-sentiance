#import "SentAppDelegate.h"
#import "MainViewController.h"

@implementation SentAppDelegate {

    void (^initSuccessCallback)(void);
    void (^initFailureCallback)(SENTInitIssue issue);
    void (^startCallback)(SENTSDKStatus*);
    void (^sdkStatusUpdateCallback)(SENTSDKStatus*);
    BOOL startFinished;
    InitState initState;
    SENTInitIssue initIssue;
    SENTSDKStatus* sdkStatus;
}

-(NSString*)getAppID {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSString*)getSecret {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(BOOL)isAutostartEnabled {
    return TRUE;
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    self.sentianceSDK = [SENTSDK sharedInstance];
    NSString* appId = [self getAppID];
    NSString* secret = [self getSecret];

    if (!appId || [appId length] == 0 || secret == nil || [secret length] == 0) {
      return [super application:application didFinishLaunchingWithOptions:launchOptions];
    }

    SENTConfig *config = [[SENTConfig alloc] initWithAppId:appId secret:secret launchOptions:@{}];
    [config setDidReceiveSdkStatusUpdate:^(SENTSDKStatus* status){
        if (sdkStatusUpdateCallback != nil)
            sdkStatusUpdateCallback(status);
    }];

    void (^initSuccessBlock)(void) = ^{
        initState = STATE_SUCCESS;

        if (initSuccessCallback != nil)
            initSuccessCallback();

        if ([self isAutostartEnabled]) {
            [self.sentianceSDK start: ^(SENTSDKStatus* status) {
                startFinished = TRUE;
                sdkStatus = status;

                if (startCallback != nil)
                    startCallback(status);
            }];
        }

    };
    void (^initFailureBlock)(SENTInitIssue) = ^(SENTInitIssue issue){
        initState = STATE_FAILED;
        initIssue = issue;

        if (initFailureCallback != nil)
            initFailureCallback(issue);
    };

    [self.sentianceSDK initWithConfig:config success:initSuccessBlock failure:initFailureBlock];
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)setInitFinishedListener:(void (^)())success failure:(void (^)(SENTInitIssue issue))failure
{
    initSuccessCallback = success;
    initFailureCallback = failure;

    if (initState != STATE_NOT_INITIALIZED) {
        if (initState == STATE_SUCCESS && initSuccessCallback != nil)
            initSuccessCallback();
        else if (initState == STATE_FAILED && initFailureCallback != nil) {
            initFailureCallback(initIssue);
        }
    }
}

- (void)setStartFinishedListener:(void (^)(SENTSDKStatus* status))callback;
{
    startCallback = callback;

    if (startFinished && startCallback != nil) {
        startCallback(sdkStatus);
    }
}

- (void)setOnSdkStatusUpdateHandler:(void (^)(SENTSDKStatus* status))callback;
{
    sdkStatusUpdateCallback = callback;
}

@end
