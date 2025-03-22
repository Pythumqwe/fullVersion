package com.example.flutter_03_18_update

import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(),SensorEventListener {
    private lateinit var sensorManager: SensorManager
    private var lastShake : Long = 0
    private val shakeThreshold = 12.0f
    private val CHANNEL_ID = "shake_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        sensorManager = getSystemService(SENSOR_SERVICE) as SensorManager
        val accelerometer = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER)
        sensorManager.registerListener(this,accelerometer,SensorManager.SENSOR_DELAY_UI)
    }

    override fun onSensorChanged(p0: SensorEvent?) {
        p0.let {
            val x = it!!.values[0]
            val y = it.values[1]
            val z = it.values[2]
            val acceleration = Math.sqrt((x * x + y * y + z * z).toDouble()).toFloat()
            if (acceleration > shakeThreshold) {
                val currentTime = System.currentTimeMillis()
                if (currentTime - lastShake >= 1000) {
                    lastShake = currentTime
                    fireFlutter()
                }
            }
        }
    }

    private fun fireFlutter(){
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger,CHANNEL_ID).invokeMethod("onShake",null)
    }

    override fun onAccuracyChanged(p0: Sensor?, p1: Int) {}

    override fun onDestroy() {
        super.onDestroy()
        sensorManager.unregisterListener(this)
    }

}