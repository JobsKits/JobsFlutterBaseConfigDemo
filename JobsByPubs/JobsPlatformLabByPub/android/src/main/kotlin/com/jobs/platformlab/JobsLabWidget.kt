package com.jobs.platformlab

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class JobsLabWidget: AppWidgetProvider() {
    override fun onReceive(context:Context,intent:Intent) {
        super.onReceive(context,intent)
        if(intent.action=="com.jobs.platformlab.WIDGET_UPDATE") {
            val manager=AppWidgetManager.getInstance(context)
            onUpdate(context,manager,manager.getAppWidgetIds(ComponentName(context,JobsLabWidget::class.java)))
        }
    }
    override fun onUpdate(context:Context,manager:AppWidgetManager,ids:IntArray) {
        val text=context.getSharedPreferences("jobs_widget",Context.MODE_PRIVATE).getString("text","Jobs Flutter")
        ids.forEach { id->
            val view=RemoteViews(context.packageName,R.layout.jobs_lab_widget)
            view.setTextViewText(R.id.jobs_widget_text,text)
            manager.updateAppWidget(id,view)
        }
    }
}
