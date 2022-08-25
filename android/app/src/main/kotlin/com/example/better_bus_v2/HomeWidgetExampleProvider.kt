package com.example.better_bus_v2

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.content.Intent
import android.os.Bundle
import android.widget.RemoteViewsService
import android.net.Uri
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import android.widget.RemoteViews
import android.os.Build




class HomeWidgetExampleProvider : HomeWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->

            val rowShorcuts = widgetData.getString("shortcuts", "1;2;3") ?: ""
            val shortcuts: Array<String> = rowShorcuts.split(";").toTypedArray()
            val intent = Intent(context, StackWidgetService::class.java).apply {
                // Add the widget ID to the intent extras.
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId)
                putExtra("shortcuts", shortcuts)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }

//            val pendingIntent = HomeWidgetLaunchIntent.getActivity(
//                context,
//                MainActivity::class.java,
//            )
            var flags = PendingIntent.FLAG_UPDATE_CURRENT

            var _intent = android.content.Intent(context, MainActivity::class.java).apply {
                action = "es.antonborri.home_widget.action.LAUNCH"
                data = null
            }
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                _intent,
                flags,
            )

            val views = RemoteViews(context.packageName, R.layout.example_layout).apply {
                setTextViewText(R.id.widget_title, _intent.type.toString())
                setPendingIntentTemplate(R.id.widget_list, pendingIntent)
                setRemoteAdapter(R.id.widget_list, intent)


            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
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
    private val appWidgetId: Int = intent.getIntExtra(
        AppWidgetManager.EXTRA_APPWIDGET_ID,
        AppWidgetManager.INVALID_APPWIDGET_ID
    )



    override fun onCreate() {
        // In onCreate() you setup any connections / cursors to your data
        // source. Heavy lifting, for example downloading or creating content
        // etc, should be deferred to onDataSetChanged() or getViewAt(). Taking
        // more than 20 seconds in this call will result in an ANR.
        print("Coucou")
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


        val uri: Uri = Uri.parse("app://openShortcut/${shortcutNames[position]}")

        val fillInIntent: Intent = Intent().apply {
            data = uri
        }
//        val pendingIntent = HomeWidgetLaunchIntent.getActivity(
//            context,
//            MainActivity::class.java,
//            uri
//        )

//        val fillInIntent = HomeWidgetLaunchIntent.getActivity(
//            context,
//            MainActivity::class.java,
//            Uri.parse("app://open-shortcut/${shortcutNames[position]}"))


        return RemoteViews(context.packageName, R.layout.widget_item).apply {
            setTextViewText(R.id.widget_item, shortcutNames[position])
            setOnClickFillInIntent(R.id.widget_item, fillInIntent)
//            setOnClickPendingIntent(R.id.widget_item, pendingIntent)
        }
    }

    override fun onDataSetChanged() {
        // This is triggered when you call AppWidgetManager notifyAppWidgetViewDataChanged
        // on the collection view corresponding to this factory. You can do heaving lifting in
        // here, synchronously. For example, if you need to process an image, fetch something
        // from the network, etc., it is ok to do it here, synchronously. The widget will remain
        // in its current state while work is being done here, so you don't need to worry about
        // locking up the widget.
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
