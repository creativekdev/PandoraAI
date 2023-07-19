package io.socialbook.cartoonizer.download;

import android.app.DownloadManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.database.Cursor;
import android.net.Uri;
import android.os.Environment;
import android.widget.Toast;

import java.io.File;
import java.io.IOException;

import io.socialbook.cartoonizer.R;

public class DownloadUtils {
    //下载器
    private DownloadManager downloadManager;
    private Context mContext;
    //下载的ID
    private long downloadId;
    private String pathstr;

    public DownloadUtils(Context context) {
        this.mContext = context;
    }

    //下载apk
    public void downloadAPK(String url, String name, String description) {
        //注册广播接收者，监听下载状态
        mContext.registerReceiver(receiver,
                new IntentFilter(DownloadManager.ACTION_DOWNLOAD_COMPLETE));
        //创建下载任务
        DownloadManager.Request request = new DownloadManager.Request(Uri.parse(url));
        //移动网络情况下是否允许漫游
        request.setAllowedOverRoaming(false);
        //在通知栏中显示，默认就是显示的
        request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE);
        request.setTitle(mContext.getString(R.string.app_name));
        request.setDescription(description);
        request.setVisibleInDownloadsUi(true);

        //设置下载的路径
        File file = new File(mContext.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS), name);
        if (file.exists()) {
            file.delete();
        }
        File newFile = new File(mContext.getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS), name);
        request.setDestinationUri(Uri.fromFile(newFile));
        pathstr = newFile.getAbsolutePath();
        //获取DownloadManager
        if (downloadManager == null) {
            downloadManager = (DownloadManager) mContext.getSystemService(Context.DOWNLOAD_SERVICE);
        }
        //将下载请求加入下载队列，加入下载队列后会给该任务返回一个long型的id，通过该id可以取消任务，重启任务、获取下载的文件等等
        if (downloadManager != null) {
            downloadId = downloadManager.enqueue(request);
        }

    }

    //广播监听下载的各个状态
    private BroadcastReceiver receiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            checkStatus();
        }
    };

    //检查下载状态
    private void checkStatus() {
        DownloadManager.Query query = new DownloadManager.Query();
        //通过下载的id查找
        query.setFilterById(downloadId);
        Cursor cursor = downloadManager.query(query);
        if (cursor.moveToFirst()) {
            int status = cursor.getInt(cursor.getColumnIndex(DownloadManager.COLUMN_STATUS));
            switch (status) {
                //下载暂停
                case DownloadManager.STATUS_PAUSED:
                    break;
                //下载延迟
                case DownloadManager.STATUS_PENDING:
                    break;
                //正在下载
                case DownloadManager.STATUS_RUNNING:
                    break;
                //下载完成
                case DownloadManager.STATUS_SUCCESSFUL:
                    //下载完成安装APK
                    installAPK();
                    cursor.close();
                    break;
                //下载失败
                case DownloadManager.STATUS_FAILED:
                    Toast.makeText(mContext, "Download Failed", Toast.LENGTH_SHORT).show();
                    cursor.close();
                    mContext.unregisterReceiver(receiver);
                    break;
                default:
                    break;
            }
        }
    }

    private void installAPK() {
        setPermission(pathstr);
        mContext.startActivity(FileEx.getApkFileIntent(mContext, pathstr));
    }

    //修改文件权限
    private void setPermission(String absolutePath) {
        String command = "chmod " + "777" + " " + absolutePath;
        Runtime runtime = Runtime.getRuntime();
        try {
            runtime.exec(command);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}