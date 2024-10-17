package com.dxy.holdem

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import org.devio.flutter.splashscreen.SplashScreen

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // SplashScreen.show(this)
        // or enable full screen
        SplashScreen.show(this, true) // here
        super.onCreate(savedInstanceState)
    }
}
