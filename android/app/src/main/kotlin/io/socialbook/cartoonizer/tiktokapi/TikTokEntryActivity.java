package io.socialbook.cartoonizer.tiktokapi;

import static io.socialbook.cartoonizer.MainActivity.mResult;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.widget.Toast;

import androidx.annotation.Nullable;

import com.bytedance.sdk.open.tiktok.TikTokOpenApiFactory;
import com.bytedance.sdk.open.tiktok.api.TikTokOpenApi;
import com.bytedance.sdk.open.tiktok.authorize.model.Authorization;
import com.bytedance.sdk.open.tiktok.common.handler.IApiEventHandler;
import com.bytedance.sdk.open.tiktok.common.model.BaseReq;
import com.bytedance.sdk.open.tiktok.common.model.BaseResp;

import io.flutter.Log;

public class TikTokEntryActivity extends Activity implements IApiEventHandler {

    TikTokOpenApi ttOpenApi;
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        ttOpenApi= TikTokOpenApiFactory.create(this);
        ttOpenApi.handleIntent(getIntent(),this); // receive and parse callback
    }
    @Override
    public void onReq(BaseReq req) {
    }
    @Override
    public void onResp(BaseResp resp) {
        if (resp instanceof Authorization.Response)  {
            Authorization.Response response = (Authorization.Response) resp;
            if(response.errorCode == 0){
                mResult.success(response.authCode);
            }
        }
        finish();
    }
    @Override
    public void onErrorIntent(@Nullable Intent intent) {
        Toast.makeText(this, "Intent Error", Toast.LENGTH_LONG).show();
    }
}
