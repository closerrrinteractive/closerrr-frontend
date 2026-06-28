package com.sharkbrewsinternational.closerrr

import io.flutter.embedding.android.FlutterFragmentActivity
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
import android.media.MediaScannerConnection
import android.os.Environment
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.lang.Exception
import android.media.RingtoneManager
import android.net.Uri
import android.app.Activity
import android.os.Vibrator
import android.os.VibrationEffect

class MainActivity : FlutterFragmentActivity() {
  private var pendingRingtoneResult: MethodChannel.Result? = null
  private var mediaPlayer: android.media.MediaPlayer? = null

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    requestNotificationPermission()
    handleIntent(intent)
  }

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    FlutterEngineCache.getInstance().put("main_engine", flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.closerrr.app/ringtone_picker")
      .setMethodCallHandler { call, result ->
        if (call.method == "pickRingtone") {
          pendingRingtoneResult = result
          val intent = Intent(RingtoneManager.ACTION_RINGTONE_PICKER).apply {
            putExtra(RingtoneManager.EXTRA_RINGTONE_TYPE, RingtoneManager.TYPE_NOTIFICATION)
            putExtra(RingtoneManager.EXTRA_RINGTONE_TITLE, "Select Notification Tone")
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_DEFAULT, true)
            putExtra(RingtoneManager.EXTRA_RINGTONE_SHOW_SILENT, true)
          }
          startActivityForResult(intent, 2001)
        } else if (call.method == "playCustomPreview") {
          val soundName = call.argument<String>("soundName")
          if (soundName != null) {
            val resId = resources.getIdentifier(soundName, "raw", packageName)
            if (resId != 0) {
              try {
                mediaPlayer?.stop()
                mediaPlayer?.release()
              } catch (e: Exception) {}
              mediaPlayer = android.media.MediaPlayer.create(this, resId)
              mediaPlayer?.start()
              result.success(null)
            } else {
              result.error("NOT_FOUND", "Sound resource not found: $soundName", null)
            }
          } else {
            result.error("INVALID_ARGUMENTS", "soundName is required", null)
          }
        } else if (call.method == "playSystemSound") {
          try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
          } catch (e: Exception) {}
          val notificationUri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
          mediaPlayer = android.media.MediaPlayer.create(this, notificationUri)
          mediaPlayer?.start()
          result.success(null)
        } else if (call.method == "stopPreview") {
          try {
            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null
          } catch (e: Exception) {}
          result.success(null)
        } else {
          result.notImplemented()
        }
      }

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.closerrr.app/vibrator")
      .setMethodCallHandler { call, result ->
        if (call.method == "vibrate") {
          val duration = call.argument<Number>("duration")?.toLong() ?: 100L
          val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vibratorManager = getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as android.os.VibratorManager
            vibratorManager.defaultVibrator.vibrate(VibrationEffect.createOneShot(duration, VibrationEffect.DEFAULT_AMPLITUDE))
          } else {
            @Suppress("DEPRECATION")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
              vibrator.vibrate(VibrationEffect.createOneShot(duration, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
              vibrator.vibrate(duration)
            }
          }
          result.success(null)
        } else {
          result.notImplemented()
        }
      }

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "call_channel")
      .setMethodCallHandler { call, result ->
        if (call.method == "dismissNotification") {
          val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
          manager.cancel(1)
          result.success(null)
        }
      }

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.closerrr.app/gallery")
      .setMethodCallHandler { call, result ->
        if (call.method == "saveFileToGallery") {
          val path = call.argument<String>("path")
          if (path != null) {
            saveFileToGallery(path, result)
          } else {
            result.error("INVALID_ARGUMENTS", "Path is required", null)
          }
        } else {
          result.notImplemented()
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

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    if (requestCode == 2001) {
      if (resultCode == Activity.RESULT_OK) {
        val uri = data?.getParcelableExtra<Uri>(RingtoneManager.EXTRA_RINGTONE_PICKED_URI)
        if (uri != null) {
          val ringtone = RingtoneManager.getRingtone(this, uri)
          val title = ringtone.getTitle(this)
          val resultData = mapOf("uri" to uri.toString(), "title" to title)
          pendingRingtoneResult?.success(resultData)
        } else {
          val resultData = mapOf("uri" to "", "title" to "System Default")
          pendingRingtoneResult?.success(resultData)
        }
      } else {
        pendingRingtoneResult?.success(null)
      }
      pendingRingtoneResult = null
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

  private fun saveFileToGallery(path: String, result: MethodChannel.Result) {
    val sourceFile = File(path)
    if (!sourceFile.exists()) {
      result.error("FILE_NOT_FOUND", "Source file does not exist", null)
      return
    }

    try {
      val ext = sourceFile.extension.lowercase()
      val isVideo = ext == "mp4" || ext == "3gp" || ext == "mov"
      val directory = if (isVideo) {
        Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_MOVIES)
      } else {
        Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
      }

      if (!directory.exists()) {
        directory.mkdirs()
      }

      val destFile = File(directory, sourceFile.name)
      FileInputStream(sourceFile).use { input ->
        FileOutputStream(destFile).use { output ->
          input.copyTo(output)
        }
      }

      MediaScannerConnection.scanFile(
        context,
        arrayOf(destFile.absolutePath),
        null
      ) { _, uri ->
        activity.runOnUiThread {
          if (uri != null) {
            result.success(true)
          } else {
            result.error("SCAN_FAILED", "Failed to scan file", null)
          }
        }
      }
    } catch (e: Exception) {
      result.error("SAVE_FAILED", e.message, null)
    }
  }
}
