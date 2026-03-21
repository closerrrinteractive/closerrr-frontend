package com.sharkbrewsinternational.closerrr

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.os.Bundle
import io.flutter.plugin.common.MethodChannel
import android.os.Build
import android.Manifest
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import android.app.NotificationManager
import android.content.Context
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache

class MainActivity : FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    requestNotificationPermission()
    handleIntent(intent)
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    FlutterEngineCache.getInstance().put("main_engine", flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "call_channel")
      .setMethodCallHandler { call, result ->
        if (call.method == "dismissNotification") {
          val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
          manager.cancel(1)
          result.success(null)
        }
      }
  }

  private fun requestNotificationPermission() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
      val permissionCheck = ContextCompat.checkSelfPermission(
        this, Manifest.permission.POST_NOTIFICATIONS
      )
      if (permissionCheck != PackageManager.PERMISSION_GRANTED) {
        ActivityCompat.requestPermissions(
          this,
          arrayOf(Manifest.permission.POST_NOTIFICATIONS),
          1001
        )
      }
    }
  }

  override fun onNewIntent(intent: Intent) {
    super.onNewIntent(intent)
    handleIntent(intent)
  }

  private fun handleIntent(intent: Intent) {
    val action = intent.getStringExtra("pending_action")
    val callData = intent.getStringExtra("call_data")

    if (action != null && callData != null) {
      MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, "call_channel")
        .invokeMethod(
          when (action) {
            "JOIN_LIVE_ACTION" -> "onCallAnswered"
            "DISMISS_ACTION" -> "onCallDeclined"
            else -> return
          },
          callData // JSON string → decode in Dart
        )
    }
  }
}
