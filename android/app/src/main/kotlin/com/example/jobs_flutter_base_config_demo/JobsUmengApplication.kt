package com.example.jobs_flutter_base_config_demo

import android.app.Application
import android.os.Bundle
import com.umeng.commonsdk.UMConfigure
import com.umeng.umcrash.UMCrash

class JobsUmengApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        // 只启用异常相关模块，性能采集另按 Demo 需求显式开启。
        val crashConfig = Bundle().apply {
            putBoolean(UMCrash.KEY_ENABLE_CRASH_JAVA, true)
            putBoolean(UMCrash.KEY_ENABLE_CRASH_NATIVE, true)
            putBoolean(UMCrash.KEY_ENABLE_ANR, true)
            putBoolean(UMCrash.KEY_ENABLE_FLUTTER, true)
            putBoolean(UMCrash.KEY_ENABLE_PA, false)
            putBoolean(UMCrash.KEY_ENABLE_LAUNCH, false)
            putBoolean(UMCrash.KEY_ENABLE_MEM, false)
            putBoolean(UMCrash.KEY_ENABLE_NET, false)
            putBoolean(UMCrash.KEY_ENABLE_H5PAGE, false)
            putBoolean(UMCrash.KEY_ENABLE_PAGE, false)
            putBoolean(UMCrash.KEY_ENABLE_CODE_LOG, false)
            putBoolean(UMCrash.KEY_ENABLE_POWER, false)
            putBoolean(UMCrash.KEY_ENABLE_MEMLEAK, false)
        }
        UMCrash.initConfig(crashConfig)
        // 预初始化不采集数据，正式初始化由 Flutter 页面获得同意后触发。
        UMConfigure.preInit(this, "6ad70d586545637cd61a3706", "JobsFlutterDemo")
    }
}
