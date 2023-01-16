package io.socialbook.cartoonizer.converter

import android.os.Handler
import android.os.Looper
import java.util.concurrent.Executors

object AsyncTaskHelper : AsyncTaskAction {

    private val executors = Executors.newCachedThreadPool()
    private val handler = Handler(Looper.getMainLooper())

    override fun<T> execute(task: AsyncTask<T>) {
        executors.execute {
            val result = task.runInBackground()
            handler.post {
                task.runOnUI(result)
            }
        }
    }

    interface AsyncTask<T> {
        fun runInBackground(): T?
        fun runOnUI(t: T?)
    }

    class AsyncTaskKt<T> : AsyncTask<T> {

        private var dbCallback: (() -> T?)? = null
        private var uiCallback: ((data: T?) -> Unit)? = null

        override fun runInBackground(): T? {
            return dbCallback?.invoke()
        }

        override fun runOnUI(t: T?) {
            uiCallback?.invoke(t)
        }

        fun runInBackground(callback: () -> T?): AsyncTaskKt<T> {
            dbCallback = callback
            return this
        }

        fun runOnUI(callback: (data: T?) -> Unit): AsyncTaskKt<T> {
            uiCallback = callback
            return this
        }
    }
}

interface AsyncTaskAction {
    fun <T> execute(task: AsyncTaskHelper.AsyncTask<T>)
}