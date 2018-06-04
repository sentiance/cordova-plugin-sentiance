/*global cordova, module*/

module.exports = {
    init: function(appId, secret, notificationConfig, error) {
        cordova.exec(null, error, "SentianceSDK", "init", [appId, secret, notificationConfig]);
    },

    setOnStatusUpdateHandler: function(success, error) {
        cordova.exec(success, error, "SentianceSDK", "setOnStatusUpdateHandler", []);
    },

    setInitFinishedHandler: function(success, error) {
        cordova.exec(success, error, "SentianceSDK", "setInitFinishedHandler", []);
    },

    setStartFinishedHandler: function(success, error) {
        cordova.exec(success, error, "SentianceSDK", "setStartFinishedHandler", []);
    },

    start: function(success, error) {
        cordova.exec(success, error, "SentianceSDK", "start", []);
    },

    stop: function(success, error) {
        cordova.exec(success, error, "SentianceSDK", "stop", []);
    },

    stopAfter: function(seconds, success, error) {
        if(seconds == null || seconds == undefined || !seconds || seconds < 0) {
            return error('stopAfter seconds should be a positive integer');
        }
        cordova.exec(success, error, "SentianceSDK", "stopAfter", [seconds]);
    },

    isInitialized: function(success, error) {
        cordova.exec(function(result) {
            success(result === 'true' ? true : false);
        }, error, "SentianceSDK", "isInitialized", []);
    },

    getSdkStatus: function(success, error) {
        cordova.exec(success, error, "SentianceSDK", "getSdkStatus", []);
    },

    getVersion: function(success, error) {
        cordova.exec(success, error, "SentianceSDK", "getVersion", []);
    },

    getUserId: function(success, error) {
        cordova.exec(success, error, "SentianceSDK", "getUserId", []);
    },

    getUserAccessToken: function(success, error) {
        cordova.exec(success, error, "SentianceSDK", "getUserAccessToken", []);
    },

    addUserMetadataField: function(label, value, success, error) {
        cordova.exec(success, error, "SentianceSDK", "addUserMetadataField", [label, value]);
    },

    removeUserMetadataField: function(label, success, error) {
        cordova.exec(success, error, "SentianceSDK", "removeUserMetadataField", [label]);
    },

    addUserMetadataFields: function(metadata, success, error) {
        cordova.exec(success, error, "SentianceSDK", "addUserMetadataFields", [metadata]);
    },

    startTrip: function (metadata, transportModeHint, success, error) {
        cordova.exec(success, error, "SentianceSDK", "startTrip", [metadata, transportModeHint]);
    },

    stopTrip: function (success, error) {
        cordova.exec(success, error, "SentianceSDK", "stopTrip", []);
    },

    setTripTimeoutListener: function(listener) {
        cordova.exec(listener, null, "SentianceSDK", "setTripTimeoutListener", [listener]);
    },

    isTripOngoing: function(success) {
        cordova.exec(function(result) {
            success(result === 'true' ? true : false);
        }, null, "SentianceSDK", "isTripOngoing", []);
    },

    registerExternalEvent: function(externalEventType, timestamp, id, label, success, error) {
        cordova.exec(success, error, "SentianceSDK", "registerExternalEvent", [externalEventType, timestamp, id, label]);
    },

    deregisterExternalEvent: function(externalEventType, timestamp, id, label, success, error) {
        cordova.exec(success, error, "SentianceSDK", "deregisterExternalEvent", [externalEventType, timestamp, id, label]);
    },

    submitDetections: function(success, error) {
        cordova.exec(success, error, "SentianceSDK", "submitDetections", []);
    },

    getWiFiQuotaLimit: function(success) {
        cordova.exec(function(response) {
            success(parseInt(response));
        }, null, "SentianceSDK", "getWiFiQuotaLimit", []);
    },

    getWiFiQuotaUsage: function(success) {
        cordova.exec(function(response) {
            success(parseInt(response));
        }, null, "SentianceSDK", "getWiFiQuotaUsage", []);
    },

    getMobileQuotaLimit: function(success) {
        cordova.exec(function(response) {
            success(parseInt(response));
        }, null, "SentianceSDK", "getMobileQuotaLimit", []);
    },

    getMobileQuotaUsage: function(success) {
        cordova.exec(function(response) {
            success(parseInt(response));
        }, null, "SentianceSDK", "getMobileQuotaUsage", []);
    },

    getDiskQuotaLimit: function(success) {
        cordova.exec(function(response) {
            success(parseInt(response));
        }, null, "SentianceSDK", "getDiskQuotaLimit", []);
    },

    getDiskQuotaUsage: function(success) {
        cordova.exec(function(response) {
            success(parseInt(response));
        }, null, "SentianceSDK", "getDiskQuotaUsage", []);
    },

    getWiFiLastSeenTimestamp: function(success) {
        cordova.exec(function(response) {
            success(parseInt(response));
        }, null, "SentianceSDK", "getWiFiLastSeenTimestamp", []);
    }

};
