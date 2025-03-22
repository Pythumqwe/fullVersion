package com.example.kotlin_0318_update

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.os.Looper
import android.widget.RemoteViews
import android.os.Handler
import com.example.kotlin_0318_update.MainActivity.Companion
import java.io.File


class SoundPlayer : AppWidgetProvider() {
    companion object{
        private var mediaPlayer : MediaPlayer? = null
        private var handler = Handler(Looper.getMainLooper())

        private val musics = mutableListOf<File>()
        private var isSoundPlaying = false
        private var currentIndex = 0
    }
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName,R.layout.sound_player)

            val c_Intent = Intent(context,SoundPlayer::class.java).apply { action = "CONTROL" }
            val c_PendingIntent = PendingIntent.getBroadcast(context,5082,c_Intent,PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
            views.setOnClickPendingIntent(R.id.widget_control_btn,c_PendingIntent)

            val l_Intent = Intent(context,SoundPlayer::class.java).apply { action = "LAST" }
            val l_PendingIntent = PendingIntent.getBroadcast(context,5082,l_Intent,PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
            views.setOnClickPendingIntent(R.id.widget_last_btn,l_PendingIntent)

            val n_Intent = Intent(context,SoundPlayer::class.java).apply { action = "NEXT" }
            val n_PendingIntent = PendingIntent.getBroadcast(context,5082,n_Intent,PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
            views.setOnClickPendingIntent(R.id.widget_next_btn,n_PendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId,views)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (musics.size != 10) getMusicFromStorage(context);
        if(mediaPlayer == null) setUpMusic(context)
        when(intent.action){
            "CONTROL" ->{
                musicControl(context)
                print(mediaPlayer)
            }
            "LAST" ->
                changeMusic(context,-1);
            "NEXT" ->
                changeMusic(context,1)
        }
    }

    private fun getMusicFromStorage(context: Context){
        val privateStorage = context.filesDir
        val musicFile = File(privateStorage,"Musics")

        if(musicFile.exists()){
            musics.clear()
            for (item in musicFile.listFiles()){
                musics.add(item)
            }
        }
    }

    private fun setUpMusic(context: Context){
        val views = RemoteViews(context.packageName,R.layout.sound_player)
        if(mediaPlayer != null){
            mediaPlayer?.pause()
            mediaPlayer?.release()
            isSoundPlaying = false
            views.setTextViewText(R.id.widget_control_btn,"play")
        }
        mediaPlayer = MediaPlayer().apply {
            setDataSource(musics[currentIndex].absolutePath)
            setOnPreparedListener{
                updateTime(context)
                isLooping = true
            }
            prepareAsync()
        }
    }

    private fun changeMusic(context: Context,newV:Int){
        currentIndex = (currentIndex + newV + musics.size) % musics.size
        setUpMusic(context)
    }

    private fun musicControl(context: Context){
        if (!isSoundPlaying){
            mediaPlayer?.start()
            updateTime(context)
        }else{
            mediaPlayer?.pause()

        }
        isSoundPlaying = !isSoundPlaying
    }

    private fun formatTime(ms:Int): String{
        val second = (ms / 1000) % 60
        val minute = (ms / 1000) / 60
        return String.format("%02d:%02d",minute,second)
    }

    private fun updateTime(context: Context){
        val views = RemoteViews(context.packageName,R.layout.sound_player)
        val componentName = ComponentName(context,SoundPlayer::class.java)
        val appWidgetManager = AppWidgetManager.getInstance(context)
        handler.postDelayed(object : Runnable{
            override fun run() {
                mediaPlayer?.let {
                    val currentTime = formatTime(it.currentPosition)
                    val totalTime = formatTime(it.duration)
                    views.setTextViewText(R.id.widget_left_time_show,"$currentTime / $totalTime")
                    views.setTextViewText(R.id.widget_control_btn, if (isSoundPlaying) "pause" else "play")

                    appWidgetManager.updateAppWidget(componentName,views)

                    if (it.isPlaying){
                        handler.postDelayed(this,300)
                    }
                }
            }
        },0)
    }

    override fun onDisabled(context: Context) {

    }
}

