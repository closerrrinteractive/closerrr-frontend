package com.sharkbrewsinternational.closerrr

import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import android.app.PendingIntent
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import android.util.Log
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import org.json.JSONObject

class MyFirebaseMessagingService : FirebaseMessagingService() {
  override fun onMessageReceived(remoteMessage: RemoteMessage) {
    if (remoteMessage.data["type"] == "call") {
      showIncomingCallNotification(remoteMessage)
    }
  }

  private fun createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val channel = NotificationChannel(
        "call_channel",
        "Call Notifications",
        NotificationManager.IMPORTANCE_HIGH
      ).apply {
        description = "Used for incoming call notifications"
        enableVibration(true)
      }

      val manager = getSystemService(NotificationManager::class.java)
      manager?.createNotificationChannel(channel)
    }
  }

  private fun showIncomingCallNotification(remoteMessage: RemoteMessage) {
    createNotificationChannel()
    val data = remoteMessage.data

    // Convert data map to JSON string (safe for passing via Intent)
    val callDataJson = JSONObject(data as Map<*, *>).toString()

    // Intent for opening app when tapping notification
    val intent = Intent(this, MainActivity::class.java).apply {
      putExtra("callerId", data["callerId"])
      flags = Intent.FLAG_ACTIVITY_NEW_TASK
    }

    // Activity Intent when user explicitly taps "Join Live"
    val joinIntent = Intent(this, MainActivity::class.java).apply {
      putExtra("route", "/stream_call")
      putExtra("callerId", data["callerId"])
      putExtra("callerName", data["callerName"])
      flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
    }
    val joinPendingIntent = PendingIntent.getActivity(
      this, 0, joinIntent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
    )

    // Answer action → CallActionReceiver
    val joinLiveIntent = Intent(this, CallActionReceiver::class.java).apply {
      action = "JOIN_LIVE_ACTION"
      putExtra("call_data", callDataJson) // ✅ JSON string
    }

    // Decline action → CallActionReceiver
    val dismissIntent = Intent(this, CallActionReceiver::class.java).apply {
      action = "DISMISS_ACTION"
      putExtra("call_data", callDataJson) // ✅ JSON string
    }

    val joinLive = PendingIntent.getBroadcast(
      this, 0, joinLiveIntent, PendingIntent.FLAG_IMMUTABLE
    )
    val dismiss = PendingIntent.getBroadcast(
      this, 1, dismissIntent, PendingIntent.FLAG_IMMUTABLE
    )

    val notification = NotificationCompat.Builder(this, "call_channel")
      .setContentTitle("Incoming Call")
      .setContentText("Call from ${data["callerName"]}")
      .setSmallIcon(R.mipmap.ic_launcher)
      .addAction(R.drawable.ic_answer, "Join Live", joinLive) // ✅ fixed to broadcast
      .addAction(R.drawable.ic_decline, "Dismiss", dismiss)
      .setFullScreenIntent(joinPendingIntent, true)
      .setPriority(NotificationCompat.PRIORITY_HIGH)
      .setCategory(NotificationCompat.CATEGORY_CALL)
      .setAutoCancel(true)
      .setDefaults(NotificationCompat.DEFAULT_ALL)
      .build()

    NotificationManagerCompat.from(this).notify(1, notification)
  }
}
