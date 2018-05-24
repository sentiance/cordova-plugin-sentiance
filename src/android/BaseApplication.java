package com.sentiance.plugin;

import android.app.Application;
import android.app.Notification;
import android.text.TextUtils;

import com.sentiance.sdk.OnInitCallback;
import com.sentiance.sdk.OnSdkStatusUpdateHandler;
import com.sentiance.sdk.OnStartFinishedHandler;
import com.sentiance.sdk.SdkConfig;
import com.sentiance.sdk.SdkStatus;
import com.sentiance.sdk.Sentiance;

public abstract class BaseApplication extends Application implements CallbackBindings {

    private static final int INIT_STATE_NOT_INTIIALIZED = 0;
    private static final int INIT_STATE_FAILED = 1;
    private static final int INIT_STATE_SUCCESS = 2;

    private int mInitState = INIT_STATE_NOT_INTIIALIZED;
    private OnInitCallback.InitIssue mInitIssue = null;
    private boolean mStartFinished = false;
    private SdkStatus mSdkStatus = null;
    private OnInitCallback mInitCallback;
    private OnStartFinishedHandler mStartCallback;
    private OnSdkStatusUpdateHandler mSdkStatusUpdateCallback;

    protected abstract String getAppID();
    protected abstract String getSecret();
    protected abstract Notification getNotification();

    protected void onInitSuccess() {
    }

    protected void onInitFailure(OnInitCallback.InitIssue issue) {
    }

    protected void onStartFinished(SdkStatus sdkStatus) {
    }

    @Override
    public final void setInitFinishedListener(OnInitCallback callback) {
        mInitCallback = callback;
        if (callback == null)
            return;

        if (mInitState != INIT_STATE_NOT_INTIIALIZED) {
            if (mInitState == INIT_STATE_SUCCESS) {
                callback.onInitSuccess();
                onInitSuccess();
            } else {
                callback.onInitFailure(mInitIssue);
                onInitFailure(mInitIssue);
            }
        }
    }

    @Override
    public final void setStartFinishedListener(OnStartFinishedHandler callback) {
        mStartCallback = callback;
        if (callback == null)
            return;

        if (mStartFinished) {
            callback.onStartFinished(mSdkStatus);
            onStartFinished(mSdkStatus);
        }
    }

    @Override
    public final void setOnSdkStatusUpdateHandler(OnSdkStatusUpdateHandler callback) {
        mSdkStatusUpdateCallback = callback;
    }

    @Override
    public void onCreate() {
        super.onCreate();

        initSentiance();
    }

    protected boolean isAutostartEnabled() {
        return true;
    }

    private void initSentiance() {
        if (TextUtils.isEmpty(getAppID()) || TextUtils.isEmpty(getSecret())) {
            return;
        }

        final Sentiance sdk = Sentiance.getInstance(getApplicationContext());

        final SdkConfig sdkConfig = new SdkConfig.Builder(getAppID(), getSecret(), getNotification())
                .setOnSdkStatusUpdateHandler(new OnSdkStatusUpdateHandler() {
                    @Override
                    public void onSdkStatusUpdate(SdkStatus status) {
                        if (mSdkStatusUpdateCallback != null)
                            mSdkStatusUpdateCallback.onSdkStatusUpdate(status);
                    }
                })
                .build();

        sdk.init(sdkConfig, new OnInitCallback() {
            @Override
            public void onInitSuccess() {
                mInitState = INIT_STATE_SUCCESS;
                if (mInitCallback != null) {
                    mInitCallback.onInitSuccess();
                }
                BaseApplication.this.onInitSuccess();

                if (isAutostartEnabled()) {
                    sdk.start(new OnStartFinishedHandler() {
                        @Override
                        public void onStartFinished(SdkStatus sdkStatus) {
                            mSdkStatus = sdkStatus;
                            mStartFinished = true;

                            if (mStartCallback != null) {
                                mStartCallback.onStartFinished(sdkStatus);
                            }
                            BaseApplication.this.onStartFinished(sdkStatus);
                        }
                    });
                }
            }

            @Override
            public void onInitFailure(OnInitCallback.InitIssue issue) {
                mInitIssue = issue;
                mInitState = INIT_STATE_FAILED;
                if (mInitCallback != null) {
                    mInitCallback.onInitFailure(issue);
                }
                BaseApplication.this.onInitFailure(issue);
            }
        });
    }
}
