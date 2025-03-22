package com.example.kotlin_0318_update

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.ClipDescription
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.os.Build
import androidx.core.app.NotificationCompat

class AlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        if(intent != null){
            val description = intent.getStringExtra("description")
            val musicPath = intent.getStringExtra("musicPath")
            sendNotification(context,description!!)
            playSound(musicPath!!)
        }
    }

    private fun sendNotification(context: Context,description: String){
        val CHANNEL_ID = "通知頻道"
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if(Build.VERSION.SDK_INT >= 28){
            val channel = NotificationChannel(
                CHANNEL_ID,
                "通知頻道",
                NotificationManager.IMPORTANCE_HIGH
            )
            notificationManager.createNotificationChannel(channel)
        }
        val intent = Intent(context,MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(context, 5366, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)

        val notification = NotificationCompat.Builder(context,CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_launcher_foreground)
            .setContentTitle("聲景探險家")
            .setContentText(description)
            .setContentIntent(pendingIntent)
            .setPriority(NotificationManager.IMPORTANCE_HIGH)
            .setAutoCancel(true)
            .build()

        notificationManager.notify(6363,notification)
    }

    private fun playSound(musicPath:String){
        val mediaPlayer = MediaPlayer().apply {
            setDataSource(musicPath)
            setOnPreparedListener{
                start()
            }
            prepareAsync()
        }
        mediaPlayer.setOnCompletionListener {
            mediaPlayer.release()
        }
    }
}