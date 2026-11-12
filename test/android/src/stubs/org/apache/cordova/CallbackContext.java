package org.apache.cordova;

import java.util.ArrayList;
import java.util.List;

/** Test stub of CallbackContext: records every way the bridge can complete a call. */
public class CallbackContext {
    /** One entry per completion, e.g. "success", "error:msg" or "result:OK:value". */
    public final List<String> completions = new ArrayList<>();
    public final List<PluginResult> results = new ArrayList<>();

    public void success() { completions.add("success"); }
    public void success(String message) { completions.add("success:" + message); }
    public void success(int message) { completions.add("success:" + message); }
    public void error(String message) { completions.add("error:" + message); }
    public void error(int message) { completions.add("error:" + message); }

    public void sendPluginResult(PluginResult result) {
        results.add(result);
        completions.add("result:" + result.getStatus() + ":" + result.getMessageObject());
    }
}
