package com.example.kotlin_0318_update

import android.app.AlarmManager
import android.app.PendingIntent
import android.app.TimePickerDialog
import android.content.Intent
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.widget.Button
import android.widget.ImageView
import android.widget.NumberPicker
import android.widget.SeekBar
import android.widget.TextView
import android.widget.TimePicker
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import coil.load
import com.google.gson.Gson
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.io.OutputStreamWriter
import java.util.Calendar
import java.util.TimeZone
import java.util.concurrent.TimeUnit


class MainActivity : AppCompatActivity() {
    private lateinit var musicImage : ImageView
    private lateinit var controlBtn: Button
    private lateinit var lastMusicBtn: Button
    private lateinit var nextMusicBtn: Button
    private lateinit var setAlarmBtn: Button
    private lateinit var progressBar : SeekBar
    private lateinit var leftTimeShow : TextView
    private lateinit var musicTitle : TextView
    companion object{
        private var mediaPlayer : MediaPlayer? = null
        private val handler = Handler(Looper.getMainLooper())

        private lateinit var musics : MutableList<File>
        private var isSoundPlaying = false
        private var currentIndex = 0
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        //=============================================================//
        musicImage = findViewById(R.id.musicImage)
        controlBtn = findViewById(R.id.controlBtn)
        lastMusicBtn = findViewById(R.id.lastMusicBtn)
        nextMusicBtn = findViewById(R.id.nextMusicBtn)
        setAlarmBtn = findViewById(R.id.setAlarmBtn)
        progressBar = findViewById(R.id.mediaProgress)
        leftTimeShow = findViewById(R.id.leftTimeShow)
        musicTitle = findViewById(R.id.musicTitle)

        musics = mutableListOf()
        //=============================================================//
        requestPermission()
        getMusicFromStorage()
        initMusic()

        controlBtn.setOnClickListener{
            musicControl()
        }
        nextMusicBtn.setOnClickListener{
            changeMusic(1)
        }
        lastMusicBtn.setOnClickListener{
            changeMusic(-1)
        }
        setAlarmBtn.setOnClickListener{
            showNumberPicker()
        }

        progressBar.setOnSeekBarChangeListener(object : SeekBar.OnSeekBarChangeListener{
            override fun onStartTrackingTouch(p0: SeekBar?) {}
            override fun onStopTrackingTouch(p0: SeekBar?) {}
            override fun onProgressChanged(p0: SeekBar?, p1: Int, p2: Boolean) {
                if(p2) mediaPlayer?.seekTo(p1)
            }
        })




    }
    //=================================================================//

    private fun requestPermission(){
        val permission = arrayOf(
            android.Manifest.permission.POST_NOTIFICATIONS
        )

        if (Build.VERSION.SDK_INT >= 33){
            ActivityCompat.requestPermissions(this,permission,2352)
        }
    }

    private fun fetchApiData(){
        val privateStorage = filesDir
        val musicDirectory = File(privateStorage, "Musics")

        if(!musicDirectory.exists() && musicDirectory.mkdirs()) throw IOException("")

        val client = OkHttpClient.Builder()
            .connectTimeout(20,TimeUnit.SECONDS)
            .readTimeout(20,TimeUnit.SECONDS)
            .build()

        val request = Request.Builder()
            .url("https://api.jamendo.com/v3.0/tracks/?client_id=9c132dac&format=json&limit=10")
            .build()

        client.newCall(request).execute().use {
            if(!it.isSuccessful){
                throw IOException("")
            }

            val json = it.body?.string()
            val musicList = Gson().fromJson(json,Music::class.java)

            for (item in musicList.results){
                downloadMusic(musicDirectory,item.audiodownload,item.name)
                downloadImage(privateStorage,item.image)
            }

            runOnUiThread {
                setUpMusic()
            }
        }
    }

    private fun downloadMusic(parentFile: File,url: String,fileName: String){
        val outputFile = File(parentFile,fileName)
        if (outputFile.exists()){
            println("music founded, path: ${outputFile.absolutePath}")
            return
        }

        val client = OkHttpClient.Builder()
            .connectTimeout(20,TimeUnit.SECONDS)
            .readTimeout(20,TimeUnit.SECONDS)
            .build()

        val request = Request.Builder()
            .url(url)
            .build()

        client.newCall(request).execute().use {
            if(!it.isSuccessful){
                throw IOException("")
            }

            val inputStream = it.body?.byteStream() ?: throw IOException("")
            val outputStream = outputFile.outputStream()

            inputStream.copyTo(outputStream)

            inputStream.close()
            outputStream.close()

            println("download success, path: ${outputFile.absolutePath}")
        }
    }

    private fun downloadImage(parentFile: File,url: String){
        val targetFile = File(parentFile,"Images.txt")
        if(targetFile.exists()){
            val content = targetFile.readLines()
            if(content.contains(url)){
                println("image has been saved")
                return
            }
        }

        val outputStream = FileOutputStream(targetFile,true)
        val outputStreamWriter = OutputStreamWriter(outputStream)

        outputStreamWriter.write("$url\n")

        outputStreamWriter.close()
        outputStream.close()


        println("image download success")
    }

    private fun getMusicFromStorage(){
        val privateStorage = filesDir
        val musicFile = File(privateStorage,"Musics")

        if(musicFile.exists()){
            musics.clear()
            for (item in musicFile.listFiles()){
                musics.add(item)
            }
        }
    }

    private fun initMusic(){
        val imageFile = File(filesDir,"Images.txt")
        if (musics.size == 10 && imageFile.readLines().size == 10) setUpMusic()
        else fetchApiData()
    }

    private fun setUpMusic(){
        if(mediaPlayer != null){
            mediaPlayer?.pause()
            mediaPlayer?.release()
            isSoundPlaying = false
            controlBtn.text = "Play"
        }
        mediaPlayer = MediaPlayer().apply {
            setDataSource(musics[currentIndex].absolutePath)
            setOnPreparedListener{
                progressBar.max = it.duration
                isLooping = true

                runOnUiThread {
                    updateProgress()
                    musicTitle.text = musics[currentIndex].name
                    musicImage.load(getImageFromStorage(currentIndex))
                }
            }
            prepareAsync()
        }
    }

    private fun musicControl(){
        if(!isSoundPlaying){
            mediaPlayer?.start()
            updateProgress()
            controlBtn.text = "Pause"
        }else{
            mediaPlayer?.pause()
            controlBtn.text = "Play"
        }
        isSoundPlaying = !isSoundPlaying
    }

    private fun changeMusic(v:Int){
        currentIndex = (currentIndex + v + musics.size) % musics.size
        setUpMusic()
    }

    private fun formatTime(ms:Int): String{
        val second = (ms / 1000) % 60
        val minute = (ms / 1000) / 60
        return String.format("%02d:%02d",minute,second)
    }

    private fun updateProgress(){
        handler.postDelayed(object : Runnable{
            override fun run() {
                mediaPlayer?.let {
                    progressBar.progress = it.currentPosition
                    val currentTime = formatTime(it.currentPosition)
                    val totalTime = formatTime(it.duration)
                    leftTimeShow.text = "$currentTime / $totalTime"


                    if(it.isPlaying){
                        handler.postDelayed(this,500)
                    }
                }
            }
        },0)
    }

    private fun getImageFromStorage(index: Int):String{
        val musicFile = File(filesDir,"Images.txt")
        if (musicFile.exists()){
            val content = musicFile.readLines()
            return content[index]
        }
        return "N/A"
    }

    private fun setAlarm(hour:Int,minute:Int){
        val currentTime = System.currentTimeMillis()
        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager

        val calendar = Calendar.getInstance(TimeZone.getTimeZone("Asia/Taipei"))
        calendar.set(Calendar.HOUR_OF_DAY,hour)
        calendar.set(Calendar.MINUTE,minute)
        calendar.set(Calendar.SECOND,0)

        if(calendar.timeInMillis <= currentTime){
            calendar.add(Calendar.DAY_OF_MONTH,1)
        }

        val intent = Intent(this,AlarmReceiver::class.java)

        when(hour){
            in 0..11 ->
                intent.putExtra("description","早上好")
            in 12..14 ->
                intent.putExtra("description","中午好")
            in 15..18 ->
                intent.putExtra("description","下午好")
            in 19..23 ->
                intent.putExtra("description","晚上好")
        }
        when(hour){
            in 0..11 ->
                intent.putExtra("musicPath", musics[0].absolutePath)
            in 12..14 ->
                intent.putExtra("musicPath",musics[1].absolutePath)
            in 15..18 ->
                intent.putExtra("musicPath",musics[2].absolutePath)
            in 19..23 ->
                intent.putExtra("musicPath",musics[3].absolutePath)
        }

        val pendingIntent = PendingIntent.getBroadcast(
            this,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )

        if(Build.VERSION.SDK_INT >= 31){
            if(!alarmManager.canScheduleExactAlarms()){
                startActivity(Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM))
            }
        }


        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            calendar.timeInMillis,
            pendingIntent
        )
    }

    private fun showNumberPicker(){
        val calendar = Calendar.getInstance()
        val hour = calendar.get(Calendar.HOUR_OF_DAY)
        val min = calendar.get(Calendar.MINUTE)

        val timePickerDialog = TimePickerDialog(
            this,
            {_,h,m -> setAlarm(h,m)}
            ,hour,
            min,
            true
        )

        timePickerDialog.show()

    }

}



data class MusicItem(
    val name : String,
    val audiodownload : String,
    val image : String
)


data class Music(
    val results : List<MusicItem>
)










