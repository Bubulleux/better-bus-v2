package com.example.better_bus_v2


import android.app.Activity
import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.EventChannel
import android.content.ComponentName
import android.appwidget.AppWidgetManager


class MainActivity: FlutterActivity() {

    private val CHANNEL = "better.bus.poitier/homeWidget"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            if (call.method == "updateWidget") {
                val n = updateWidgets()
                print("Widget Updated")
                result.success(n)
            }
            result.notImplemented()
        }
    }

    fun updateWidgets(): IntArray {
        val widgetManager: AppWidgetManager = AppWidgetManager.getInstance(this)
        val ids: IntArray = widgetManager.getAppWidgetIds(ComponentName(this, HomeWidgetExampleProvider::class.java))
        if (ids.size > 0) {
            HomeWidgetExampleProvider().onUpdate(this, widgetManager, ids)
        }
        return ids
    }
}
