
package com.bubulle.better_bus_v2
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.content.Context
import android.content.Intent
import android.content.ComponentName
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.util.Log


class HomeWidgetHandler : FlutterPlugin, MethodCallHandler{

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var receiver: BroadcastReceiver? = null
    private lateinit var context: Context


    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "home_widget")
        channel.setMethodCallHandler(this)

        context = binding.applicationContext
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "setWidgetData" -> {
                val prefs = context.getSharedPreferences("WidgetData", Context.MODE_PRIVATE).edit()
                val dataa : String = call.argument<String>("data") as String
                println("Ser data")
                println(dataa)
                prefs.putString("favs", dataa)
                result.success(prefs.commit())
            }
            "updateWidget" -> {

                Log.d("TAG", "UpdateWidget !!!!!!!!!!!!!!!!!!!")
                val widgetManager: AppWidgetManager = AppWidgetManager.getInstance(context.applicationContext)
                val ids: IntArray = widgetManager.getAppWidgetIds(ComponentName(context, HomeWidgetProvider::class.java))
                if (ids.size > 0) {
                    HomeWidgetProvider().onUpdate(context, widgetManager, ids)
                }
//                val intent = Intent(context, HomeWidgetProvider::class.java)
//                intent.action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
//                intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
//                context.sendBroadcast(intent)

                Log.d("TAG", "UpdateWidget  Success !!!!!!!!!!!!!!!!!!!")
                println("bonjour...")

                result.success(true)
            }
            else -> {
                result.notImplemented()
            }
        }
    }
}