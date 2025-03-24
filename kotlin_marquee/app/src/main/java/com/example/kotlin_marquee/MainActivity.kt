package com.example.kotlin_marquee

import android.animation.ObjectAnimator
import android.animation.ValueAnimator
import android.content.res.Resources
import android.graphics.Color
import android.os.Bundle
import android.provider.CalendarContract.Colors
import android.renderscript.Sampler.Value
import android.text.Editable
import android.text.TextWatcher
import android.view.animation.LinearInterpolator
import android.widget.Button
import android.widget.EditText
import android.widget.SeekBar
import android.widget.TextView
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import org.w3c.dom.Text

class MainActivity : AppCompatActivity() {
    private lateinit var marqueeText : TextView
    private lateinit var textSizeHint : TextView
    private lateinit var input : EditText
    private lateinit var textSizeController : SeekBar
    private lateinit var setColorBtn : Button
    companion object{
        private lateinit var marqueeAnimation : ObjectAnimator
    }
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        marqueeText = findViewById(R.id.marqueeText)
        textSizeHint = findViewById(R.id.hint1)
        input = findViewById(R.id.input)
        textSizeController = findViewById(R.id.marqueeTextSizeController)
        setColorBtn = findViewById(R.id.setColorBtn)
        marqueeAnimation = ObjectAnimator()

        textSizeController.progress = marqueeText.textSize.toInt()
        textSizeHint.text = "當前大小: ${textSizeHint.textSize}"

        marqueeText.post{ setUpAnimation() }


        input.addTextChangedListener(onTextChange)
        textSizeController.setOnSeekBarChangeListener(onTextSizeChange)
        setColorBtn.setOnClickListener{
            showColorDialog()
        }
    }

    private fun showColorDialog(){
        val colorArray = arrayOf(Color.RED, Color.BLUE, Color.GREEN, Color.YELLOW, Color.BLACK)
        val colorTitleArray = arrayOf("紅色","藍色","綠色","黃色","黑色")
        AlertDialog.Builder(this)
            .setIcon(R.drawable.ic_launcher_foreground)
            .setTitle("選擇顏色:")
            .setItems(colorTitleArray){_,choose ->
                when(choose){
                    0 -> setTextColor(colorArray[0])
                    1 -> setTextColor(colorArray[1])
                    2 -> setTextColor(colorArray[2])
                    3 -> setTextColor(colorArray[3])
                    4 -> setTextColor(colorArray[4])
                }
            }
            .show()
    }

    private fun setTextColor(color: Int){
        marqueeText.post{
            marqueeText.setTextColor(color)
        }
    }

    private val onTextChange = object : TextWatcher{
        override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {}
        override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {}
        override fun afterTextChanged(s: Editable?) {
            marqueeText.text = s.toString()
            marqueeText.post{
                setUpAnimation()
            }
        }
    }

    private val onTextSizeChange = object : SeekBar.OnSeekBarChangeListener{
        override fun onStartTrackingTouch(seekBar: SeekBar?) {}
        override fun onStopTrackingTouch(seekBar: SeekBar?) {}
        override fun onProgressChanged(seekBar: SeekBar?, progress: Int, fromUser: Boolean) {
            marqueeText.post{
                marqueeText.textSize = progress.toFloat()
                textSizeHint.text = "當前大小: ${marqueeText.textSize}"
            }
        }
    }

    private fun setUpAnimation(){
        marqueeAnimation.cancel()
        val startPos = -marqueeText.width.toFloat()
        val endPos = Resources.getSystem().displayMetrics.widthPixels.toFloat()
        marqueeAnimation = ObjectAnimator.ofFloat(marqueeText,"TranslationX",startPos,endPos).apply {
            duration = 5000
            repeatCount = ValueAnimator.INFINITE
            interpolator = LinearInterpolator()
            start()
        }
    }
}