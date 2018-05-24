# Develop

1.  Clone the cordova-plugin locally
2.  Create an ionic project
3.  Install the local cordova-plugin into the testapp
4.  Build and run testapp

## Create an ionic project
```
ionic start testapp blank
cd testapp
ionic platform add android
```

## Install the local cordova-plugin into the testapp
```
ionic plugin remove com.sentiance.sdk.cordova --save                  # Remove the previous plugin
ionic plugin add ../../cordova-plugin                                 # Reinstall using your local cordova-plugin clone
```

## Build and run testapp
```
ionic build android                                                   # Rebuild android
adb install -r platforms/android/build/outputs/apk/android-debug.apk  # Run it
```

## Example ionic testapp code
File: www/js/app.js
```
......
  $ionicPlatform.ready(function() {
  .......
    sentiance.setOnStatusUpdateHandler(function() {
      console.log('STATUS UPDATE');
    })
    sentiance.init("APP_ID", "SECRET", null, function() {
        console.log('INITIALIZED');
        sentiance.getUserId(function(userId) {
          console.log('UserId: '+userId);
        }, function(err) {
          console.log('Error: '+err);
        })
        sentiance.start(function(status) {
          console.log('Started!');
        })
      }, function(err) {
        console.log("ERROR"+err);
      }
    );
  });
});

```