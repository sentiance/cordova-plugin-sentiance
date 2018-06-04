package com.sentiance.plugin;

import android.content.Context;
import android.util.Log;

import com.sentiance.plugin.CallbackBindings;

import com.sentiance.core.model.thrift.ExternalEventType;
import com.sentiance.core.model.thrift.TransportMode;
import com.sentiance.sdk.MetadataCallback;
import com.sentiance.sdk.OnInitCallback;
import com.sentiance.sdk.OnSdkStatusUpdateHandler;
import com.sentiance.sdk.OnStartFinishedHandler;
import com.sentiance.sdk.SdkConfig;
import com.sentiance.sdk.SdkStatus;
import com.sentiance.sdk.SdkException;
import com.sentiance.sdk.Sentiance;
import com.sentiance.sdk.SdkConfig.Builder;
import com.sentiance.sdk.SubmitDetectionsCallback;
import com.sentiance.sdk.Token;
import com.sentiance.sdk.TokenResultCallback;
import com.sentiance.sdk.TripTimeoutListener;
import com.sentiance.sdk.InvalidConfigurationException;
import com.sentiance.sdk.modules.trip.Trip;
import com.sentiance.sdk.modules.trip.Waypoint;
import com.sentiance.sdk.StartTripCallback;
import com.sentiance.sdk.StopTripCallback;

import android.content.Intent;
import android.app.Notification;
import android.app.PendingIntent;
import android.support.v4.app.NotificationCompat;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.cordova.*;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONException;

public class CordovaSentianceSDK extends CordovaPlugin {

    private static final boolean DEBUG = true;

    private CallbackContext mOnStatusUpdateHandler = null;
    private CallbackContext mInitFinishedHandler = null;
    private CallbackContext mStartFinishedHandler = null;

    private OnInitCallback onInitCallback = new OnInitCallback() {
        @Override
        public void onInitSuccess() {
            if (mInitFinishedHandler != null) {
                PluginResult result = new PluginResult(PluginResult.Status.OK);
                result.setKeepCallback(true);
                mInitFinishedHandler.sendPluginResult(result);
            }
        }
        @Override
        public void onInitFailure(InitIssue issue) {
            if (mInitFinishedHandler != null) {
                PluginResult result = new PluginResult(PluginResult.Status.ERROR, issue.name());
                result.setKeepCallback(true);
                mInitFinishedHandler.sendPluginResult(result);
            }
        }
    };

    private OnStartFinishedHandler onStartFinishedCallback = new OnStartFinishedHandler() {
        @Override
        public void onStartFinished(SdkStatus sdkStatus) {
            if (mStartFinishedHandler != null) {
                // We keep this since start callback is set once, but can be called mulitple times.
                PluginResult result = new PluginResult(PluginResult.Status.OK, convertSdkStatusToJson(sdkStatus));
                result.setKeepCallback(true);
                mStartFinishedHandler.sendPluginResult(result);
            }
        }
    };

    private OnSdkStatusUpdateHandler onSdkStatusUpdateCallback = new OnSdkStatusUpdateHandler() {
        @Override
        public void onSdkStatusUpdate(SdkStatus status) {
            if(mOnStatusUpdateHandler != null) {
                // We keep this since mOnStatusUpdateHandler will be called many times.
                PluginResult result = new PluginResult(PluginResult.Status.OK, convertSdkStatusToJson(status));
                result.setKeepCallback(true);
                mOnStatusUpdateHandler.sendPluginResult(result);
            }
        }
    };

    @Override
    public boolean execute(String action, final JSONArray arguments, final CallbackContext callback) throws JSONException {
        //log("cordova.action '%s'", action);
        final Context context = cordova.getActivity().getApplicationContext();
        final Sentiance sdk = Sentiance.getInstance(context);


        if (action == null) {
            callback.error("Action cannot be null");
            return false;
        }

        try {
            if (action.equals("init")) {
                final String appId = arguments.getString(0);
                final String secret = arguments.getString(1);
                JSONObject _notificationConfig = null;
                if(!arguments.isNull(2)) {
                    _notificationConfig = arguments.getJSONObject(2);
                }
                final JSONObject notificationConfig = _notificationConfig;

                if(notificationConfig != null) {
                    if(notificationConfig.getString("mainActivityFullClassname") == null) {
                        callback.error("notification.mainActivityFullClassname is required");
                        return true;
                    }
                    if(notificationConfig.getString("drawableIdentifier") == null) {
                        callback.error("notification.drawableIdentifier is required");
                        return true;
                    }
                    if(notificationConfig.getString("notificationTitle") == null) {
                        callback.error("notification.notificationTitle is required");
                        return true;
                    }
                    if(notificationConfig.getString("notificationText") == null) {
                        callback.error("notification.notificationText is required");
                        return true;
                    }
                }

                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        Builder configBuilder = new SdkConfig.Builder(appId,secret);
                        if(notificationConfig != null) {
                            try {
                                Intent intent = new Intent(context, Class.forName(notificationConfig.getString("mainActivityFullClassname"))).setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
                                PendingIntent pendingIntent = PendingIntent.getActivity(context, 0, intent, 0);
                                Notification notification = new NotificationCompat.Builder(context)
                                    .setContentTitle(notificationConfig.getString("notificationTitle"))
                                    .setContentText(notificationConfig.getString("notificationText"))
                                    .setShowWhen(false)
                                    .setSmallIcon(context.getResources().getIdentifier(notificationConfig.getString("drawableIdentifier"), "drawable", context.getPackageName()))
                                    .setContentIntent(pendingIntent)
                                    .setPriority(NotificationCompat.PRIORITY_MIN)
                                    .build();
                                configBuilder.enableForeground(notification);
                           } catch(JSONException exception) {
                               callback.error("Could not create notification, please check your sdk configuration");
                           } catch(ClassNotFoundException exception) {
                                callback.error("Could not find class for notification.mainActivityFullClassname");
                            }
                        }

                        configBuilder.setOnSdkStatusUpdateHandler(onSdkStatusUpdateCallback);

                        final SdkConfig sdkConfig = configBuilder.build();
                        sdk.init(sdkConfig, onInitCallback);
                    }
                });
                return true;
            } else if(action.equals("setOnStatusUpdateHandler")) {
                mOnStatusUpdateHandler = callback;

                if (context instanceof CallbackBindings) {
                    // This part is relevant only for when init is done via the Application class.
                    ((CallbackBindings)context).setOnSdkStatusUpdateHandler(onSdkStatusUpdateCallback);
                }
                return true;
            } else if (action.equals("setInitFinishedHandler")) {
                mInitFinishedHandler = callback;

                if (context instanceof CallbackBindings) {
                    // This part is relevant only for when init is done via the Application class.
                    ((CallbackBindings)context).setInitFinishedListener(onInitCallback);
                }
                return true;
            } else if (action.equals("setStartFinishedHandler")) {
                mStartFinishedHandler = callback;

                if (context instanceof CallbackBindings) {
                    // This part is relevant only for when start is called in the Application class.
                    ((CallbackBindings)context).setStartFinishedListener(onStartFinishedCallback);
                }
                return true;
            } else if (action.equals("start")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        sdk.start(onStartFinishedCallback);
                    }
                });
                return true;
            } else if (action.equals("stop")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        sdk.stop();
                    }
                });
                return true;
            } else if (action.equals("stopAfter")) {
                final int seconds = arguments.getInt(0);
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        sdk.stopAfter(seconds);
                    }
                });
                return true;
            } else if (action.equals("isInitialized")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        callback.success(sdk.isInitialized() ? "true" : "false"); // Poor man's boolean
                    }
                });
                return true;
            } else if (action.equals("getUserId")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        callback.success(sdk.getUserId());
                    }
                });
                return true;
            } else if (action.equals("getSdkStatus")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        callback.success(convertSdkStatusToJson(sdk.getSdkStatus()));
                    }
                });
                return true;
            } else if (action.equals("getVersion")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        callback.success(sdk.getVersion());
                    }
                });
                return true;
            } else if (action.equals("getUserAccessToken")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        sdk.getUserAccessToken(new TokenResultCallback() {
                            @Override
                            public void onSuccess(Token token) {
                                callback.success(convertTokenToJson(token));
                            }

                            @Override
                            public void onFailure() {
                                callback.error("Couldn't get access token");
                            }
                        });
                    }
                });
                return true;
            } else if (action.equals("addUserMetadataField")) {
                final String label = arguments.getString(0);
                final String value = arguments.getString(1);

                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {

                        sdk.addUserMetadataField(label, value, new MetadataCallback() {
                            @Override
                            public void onSuccess() {
                                callback.success();
                            }

                            @Override
                            public void onFailure() {
                                callback.error("Couldn't submit metadata");
                            }
                        });
                    }
                });
                return true;
            } else if (action.equals("addUserMetadataFields")) {
                JSONObject metadata = arguments.getJSONObject(0);
                final Map<String, String> map = jsonObjectToMap(metadata);

                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        sdk.addUserMetadataFields(map, new MetadataCallback() {
                            @Override
                            public void onSuccess() {
                                callback.success();
                            }

                            @Override
                            public void onFailure() {
                                callback.error("Couldn't submit metadata");
                            }
                        });
                    }
                });
                return true;
            } else if (action.equals("removeUserMetadataField")) {
                final String label = arguments.getString(0);

                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {

                        sdk.removeUserMetadataField(label, new MetadataCallback() {
                            @Override
                            public void onSuccess() {
                                callback.success();
                            }

                            @Override
                            public void onFailure() {
                                callback.error("Couldn't remove metadata?");
                            }
                        });
                    }
                });
                return true;
            } else if (action.equals("startTrip")) {
                final Map<String, String> metadata = jsonObjectToMap(arguments.optJSONObject(0));
                int hintParam = arguments.optInt(1, -1);
                final TransportMode hint = hintParam == -1 ? null : TransportMode.findByValue(hintParam);

                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        sdk.startTrip(metadata, hint, new StartTripCallback() {
                            @Override
                                public void onSuccess() {
                                  callback.success();
                            }

                            @Override
                            public void onFailure(SdkStatus sdkStatus) {
                                callback.error(convertSdkStatusToJson(sdkStatus));
                            }
                        });
                    }
                });
                return true;
            } else if (action.equals("stopTrip")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        sdk.stopTrip(new StopTripCallback() {
                            @Override
                            public void onTripStopped(Trip trip) {
                                callback.success(convertTripToJson(trip));
                            }
                        });
                    }
                });
                return true;
            } else if (action.equals("setTripTimeoutListener")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        sdk.setTripTimeoutListener(new TripTimeoutListener() {
                            @Override
                            public void onTripTimeout(Trip trip) {
                                PluginResult result = new PluginResult(PluginResult.Status.OK, convertTripToJson(trip));
                                result.setKeepCallback(true);   // keep it since it's set once but called many times.
                                callback.sendPluginResult(result);
                            }
                        });
                    }
                });
                return true;
            } else if (action.equals("isTripOngoing")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        callback.success(sdk.isTripOngoing() ? "true" : "false");
                    }
                });
                return true;
            } else if (action.equals("registerExternalEvent")) {
                int typeParam = arguments.getInt(0);
                final ExternalEventType type = ExternalEventType.findByValue(typeParam);
                final long timestamp = arguments.getLong(1);
                final String id = arguments.getString(2);
                final String label = arguments.optString(3, null);

                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        sdk.registerExternalEvent(type, timestamp, id, label);
                        callback.success();
                    }
                });
                return true;
            } else if (action.equals("deregisterExternalEvent")) {
                int typeParam = arguments.getInt(0);
                final ExternalEventType type = ExternalEventType.findByValue(typeParam);
                final long timestamp = arguments.getLong(1);
                final String id = arguments.getString(2);
                final String label = arguments.optString(3, null);

                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        sdk.deregisterExternalEvent(type, timestamp, id, label);
                        callback.success();
                    }
                });
                return true;
            } else if (action.equals("submitDetections")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        sdk.submitDetections(new SubmitDetectionsCallback() {
                            public void onSuccess() {
                                callback.success();
                            }

                            public void onFailure() {
                                callback.error("Couldn't submit all detections");
                            }
                        });
                    }
                });
                return true;
            } else if (action.equals("getWiFiQuotaLimit")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        callback.success(String.valueOf(sdk.getWiFiQuotaLimit()));
                    }
                });
                return true;
            } else if (action.equals("getWiFiQuotaUsage")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        callback.success(String.valueOf(sdk.getWiFiQuotaUsage()));
                    }
                });
                return true;
            } else if (action.equals("getMobileQuotaLimit")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        callback.success(String.valueOf(sdk.getMobileQuotaLimit()));
                    }
                });
                return true;
            } else if (action.equals("getMobileQuotaUsage")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        callback.success(String.valueOf(sdk.getMobileQuotaUsage()));
                    }
                });
                return true;
            } else if (action.equals("getDiskQuotaLimit")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        callback.success(String.valueOf(sdk.getDiskQuotaLimit()));
                    }
                });
                return true;
            } else if (action.equals("getDiskQuotaUsage")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        callback.success(String.valueOf(sdk.getDiskQuotaUsage()));
                    }
                });
                return true;
            } else if (action.equals("getWiFiLastSeenTimestamp")) {
                cordova.getThreadPool().execute(new Runnable() {
                    public void run() {
                        callback.success(String.valueOf(sdk.getWiFiLastSeenTimestamp()));
                    }
                });
                return true;
            }
        } catch(Exception e) {
            // Generic error handler
            log("%s: %s", e.getClass().getSimpleName(), e.getMessage());
            callback.error(convertExceptionToJson(e));
            return true;
        }
        log("NO IMPLEMENTATION FOR THIS IN SENTIANCE SDK JAVA PLUGIN");
        return false;
    }

    private void log(String msg, Object... params) {
        if (DEBUG) {
            Log.e("SentianceSDK", String.format(msg, params));
        }
    }

    private JSONObject convertExceptionToJson(Exception ex) {
        JSONObject result = new JSONObject();
        try {
            result.put("message", ex.getMessage());
            result.put("stacktrace", Log.getStackTraceString(ex));
        } catch (JSONException e) {
        }

        return result;
    }

    private JSONObject convertSdkStatusToJson(SdkStatus status) {
        JSONObject result = new JSONObject();

        try {
            result.put("startStatus", status.startStatus.name());
            result.put("canDetect", status.canDetect);
            result.put("isRemoteEnabled", status.isRemoteEnabled);
            result.put("isLocationPermGranted", status.isLocationPermGranted);
            result.put("locationSetting", status.locationSetting.name());
            result.put("isAccelPresent", status.isAccelPresent);
            result.put("isGyroPresent", status.isGyroPresent);
            result.put("isGpsPresent", status.isGpsPresent);
            result.put("isGooglePlayServicesMissing", status.isGooglePlayServicesMissing);
            result.put("wifiQuotaStatus", status.wifiQuotaStatus);
            result.put("mobileQuotaStatus", status.mobileQuotaStatus);
            result.put("diskQuotaStatus", status.diskQuotaStatus);
        } catch (JSONException ignored) {
        }

        return result;
    }

    private JSONObject convertTokenToJson(Token token) {
        JSONObject result = new JSONObject();

        try {
            result.put("tokenId", token.getTokenId());
            result.put("expiryDate", token.getExpiryDate().getTime());
        } catch (JSONException ignored) {
        }

        return result;
    }

    private JSONObject convertTripToJson(Trip trip) {
        JSONObject result = new JSONObject();

        if (trip == null) {
            return result;
        }

        try {
            result.put("tripId", trip.tripId);
            result.put("start", trip.start);
            result.put("stop", trip.stop);
            result.put("distance", trip.distance);

            JSONArray waypoints = new JSONArray();
            for(Waypoint waypoint : trip.waypoints) {
                JSONObject jsonWaypoint = new JSONObject();
                jsonWaypoint.put("timestamp", waypoint.timestamp);
                jsonWaypoint.put("latitude", waypoint.latitude);
                jsonWaypoint.put("longitude", waypoint.longitude);
                jsonWaypoint.put("accuracy", waypoint.accuracy);
                waypoints.put(jsonWaypoint);
            }
            result.put("waypoints", waypoints);
        } catch (JSONException ignored) {
        }

        return result;
    }

    private Map<String, String> jsonObjectToMap(JSONObject jsonObject) {
        if (jsonObject == null) {
            return null;
        }

        Map<String, String> result = new HashMap<String, String>();

        Iterator<String> iterator = jsonObject.keys();
        while (iterator.hasNext()) {
            String key = iterator.next();
            try {
                result.put(key, jsonObject.getString(key));
            } catch (JSONException ignored) {
            }
        }
        return result;
    }
}
