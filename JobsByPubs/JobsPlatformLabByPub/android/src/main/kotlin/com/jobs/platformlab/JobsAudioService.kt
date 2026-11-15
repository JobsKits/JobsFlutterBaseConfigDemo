package com.jobs.platformlab

import android.app.*
import android.content.Intent
import android.os.Build
import android.os.IBinder

internal object JobsAudioServiceOwner {
    var stop: (() -> Unit)? = null
}

/** Keeps an explicitly started microphone recording valid while the app backgrounds. */
class JobsAudioService: Service() {
    override fun onBind(intent:Intent?):IBinder?=null
    override fun onStartCommand(intent:Intent?,flags:Int,startId:Int):Int {
        val manager=getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        if(Build.VERSION.SDK_INT>=26) manager.createNotificationChannel(NotificationChannel("jobs_recording","Jobs audio recording",NotificationManager.IMPORTANCE_LOW))
        val builder=if(Build.VERSION.SDK_INT>=26)Notification.Builder(this,"jobs_recording") else Notification.Builder(this)
        val launch=packageManager.getLaunchIntentForPackage(packageName)
        val pending=launch?.let {PendingIntent.getActivity(this,0,it,PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)}
        val notification=builder.setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setContentTitle(intent?.getStringExtra("title") ?: "Jobs Flutter")
            .setContentText(intent?.getStringExtra("message") ?: "Audio recording")
            .setContentIntent(pending).setOngoing(true).build()
        startForeground(8195,notification)
        return START_NOT_STICKY
    }
    override fun onDestroy() {
        val stop=JobsAudioServiceOwner.stop
        JobsAudioServiceOwner.stop=null
        stop?.invoke()
        super.onDestroy()
    }
}
