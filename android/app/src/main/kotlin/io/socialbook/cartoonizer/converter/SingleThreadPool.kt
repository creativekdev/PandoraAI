@file:Suppress("unused")

package io.socialbook.cartoonizer.converter

import java.util.concurrent.*

/**
 * 单线程池，策略为先进先出，与Executors不同 [java.util.concurrent.Executors.newSingleThreadExecutor]
 * Created by wangyu on 2018/10/23.
 */

class SingleThreadPool
/**
 * 单任务线程池
 * 默认优先级为（Thread.NORM_PRIORITY - 1）.
 * @param keepAliveTime  最大空闲时间
 * @param timeUnit       时间单位
 * @param threadName     线程名称
 * @param threadPriority 线程优先级
 */
@JvmOverloads constructor(keepAliveTime: Int = 60, timeUnit: TimeUnit = TimeUnit.SECONDS, threadName: String = "SingleThreadPool", threadPriority: Int = Thread.NORM_PRIORITY - 1) : Executor {

    private val executorService: ExecutorService

    init {
        val threadFactory = ThreadFactory { r ->
            val thread = Thread(r, threadName)
            thread.priority = threadPriority
            thread
        }
        val linkedBlockingQueue = LinkedBlockingQueue<Runnable>()
        executorService = ThreadPoolExecutor(0, 1, keepAliveTime.toLong(), timeUnit, linkedBlockingQueue, threadFactory)
    }

    /**
     * 执行任务
     *
     * @param runnable 待执行任务
     */
    override fun execute(runnable: Runnable) {
        executorService.execute(runnable)
    }

    fun <T> submit(task: Callable<T>): Future<T> {
        return executorService.submit(task)
    }
}