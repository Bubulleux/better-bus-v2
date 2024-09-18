package com.bubulle.better_bus_v2


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
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import com.bubulle.better_bus_v2.HomeWidgetHandler
import io.flutter.embedding.engine.plugins.PluginRegistry
import com.bubulle.better_bus_v2.HomeWidgetProvider


class MainActivity: FlutterActivity() {

    private val CHANNEL = "better.bus.poitier/homeWidget"
    private lateinit var plugin: PluginRegistry
//    private lateinit var context: Context

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        plugin = flutterEngine.getPlugins();

        plugin.add(HomeWidgetHandler())
    }
}
