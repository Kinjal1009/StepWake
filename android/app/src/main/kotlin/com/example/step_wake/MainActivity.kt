package com.example.step_wake

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.view.WindowManager
import android.os.Build
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.step_wake/alarm"
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    val id = call.argument<Int>("id") ?: 0
                    // Safely handle number types (Integer or Long) from Dart
                    val delayMillisObj = call.argument<Any>("delayMillis")
                    val delayMillis = (delayMillisObj as? Number)?.toLong() ?: 0L
                    scheduleAlarm(id, delayMillis)
                    result.success(null)
                }
                "stopAlarm" -> {
                    stopNativeAlarm()
                    result.success(null)
                }
                "checkLaunchIntent" -> {
                     val triggered = intent.getBooleanExtra("TRIGGERED_FROM_ALARM", false)
                     val startChallenge = intent.getBooleanExtra("START_CHALLENGE", false)
                     val alarmId = intent.getIntExtra("ALARM_ID", 0)
                     result.success(mapOf("triggered" to triggered, "startChallenge" to startChallenge, "alarmId" to alarmId))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scheduleAlarm(id: Int, delayMillis: Long) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra("ALARM_ID", id)
        }
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            id,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val triggerTime = System.currentTimeMillis() + delayMillis
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, triggerTime, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, triggerTime, pendingIntent)
        }
    }
    
    private fun stopNativeAlarm() {
        val stopIntent = Intent(this, AlarmService::class.java)
        stopService(stopIntent)
    }



    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleAlarmIntent(intent)
    }
    
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        this.intent = intent
        handleAlarmIntent(intent)

        // Check if new intent is alarm trigger for Flutter side logic
        if (intent.getBooleanExtra("TRIGGERED_FROM_ALARM", false)) {
            val startChallenge = intent.getBooleanExtra("START_CHALLENGE", false)
            val alarmId = intent.getIntExtra("ALARM_ID", 0)
            // Notify Flutter somehow, or let Flutter component poll/re-check
             flutterEngine?.dartExecutor?.binaryMessenger?.let { messenger ->
                MethodChannel(messenger, CHANNEL).invokeMethod("alarmTriggered", mapOf("startChallenge" to startChallenge, "alarmId" to alarmId))
            }
        }
    }

    private fun handleAlarmIntent(intent: Intent) {
        if (intent.getBooleanExtra("TRIGGERED_FROM_ALARM", false)) {
             if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                setShowWhenLocked(true)
                setTurnScreenOn(true)
            }
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
            )
        }
    }
}
