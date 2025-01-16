package com.iAttendy.app

import android.app.Activity
import android.app.ActivityManager
import android.content.Context
import android.os.Build
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity : FlutterActivity() {


//    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine)
//        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
//                call, result ->
//            // This method is invoked on the main thread.
//            // TODO
//        }
//    }


   override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
       flutterEngine.let { super.configureFlutterEngine(it) }
       flutterEngine.dartExecutor.let {
           MethodChannel(it.binaryMessenger, CHANNEL)
               .setMethodCallHandler { call, result ->
                   if (call.method.equals("pinScreen")) {
                       val isAppPinned : Boolean = isAppPinned(context)
                       if(!isAppPinned) {
                           pinScreen()
                           result.success("Pinned the screen")
                       }
                      // Toast.makeText(activity, "App is already pinned", Toast.LENGTH_SHORT).show()
                   } else if (call.method.equals("unpinScreen")) {
                       val isAppPinned : Boolean = isAppPinned(context)
                       if(isAppPinned) {
                           unpinScreen()
                           result.success("Unpinned the screen")
                       }
                      // Toast.makeText(activity, "App is not pinned", Toast.LENGTH_SHORT).show()
                   } else {
                       result.notImplemented()
                   }
               }
       }
    }

//    // Handle when the lock task mode is entering (This won't be available unless using DPC)
//    override fun onLockTaskModeEntering() {
//        super.onLockTaskModeEntering()
//        // This method will be called when lock task mode is entering
//        Toast.makeText(this, "Entering Lock Task Mode", Toast.LENGTH_SHORT).show()
//    }
//    // Called when the activity exits lock task mode
//     fun onLockTaskModeExiting() {
//        super.onLockTaskModeExiting()
//        Toast.makeText(this, "Lock Task Mode Exiting", Toast.LENGTH_SHORT).show()
//    }

    private fun pinScreen() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val activity: Activity = this
            // Check if the device supports screen pinning
//            if (activity.packageManager.hasSystemFeature("android.hardware.screen.pinning")) {
                try{
                    activity.startLockTask() // Start pinning the app
                   // Toast.makeText(activity, "App is now pinned", Toast.LENGTH_SHORT).show()
                } catch (e: SecurityException) {
                    Toast.makeText(activity, "Pinning failed: " + e.message, Toast.LENGTH_LONG).show()
                }
        //    }
       // else {
//                Toast.makeText(activity, "Screen pinning is not supported", Toast.LENGTH_SHORT)
//                    .show()
//            }
        }
    }

    private fun unpinScreen() {
        // Stop screen pinning
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val activity: Activity = this
            try {
                activity.stopLockTask() // Unpin the app
                Toast.makeText(activity, "App is now unpinned", Toast.LENGTH_SHORT).show()
            } catch (e: SecurityException) {
                Toast.makeText(activity, "Unpinning failed: " + e.message, Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun isAppPinned(context: Context): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val activityManager = context.getSystemService(ACTIVITY_SERVICE) as ActivityManager
            return activityManager.lockTaskModeState == ActivityManager.LOCK_TASK_MODE_PINNED
        }
        return false // Before Lollipop, there is no API to check for pinning
    }

    companion object {
        private const val CHANNEL = "com.iAttendy.app.pinning"
    }
}
