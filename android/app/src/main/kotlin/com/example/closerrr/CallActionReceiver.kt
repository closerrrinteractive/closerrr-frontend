package com.sharkbrewsinternational.closerrr

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import android.app.NotificationManager

class CallActionReceiver : BroadcastReceiver() {
  override fun onReceive(context: Context, intent: Intent) {
    val action = intent.action
    val callData = intent.getStringExtra("call_data") ?: "{}"

    val notificationManager =
      context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
    notificationManager.cancel(1)

    Log.d("CALL_RECEIVER", "Action: $action with data: $callData")

    // Always launch MainActivity with pending action (works for terminated state too)
    val launchIntent = Intent(context, MainActivity::class.java).apply {
      putExtra("pending_action", action)
      putExtra("call_data", callData)
      flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
    }
    context.startActivity(launchIntent)
  }
}
