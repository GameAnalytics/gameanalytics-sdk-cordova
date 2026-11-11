package com.gameanalytics.sdk.cordova;

import android.app.Activity;
import com.gameanalytics.sdk.GameAnalytics;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.json.JSONArray;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** Drives the real bridge the way Cordova does: initialize once, then execute(action, args, callback). */
final class BridgeHarness {
    static final Activity ACTIVITY = new Activity();

    static final class Outcome {
        boolean handled;
        Throwable thrown;
        List<List<Object>> nativeCalls;
        CallbackContext callback;
    }

    static GameAnalyticsCordova newPlugin() {
        GameAnalyticsCordova plugin = new GameAnalyticsCordova();
        CordovaInterface cordova = () -> ACTIVITY;
        plugin.initialize(cordova, null);
        return plugin;
    }

    /** Runs one action. {@code argsJson} is the JSON array Cordova would hand to execute(). */
    static Outcome run(String action, String argsJson) {
        GameAnalytics.reset();
        Outcome o = new Outcome();
        o.callback = new CallbackContext();
        try {
            o.handled = newPlugin().execute(action, new JSONArray(argsJson), o.callback);
        } catch (Throwable t) {
            o.thrown = t;
        }
        o.nativeCalls = new ArrayList<>(GameAnalytics.CALLS);
        return o;
    }

    static List<Object> call(Object... parts) {
        return Arrays.asList(parts);
    }

    /** The plugin version as declared in the plugin's package.json (the specification of "cordova x.y.z"). */
    static String pluginVersion() throws Exception {
        Path p = Paths.get("..", "..", "gameanalytics", "package.json");
        String json = new String(Files.readAllBytes(p), StandardCharsets.UTF_8);
        Matcher m = Pattern.compile("\"version\"\\s*:\\s*\"([^\"]+)\"").matcher(json);
        if (!m.find()) throw new IllegalStateException("no version in " + p);
        return m.group(1);
    }
}
