
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
import android.net.Uri
import android.util.Log
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.PluginRegistry


class HomeWidgetHandler : FlutterPlugin, MethodCallHandler, ActivityAware,
    EventChannel.StreamHandler, PluginRegistry.NewIntentListener{

    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var receiver: BroadcastReceiver? = null
    private lateinit var context: Context
    private var activity: MainActivity? = null
    private var launchUri : Uri? = null


    override fun onAttachedToEngine(binding: FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "home_widget")
        channel.setMethodCallHandler(this)

        eventChannel = EventChannel(binding.binaryMessenger, "widgetLaunch")
        eventChannel.setStreamHandler(this)

        context = binding.applicationContext
        println("onCreate")
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        println("Attached To activity")
        if (binding.activity is MainActivity) {
            println("Attached To Main Activity")
            activity = binding.activity as MainActivity
            binding.addOnNewIntentListener(this)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        println("Re-Attached To activity")
        if (binding.activity is MainActivity) {
            println("Re-Attached To Main Activity")
            activity = binding.activity as MainActivity
            binding.addOnNewIntentListener(this)
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
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
            "getLaunchUri" -> {
                if (launchUri is Uri) {
                    result.success(launchUri.toString())
                } else {
                    result.success(null)
                }

            }
            else -> {
                result.notImplemented()
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                if (intent.action == LAUNCH_ACTION) {
                    events?.success(intent.data.toString())
                }
            }
        }
    }

    override fun onCancel(arguments: Any?) {
        receiver = null
    }

    override fun onNewIntent(intent: Intent) : Boolean{
        println("New Intent")
        println(intent.action)
        println(receiver)
        println(intent.data)
        if (receiver != null && intent.action == LAUNCH_ACTION && intent.data is Uri) {
            launchUri = intent.data as Uri
            println("App launch with ")
            println(intent.action)
            println(intent.data)
            receiver!!.onReceive(context, intent)
            return true
        }
        return false
    }

}