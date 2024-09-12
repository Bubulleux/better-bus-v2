package com.bubulle.better_bus_v2

import android.app.ActivityOptions
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.SharedPreferences
import android.content.Intent
import android.os.Bundle
import android.widget.RemoteViewsService
import android.net.Uri
import android.widget.RemoteViews
import android.os.Build


const val LAUNCH_ACTION = "com.bubulle.better_bus_v2";

class HomeWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        appWidgetIds.forEach { widgetId ->

            val intent = Intent(context, StackWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }

            var flags = android.app.PendingIntent.FLAG_UPDATE_CURRENT
            if (Build.VERSION.SDK_INT >= 23) {
                flags = flags or android.app.PendingIntent.FLAG_MUTABLE
            }

            var _intent = android.content.Intent(context, StackWidgetService::class.java).apply {
                action = "es.antonborri.home_widget.action.LAUNCH"
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                _intent,
                flags,
            )


            val myStopPendingIntent = getActivityPendingIntent(context, "app://openmystop")

            val views = RemoteViews(context.packageName, R.layout.widget_root_layout).apply {
                setRemoteAdapter(R.id.widget_list, intent)
                setEmptyView(R.id.widget_list, R.id.list_empty)
//                setPendingIntentTemplate(R.id.widget_list, pendingIntent)
                setOnClickPendingIntent(R.id.my_stop_button, myStopPendingIntent)
            }
            appWidgetManager.notifyAppWidgetViewDataChanged(widgetId, R.id.widget_list)
            appWidgetManager.updateAppWidget(widgetId, views)


        }
    }

    fun getActivityPendingIntent(context: Context, url: String): PendingIntent {
        val intent = Intent(context, MainActivity::class.java)
        intent.data = Uri.parse(url)

        var flags = PendingIntent.FLAG_UPDATE_CURRENT
        if (Build.VERSION.SDK_INT >= 23) {
            flags = flags or PendingIntent.FLAG_MUTABLE
        }

        if (Build.VERSION.SDK_INT < 34) {
            return PendingIntent.getActivity(context, 0, intent, flags)
        }

        val options = ActivityOptions.makeBasic()
        options.pendingIntentBackgroundActivityStartMode =
            ActivityOptions.MODE_BACKGROUND_ACTIVITY_START_ALLOWED

        return PendingIntent.getActivity(context, 0, intent, flags, options.toBundle())
    }
}

class StackWidgetService  : RemoteViewsService()
{
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return StackRemoteViewsFactory(this.applicationContext, intent)
    }

}


class StackRemoteViewsFactory(
    private val context: Context,
    val intent: Intent

) : RemoteViewsService.RemoteViewsFactory {

    private lateinit var shortcutNames: Array<String>
//    private lateinit var shortcutIds: Array<String>
    private val appWidgetId: Int = intent.getIntExtra(
        AppWidgetManager.EXTRA_APPWIDGET_ID,
        AppWidgetManager.INVALID_APPWIDGET_ID
    )



    override fun onCreate() {
        // In onCreate() you setup any connections / cursors to your data
        // source. Heavy lifting, for example downloading or creating content
        // etc, should be deferred to onDataSetChanged() or getViewAt(). Taking
        // more than 20 seconds in this call will result in an ANR.
        shortcutNames = intent.getStringArrayExtra("shortcuts") ?: emptyArray<String>()

    }

    override fun onDestroy() {
        // In onDestroy() you should tear down anything that was setup for your data source,
        // eg. cursors, connections, etc.
    }

    override fun getCount(): Int {
        return shortcutNames.size
    }

    override fun getViewAt(position: Int): RemoteViews {
        // Construct a remote views item based on the widget item XML file,
        // and set the text based on the position.


//        val uri: Uri = Uri.parse("app://openShortcut/${shortcutIds[position]}")
//
//        val fillInIntent: Intent = Intent().apply {
//            data = uri
//        }


        return RemoteViews(context.packageName, R.layout.widget_item).apply {
            setTextViewText(R.id.widget_item, shortcutNames[position])
//            setOnClickFillInIntent(R.id.widget_item, fillInIntent)
        }
    }

    override fun onDataSetChanged() {
        val widgetData: android.content.SharedPreferences = context.getSharedPreferences("WidgetData", Context.MODE_PRIVATE)
        println("GetUpdatedd")

        val rowShorcuts = widgetData.getString("favs", "") ?: ""
        println("Row Shortcuts")
        println(rowShorcuts)
        var shortcuts: Array<String> = rowShorcuts.split(";").toTypedArray()
//        val rowIds = widgetData.getString("shortcutsIds", "") ?: ""
//        var ids: Array<String> = rowIds.split(";").toTypedArray()
        if (shortcuts.size == 1 && shortcuts[0] == "")
        {
            shortcuts = emptyArray<String>()
        }
        shortcutNames = shortcuts
//        shortcutIds = ids
    }
    override fun getLoadingView(): RemoteViews? {
        // You can create a custom loading view (for instance when getViewAt() is slow.) If you
        // return null here, you will get the default loading view.
        return null
    }

    override fun getViewTypeCount(): Int {
        return 1
    }

    override fun getItemId(position: Int): Long {
        return position.toLong()
    }

    override fun hasStableIds(): Boolean {
        return true
    }
}
