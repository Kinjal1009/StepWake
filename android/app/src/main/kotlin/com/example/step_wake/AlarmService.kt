package com.example.step_wake

import android.app.NotificationManager
import android.app.NotificationChannel
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import android.media.MediaPlayer
import android.content.pm.ServiceInfo

class AlarmService : Service() {
    private var mediaPlayer: MediaPlayer? = null
    private val CHANNEL_ID = "step_wake_native_alarm_channel"
    private val NOTIFICATION_ID = 12345
    
    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val alarmId = intent?.getIntExtra("ALARM_ID", 0) ?: 0
        
        createNotificationChannel()
        
        // Intent for Lock Screen / Full Screen (Default behavior: Ringing Screen)
        val fullScreenIntent = Intent(this, MainActivity::class.java).apply {
            setFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("ALARM_ID", alarmId)
            putExtra("TRIGGERED_FROM_ALARM", true)
        }
        
        val fullScreenPendingIntent = PendingIntent.getActivity(
            this,
            alarmId,
            fullScreenIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        // Intent for "Start Walking" Action Button (Direct to Challenge)
        val startWalkingIntent = Intent(this, MainActivity::class.java).apply {
            setFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            putExtra("ALARM_ID", alarmId)
            putExtra("TRIGGERED_FROM_ALARM", true)
            putExtra("START_CHALLENGE", true) // Signal to start challenge immediately
        }

        val startWalkingPendingIntent = PendingIntent.getActivity(
            this,
            alarmId + 1000, // Different Request Code to ensure distinct PendingIntent
            startWalkingIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Notification Builder
        val notificationBuilder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.mipmap.launcher_icon) // Use custom icon
            .setContentTitle("IT'S TIME TO WAKE UP!") // Engaging title
            .setContentText("Tap to start walking challenge")
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            // Use fullScreenIntent to show the UI on lock screen too
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setContentIntent(fullScreenPendingIntent)
            .setAutoCancel(false)
            .setOngoing(true)
            .setSound(null) // We play sound manually
            // Add Start Walking Action Button
            .addAction(android.R.drawable.ic_menu_directions, "START WALKING", startWalkingPendingIntent)
            .setColor(0xFFFF0000.toInt()) // Red accent color for visibility
            .setLights(0xFFFF0000.toInt(), 500, 500)
        
        // Start Foreground Service
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
             startForeground(NOTIFICATION_ID, notificationBuilder.build(), ServiceInfo.FOREGROUND_SERVICE_TYPE_MEDIA_PLAYBACK)
        } else {
             startForeground(NOTIFICATION_ID, notificationBuilder.build())
        }
        
        startRinging()
        
        return START_STICKY
    }
    
    private fun startRinging() {
        if (mediaPlayer != null && mediaPlayer!!.isPlaying) return
        
        try {
            // Using custom ringtone from R.raw.alarm
            mediaPlayer = MediaPlayer.create(this, R.raw.alarm).apply {
                isLooping = true
                start()
            }
        } catch (e: Exception) {
            e.printStackTrace()
            // Fallback if needed
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        stopRinging()
        stopForeground(true) // Ensure notification is removed
    }
    
    private fun stopRinging() {
        mediaPlayer?.let {
            if (it.isPlaying) {
                it.stop()
            }
            it.release()
        }
        mediaPlayer = null
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "StepWake Alarms"
            val descriptionText = "Full screen alarm notifications"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(CHANNEL_ID, name, importance).apply {
                description = descriptionText
                setSound(null, null) // Manage sound manually
                enableVibration(true)
            }
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
