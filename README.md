# Ionic/Cordova Sentiance SDK plugin
Ionic/Cordova plugin for Sentiance SDK.  
The plugin supports iOS and Android.


## Plugin repository
[https://github.com/sentiance/cordova-plugin-sentiance](https://github.com/sentiance/cordova-plugin-sentiance)



## Install
```
cordova plugin add cordova-plugin-sentiance
ionic plugin add cordova-plugin-sentiance
```

## Upgrade
```
ionic plugin remove com.sentiance.sdk.cordova
ionic plugin add cordova-plugin-sentiance
```

## Initialize SDK from app code
[More info on creating app credentials](https://developers.sentiance.com/docs)

```
$ionicPlatform.ready(function() {
     sentiance.setOnStatusUpdateHandler(function(status) {
      console.log(status);
    })
    // notification can be null if no notification is used
    var foregroundNotification = {
        mainActivityFullClassname: 'MainActivity',
        notificationTitle: '',
        notificationText: '$appName is building your profile',
        drawableIdentifier: 'icon'         
    }
    sentiance.init("APP_ID", "SECRET", foregroundNotification, function() { 
        console.log('Initialized');
        sentiance.getUserId(function(userId) {
          console.log('UserId: '+userId);
        }, function(err) {
          console.log('err: '+err);
        })
        sentiance.start(function(status) {
          console.log('SDK Started');
        })
      }, function(err) {
        console.log('err: '+err);
      }
    );
});
```



## iOS platform

### config.xml:
```
<preference name="deployment-target" value="8.0" />
```


### AppDelegate.h:
Include the framework
```
#import <SENTTransportDetectionSDK/SENTTransportDetectionSDK.h>
```
Add an instance variable
```
@property SENTTransportDetectionSDK* sentianceSdk;
```

Full example:
```
#import <SENTTransportDetectionSDK/SENTTransportDetectionSDK.h>

@interface AppDelegate : NSObject <UIApplicationDelegate>{}
// ...
@property SENTTransportDetectionSDK* sentianceSdk;
// ...
@end
```



### AppDelegate.m

Start the SDK before any other location managers
```
if( [SENTTransportDetectionSDK isAuthenticated] ) {
    self.sentianceSdk = [[SENTTransportDetectionSDK alloc] initWithConfigurationData:@{ @"launchOptions": launchOptions == nil ? @{} : launchOptions }]; 
}
```

Full example:
```
- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions {
    // ...
    if( [SENTTransportDetectionSDK isAuthenticated] ) {
        self.sentianceSdk = [[SENTTransportDetectionSDK alloc] initWithConfigurationData:@{ @"launchOptions": launchOptions == nil ? @{} : launchOptions }]; 
    }
   // ...
}
```


### Review native integration steps

Open [https://developers.sentiance.com/docs/sdk/ios/integration](https://developers.sentiance.com/docs/sdk/ios/integration) and make sure all integration steps are done.

### Build the application
```
ionic build ios
```


## Android platform

### Start the SDK when your Application is created
For this you need to override your default Android Application class.
Create `platforms/android/src/com/yourcompany/yourapp/MyApplication.java` or merge the logic with your current application class if you already have one.

Full example:
```
package com.yourcompany.yourapp;

import android.app.Application;
import com.sentiance.sdk.Sdk;
import com.sentiance.sdk.modules.config.SdkConfig;

public class MyApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        Sdk.getInstance(this).init(new SdkConfig());
    }
}
```


### AndroidManifest.xml
Make sure your `AndroidManifest.xml` uses your Application class.  

Add attribute to the application tag
```
android:name="com.yourcompany.yourapp.MyApplication"
```

Full example:
```
<application
  android:name="com.yourcompany.yourapp.MyApplication"
  >
  <!-- Activities -->
</application>
```


### Review native integration steps
Open [https://developers.sentiance.com/docs/sdk/android/integration](https://developers.sentiance.com/docs/sdk/android/integration) and make sure all integration steps are done.

### Add background notification
[https://developers.sentiance.com/docs/sdk/android/background-notification](https://developers.sentiance.com/docs/sdk/android/background-notification)


### Build the application
```
ionic build android
```


### In the case you have dependency conflicts
Our SDK depends on the google play services and the support library.  
We always release our SDK's with the latest dependency versions.  

There are two main techniques to circumvent these issues.

You can find conflicts by debugging the gradle dependency tree.
`./gradlew :dependencies` or `./gradlew appName:dependencies`

If there are dependency problems you can exclude the old versions from conflicting packages using:
```
exclude group: '$groupName'
```

For example, if you want to remove `com.google.android.gms` from our SDK, you can update `platforms/android/com.sentiance.sdk.cordova/app-CordovaSentianceSDK.gradle`
```
dependencies {
    compile ('com.sentiance:sdk:3.3.4@aar') {
      transitive = true
      exclude group: 'com.google.android.gms'
    }
}
```


## Background optimizations
1.  Only load window when the view will appear
2.  Only load browser when foreground
3.  Kill browser when background for a while and app keeps running
