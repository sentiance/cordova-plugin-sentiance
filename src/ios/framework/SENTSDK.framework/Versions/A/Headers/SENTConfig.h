//
//  SENTConfig.h
//  SENTSDK
//
//  Created by Gustavo Nascimento on 28/07/17.
//  Copyright © 2018 Sentiance. All rights reserved.
//

@import Foundation;
@class SENTSDKStatus;

@interface SENTConfig : NSObject 

@property (nonatomic, strong) NSString *appId;
@property (nonatomic, strong) NSString *secret;
@property (nonatomic, assign) BOOL isTriggeredTrip;
@property (nonatomic, strong) NSDictionary *launchOptions;
@property (nonatomic, copy) void (^didReceiveSdkStatusUpdate)(SENTSDKStatus* issue);

- (id)initWithAppId:(NSString *)appId secret:(NSString *)secret launchOptions:(NSDictionary *)launchOptions;
- (BOOL)isValidConfig;

@end
