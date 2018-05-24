// This script downloads the Sentiance SDK
module.exports = function(ctx) {
    var sdkVersion = '4.6.0';

    var fs = ctx.requireCordovaModule('fs'),
        path = ctx.requireCordovaModule('path'),
        zlib = ctx.requireCordovaModule('zlib'),
        https = ctx.requireCordovaModule('https'),
        Q = ctx.requireCordovaModule('q'),
        extract = require(__dirname + '/../node_modules/extract-zip');


    var download = function(url, dest, cb) {
        var file = fs.createWriteStream(dest);
        var request = https.get(url, function(response) {
            response.pipe(file);
            file.on('finish', function() {
                file.close(cb);
            });
        });
    }

    var frameworkUrl = 'https://s3-eu-west-1.amazonaws.com/sentiance-sdk/ios/transport/SENTTransportDetectionSDK-'+sdkVersion+'.framework.zip';

    // make sure this only happens on ios build
    // if (ctx.opts.cordova.platforms.indexOf('ios') < 0) {
    //     return;
    // }
    var deferred = Q.defer();

    console.log('com.sentiance.sdk.cordova: downloading SDK framework archive, version: '+sdkVersion);

    var archivePath = ctx.opts.plugin.dir+'/src/ios/SENTTransportDetectionSDK.framework.zip';
    var frameworkPath = ctx.opts.plugin.dir+'/src/ios/framework';
    download(frameworkUrl, archivePath, function() {
        console.log('com.sentiance.sdk.cordova: extracting framework');
        extract(archivePath, {dir: frameworkPath}, function (err) {
            fs.unlink(archivePath, function() {
                console.log('com.sentiance.sdk.cordova: removing temporary archive');
                deferred.resolve();
            });
        });
    });

    return deferred.promise;
};
