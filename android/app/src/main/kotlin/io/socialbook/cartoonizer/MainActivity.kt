package io.socialbook.cartoonizer

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.widget.Toast
import androidx.activity.result.contract.ActivityResultContracts
import androidx.annotation.NonNull
import androidx.core.content.FileProvider
import com.bytedance.sdk.open.tiktok.TikTokOpenApiFactory
import com.bytedance.sdk.open.tiktok.TikTokOpenConfig
import com.bytedance.sdk.open.tiktok.api.TikTokOpenApi
import com.bytedance.sdk.open.tiktok.authorize.model.Authorization
import com.bytedance.sdk.open.tiktok.common.handler.IApiEventHandler
import com.bytedance.sdk.open.tiktok.common.model.BaseReq
import com.bytedance.sdk.open.tiktok.common.model.BaseResp
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity()/*, IApiEventHandler*/ {

    private val CHANNEL = "io.socialbook/shareVideo"
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
                "ShareInsta" -> {
                    val filePath = Uri.parse(call.argument("path"))
                    val uri = FileProvider.getUriForFile(context, "io.socialbook.cartoonizer.com.shekarmudaliyar.social_share", File(filePath.path))
                    val feedIntent = Intent(Intent.ACTION_SEND)
                    feedIntent.type = "video/*"
                    feedIntent.putExtra(Intent.EXTRA_STREAM, uri)
                    feedIntent.setPackage("com.instagram.android")

                    val storiesIntent = Intent("com.instagram.share.ADD_TO_STORY")
                    storiesIntent.setDataAndType(uri, "mp4")
                    storiesIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    storiesIntent.setPackage("com.instagram.android")

                    activity.grantUriPermission("com.instagram.android", uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)

                    val chooserIntent: Intent = Intent.createChooser(feedIntent, "share video")
                    chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, arrayOf<Intent>(storiesIntent))
                    startActivity(chooserIntent)
                }

                "ShareFacebook" -> {
                    val filePath = Uri.parse(call.argument("path"))
                    val uri = FileProvider.getUriForFile(context, "io.socialbook.cartoonizer.com.shekarmudaliyar.social_share", File(filePath.path))
                    val feedIntent = Intent(Intent.ACTION_SEND)
                    feedIntent.type = "video/*"
                    feedIntent.putExtra(Intent.EXTRA_STREAM, uri)
                    feedIntent.setPackage("com.facebook.katana")

                    activity.grantUriPermission("com.facebook.katana", uri, Intent.FLAG_GRANT_READ_URI_PERMISSION)

                    val chooserIntent: Intent = Intent.createChooser(feedIntent, "share video")
                    startActivity(chooserIntent)
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
        Log.e("TAG","appInstalledOrNot")
        val pm: PackageManager = packageManager
        try {
            pm.getPackageInfo(uri, PackageManager.GET_ACTIVITIES)
            return true
        } catch (e: PackageManager.NameNotFoundException) {
        }
        return false
    }
}
