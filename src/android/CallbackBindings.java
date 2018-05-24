package com.sentiance.plugin;

import com.sentiance.sdk.OnInitCallback;
import com.sentiance.sdk.OnStartFinishedHandler;
import com.sentiance.sdk.OnSdkStatusUpdateHandler;

public interface CallbackBindings {
    void setInitFinishedListener(OnInitCallback callback);
    void setOnSdkStatusUpdateHandler(OnSdkStatusUpdateHandler callback);
    void setStartFinishedListener(OnStartFinishedHandler callback);
}
