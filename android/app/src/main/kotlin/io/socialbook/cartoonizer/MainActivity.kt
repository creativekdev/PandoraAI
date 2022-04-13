package io.socialbook.cartoonizer

import android.content.pm.PackageManager
import android.net.Uri
import androidx.annotation.NonNull
import com.bytedance.sdk.open.tiktok.TikTokOpenApiFactory
import com.bytedance.sdk.open.tiktok.TikTokOpenConfig
import com.bytedance.sdk.open.tiktok.api.TikTokOpenApi
import com.bytedance.sdk.open.tiktok.authorize.model.Authorization
import com.facebook.share.model.SharePhoto;
import com.facebook.share.model.SharePhotoContent;
import com.facebook.share.widget.ShareDialog;
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "io.socialbook/cartoonizer"
    lateinit var tiktokOpenApi : TikTokOpenApi
    companion object{
        lateinit var mResult : MethodChannel.Result
    }
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        val clientKey = "aw9iospxikqd2qsx"
        val tiktokOpenConfig = TikTokOpenConfig(clientKey)
        TikTokOpenApiFactory.init(tiktokOpenConfig)
        tiktokOpenApi = TikTokOpenApiFactory.create(this@MainActivity)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            mResult = result
            when (call.method) {
                "ShareFacebook" -> {
                    val fileURL = Uri.parse(call.argument("fileURL"))
                    // val fileType = Uri.parse(call.argument("fileType"))

                    // share facebook photo
                    val sharePhoto = SharePhoto.Builder().setImageUrl(fileURL).build();
                    val content = SharePhotoContent.Builder().addPhoto(sharePhoto).build();
                    val shareDialog = ShareDialog(this@MainActivity);

                    shareDialog.show(content);
                    result.success(true);
                }

                "AppInstall" -> {
                    val isAppInstalled = appInstalledOrNot(call.argument<String>("path").toString())
                    if (isAppInstalled) {
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }

                "OpenTiktok" -> {
                    val request = Authorization.Request()
                    request.scope = "user.info.basic,video.list,video.upload"
                    request.state = "99"
                    tiktokOpenApi.authorize(request)
                }
            }
        }
    }

    private fun appInstalledOrNot(uri: String): Boolean {
        val pm: PackageManager = packageManager
        try {
            pm.getPackageInfo(uri, PackageManager.GET_ACTIVITIES)
            return true
        } catch (e: PackageManager.NameNotFoundException) {
        }
        return false
    }
}
