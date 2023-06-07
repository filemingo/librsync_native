package me.gurupras.librsyncnative.librsync_native;

import io.flutter.Log;

public class GoLogger {

    public static void init () {

        librsyncbridge.Librsyncbridge.init();
        Log.i("librsync", "Initialized golang logger");
        librsyncbridge.Librsyncbridge.addLogger(new librsyncbridge.Logger() {
            @Override
            public void d(String tag, String msg) {
                Log.d(tag, msg);
            }

            @Override
            public void e(String tag, String msg) {
                Log.e(tag, msg);
            }

            @Override
            public void i(String tag, String msg) {
                Log.i(tag, msg);
            }

            @Override
            public void v(String tag, String msg) { Log.v(tag, msg); }

            @Override
            public void w(String tag, String msg) { Log.w(tag, msg); }
        });
        Log.i("librsync", "Set up logger interface");
    }
}
