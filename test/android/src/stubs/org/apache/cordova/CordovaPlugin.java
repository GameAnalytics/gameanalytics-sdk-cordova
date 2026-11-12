package org.apache.cordova;

import org.json.JSONArray;
import org.json.JSONException;

/** Test stub of CordovaPlugin with the members the bridge uses. */
public class CordovaPlugin {
    public CordovaInterface cordova;
    public CordovaWebView webView;

    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        this.cordova = cordova;
        this.webView = webView;
    }

    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        return false;
    }
}
