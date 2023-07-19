package io.socialbook.cartoonizer

import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Matrix
import android.net.Uri
import androidx.annotation.NonNull
import com.bytedance.sdk.open.tiktok.TikTokOpenApiFactory
import com.bytedance.sdk.open.tiktok.TikTokOpenConfig
import com.bytedance.sdk.open.tiktok.api.TikTokOpenApi
import com.bytedance.sdk.open.tiktok.authorize.model.Authorization
import com.facebook.share.model.SharePhoto
import com.facebook.share.model.SharePhotoContent
import com.facebook.share.widget.ShareDialog
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.socialbook.cartoonizer.converter.AsyncTaskHelper
import io.socialbook.cartoonizer.converter.YuvConverter
import io.socialbook.cartoonizer.download.DownloadUtils
import java.io.ByteArrayOutputStream
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.io.IOException

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "io.socialbook/cartoonizer"
    lateinit var tiktokOpenApi: TikTokOpenApi

    companion object {
        lateinit var mResult: MethodChannel.Result
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val clientKey = "aw9iospxikqd2qsx"
        val tiktokOpenConfig = TikTokOpenConfig(clientKey)
        TikTokOpenApiFactory.init(tiktokOpenConfig)
        tiktokOpenApi = TikTokOpenApiFactory.create(this@MainActivity)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->
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

                "YUVTransform" -> {
                    val bytesList: ArrayList<ByteArray>? = call.argument("data")
                    val strides: IntArray = call.argument("strides")!!
                    val width: Int = call.argument("width")!!
                    val height: Int = call.argument("height")!!
                    val quality: Int = call.argument("quality")!!
                    val isVertical: Boolean = call.argument("isVertical")!!
                    val isFront: Boolean = call.argument("isFront")!!
                    if (bytesList == null) {
                        result.error("-1", "ioException", "null bytes")
                    } else {
                        val data = YuvConverter.NV21toJPEG(
                            YuvConverter.YUVtoNV21(
                                bytesList,
                                strides,
                                width,
                                height
                            ), width, height, 100
                        )
                        val bitmapRaw = BitmapFactory.decodeByteArray(data, 0, data.size)
                        val bitmap = if (isVertical && width > height) {
                            val matrix = Matrix()
                            matrix.postRotate(90F)//统一旋转90度
                            if (isFront) {//前置摄像头是镜像的，向下翻转，完后需要往回位移height高度
                                matrix.postScale(1F, -1F)
                                matrix.postTranslate(0F, height.toFloat())
                            }
                            Bitmap.createBitmap(
                                bitmapRaw,
                                0,
                                0,
                                bitmapRaw.width,
                                bitmapRaw.height,
                                matrix,
                                true
                            )
                        } else {
                            bitmapRaw
                        }
                        AsyncTaskHelper.execute(
                            AsyncTaskHelper.AsyncTaskKt<ByteArray>().runInBackground {
                                var outputStream: ByteArrayOutputStream? = null
                                val result: ByteArray?
                                try {
                                    outputStream = ByteArrayOutputStream()
                                    bitmap.compress(
                                        Bitmap.CompressFormat.PNG,
                                        quality,
                                        outputStream
                                    )
                                    result = outputStream.toByteArray()
                                } catch (e: IOException) {
                                    return@runInBackground null
                                } finally {
                                    outputStream?.close()
                                }
                                return@runInBackground result
                            }.runOnUI {
                                if (it == null) {
                                    result.error("-1", "ioException", "ioException")
                                } else {
                                    result.success(it)
                                }
                            })
                    }

                }

                "heic2jpg" -> {
                    val filePath: String? = call.argument("path")
                    val outPath: String? = call.argument("outPath")
                    AsyncTaskHelper.execute(AsyncTaskHelper.AsyncTaskKt<Boolean>().runInBackground {
                        val fileInputStream = FileInputStream(File(filePath))
                        val decodeFile: Bitmap = BitmapFactory.decodeStream(fileInputStream)
                        val file = File(outPath)
                        val fileOutputStream = FileOutputStream(file)
                        val result =
                            decodeFile.compress(Bitmap.CompressFormat.JPEG, 95, fileOutputStream)
                        fileInputStream.close()
                        fileOutputStream.close()
                        return@runInBackground result
                    }.runOnUI {
                        if (it == null) {
                            result.error("-1", "ioException", "ioException")
                        } else {
                            result.success(it)
                        }
                    })
                }

                "openAppStore" -> {
                    toAppStore(result)
                }
                "updateAppByApk" -> {
                    val url = call.argument<String>("url")
                    val name = call.argument<String>("name")
                    val desc = call.argument<String>("desc")
                    DownloadUtils(this).downloadAPK(url, name, desc)
                    result.success(true)
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

    private fun toAppStore(result: MethodChannel.Result) {
        try {
            val uri = Uri.parse("market://details?id=" + applicationContext.packageName)
            val intent = Intent(Intent.ACTION_VIEW, uri)
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }
}
