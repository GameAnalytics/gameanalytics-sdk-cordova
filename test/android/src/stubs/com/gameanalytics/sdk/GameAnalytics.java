package com.gameanalytics.sdk;

import android.app.Activity;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Recording test stub of com.gameanalytics.sdk.GameAnalytics.
 *
 * Only the primitive and String overloads of the published gameanalytics-android 7.2.1
 * API are declared, with their real parameter types, so Java overload resolution in the
 * bridge picks the same overload it would pick against the real SDK. Every call is
 * recorded as [signature, arg0, arg1, ...] with the argument types preserved.
 */
public class GameAnalytics {
    public static final List<List<Object>> CALLS = new ArrayList<>();

    /** Values the stubbed getters return. */
    public static String stringResult = "stub-string";
    public static boolean boolResult = true;

    public static void reset() {
        CALLS.clear();
        stringResult = "stub-string";
        boolResult = true;
    }

    private static void record(String name, String types, Object... args) {
        List<Object> call = new ArrayList<>();
        call.add(name + "(" + types + ")");
        for (Object a : args) {
            call.add(a);
        }
        CALLS.add(call);
    }
    public static void configureAvailableCustomDimensions01(String... a0) { record("configureAvailableCustomDimensions01", "String...", Arrays.asList(a0)); }
    public static void configureAvailableCustomDimensions02(String... a0) { record("configureAvailableCustomDimensions02", "String...", Arrays.asList(a0)); }
    public static void configureAvailableCustomDimensions03(String... a0) { record("configureAvailableCustomDimensions03", "String...", Arrays.asList(a0)); }
    public static void configureAvailableResourceCurrencies(String... a0) { record("configureAvailableResourceCurrencies", "String...", Arrays.asList(a0)); }
    public static void configureAvailableResourceItemTypes(String... a0) { record("configureAvailableResourceItemTypes", "String...", Arrays.asList(a0)); }
    public static void configureBuild(String a0) { record("configureBuild", "String", a0); }
    public static void configureSdkGameEngineVersion(String a0) { record("configureSdkGameEngineVersion", "String", a0); }
    public static void configureGameEngineVersion(String a0) { record("configureGameEngineVersion", "String", a0); }
    public static void configureAutoDetectAppVersion(boolean a0) { record("configureAutoDetectAppVersion", "boolean", a0); }
    public static void configureUserId(String a0) { record("configureUserId", "String", a0); }
    public static void initialize(Activity a0, String a1, String a2) { record("initialize", "Activity,String,String", a0, a1, a2); }
    public static void initialize(String a0, String a1) { record("initialize", "String,String", a0, a1); }
    public static void addBusinessEvent(String a0, int a1, String a2, String a3, String a4) { record("addBusinessEvent", "String,int,String,String,String", a0, a1, a2, a3, a4); }
    public static void addBusinessEvent(String a0, int a1, String a2, String a3, String a4, String a5) { record("addBusinessEvent", "String,int,String,String,String,String", a0, a1, a2, a3, a4, a5); }
    public static void addBusinessEvent(String a0, int a1, String a2, String a3, String a4, String a5, boolean a6) { record("addBusinessEvent", "String,int,String,String,String,String,boolean", a0, a1, a2, a3, a4, a5, a6); }
    public static void addBusinessEvent(String a0, int a1, String a2, String a3, String a4, String a5, String a6, String a7) { record("addBusinessEvent", "String,int,String,String,String,String,String,String", a0, a1, a2, a3, a4, a5, a6, a7); }
    public static void addBusinessEvent(String a0, int a1, String a2, String a3, String a4, String a5, String a6, String a7, String a8) { record("addBusinessEvent", "String,int,String,String,String,String,String,String,String", a0, a1, a2, a3, a4, a5, a6, a7, a8); }
    public static void addBusinessEvent(String a0, int a1, String a2, String a3, String a4, String a5, String a6, String a7, String a8, boolean a9) { record("addBusinessEvent", "String,int,String,String,String,String,String,String,String,boolean", a0, a1, a2, a3, a4, a5, a6, a7, a8, a9); }
    public static void addResourceEvent(int a0, String a1, float a2, String a3, String a4) { record("addResourceEvent", "int,String,float,String,String", a0, a1, a2, a3, a4); }
    public static void addResourceEvent(int a0, String a1, float a2, String a3, String a4, String a5) { record("addResourceEvent", "int,String,float,String,String,String", a0, a1, a2, a3, a4, a5); }
    public static void addResourceEvent(int a0, String a1, float a2, String a3, String a4, String a5, boolean a6) { record("addResourceEvent", "int,String,float,String,String,String,boolean", a0, a1, a2, a3, a4, a5, a6); }
    public static void addProgressionEvent(int a0, String a1, String a2, String a3) { record("addProgressionEvent", "int,String,String,String", a0, a1, a2, a3); }
    public static void addProgressionEvent(int a0, String a1, String a2, String a3, String a4) { record("addProgressionEvent", "int,String,String,String,String", a0, a1, a2, a3, a4); }
    public static void addProgressionEvent(int a0, String a1, String a2, String a3, String a4, boolean a5) { record("addProgressionEvent", "int,String,String,String,String,boolean", a0, a1, a2, a3, a4, a5); }
    public static void addProgressionEvent(int a0, String a1, String a2, String a3, double a4) { record("addProgressionEvent", "int,String,String,String,double", a0, a1, a2, a3, a4); }
    public static void addProgressionEvent(int a0, String a1, String a2, String a3, double a4, String a5) { record("addProgressionEvent", "int,String,String,String,double,String", a0, a1, a2, a3, a4, a5); }
    public static void addProgressionEvent(int a0, String a1, String a2, String a3, double a4, String a5, boolean a6) { record("addProgressionEvent", "int,String,String,String,double,String,boolean", a0, a1, a2, a3, a4, a5, a6); }
    public static void addDesignEvent(String a0) { record("addDesignEvent", "String", a0); }
    public static void addDesignEvent(String a0, String a1) { record("addDesignEvent", "String,String", a0, a1); }
    public static void addDesignEvent(String a0, String a1, boolean a2) { record("addDesignEvent", "String,String,boolean", a0, a1, a2); }
    public static void addDesignEvent(String a0, double a1) { record("addDesignEvent", "String,double", a0, a1); }
    public static void addDesignEvent(String a0, double a1, String a2) { record("addDesignEvent", "String,double,String", a0, a1, a2); }
    public static void addDesignEvent(String a0, double a1, String a2, boolean a3) { record("addDesignEvent", "String,double,String,boolean", a0, a1, a2, a3); }
    public static void addErrorEvent(int a0, String a1) { record("addErrorEvent", "int,String", a0, a1); }
    public static void addErrorEvent(int a0, String a1, String a2) { record("addErrorEvent", "int,String,String", a0, a1, a2); }
    public static void addErrorEvent(int a0, String a1, String a2, boolean a3) { record("addErrorEvent", "int,String,String,boolean", a0, a1, a2, a3); }
    public static void addAdEvent(int a0, int a1, String a2, String a3) { record("addAdEvent", "int,int,String,String", a0, a1, a2, a3); }
    public static void addAdEvent(int a0, int a1, String a2, String a3, String a4) { record("addAdEvent", "int,int,String,String,String", a0, a1, a2, a3, a4); }
    public static void addAdEvent(int a0, int a1, String a2, String a3, String a4, boolean a5) { record("addAdEvent", "int,int,String,String,String,boolean", a0, a1, a2, a3, a4, a5); }
    public static void addAdEvent(int a0, int a1, String a2, String a3, long a4) { record("addAdEvent", "int,int,String,String,long", a0, a1, a2, a3, a4); }
    public static void addAdEvent(int a0, int a1, String a2, String a3, long a4, String a5) { record("addAdEvent", "int,int,String,String,long,String", a0, a1, a2, a3, a4, a5); }
    public static void addAdEvent(int a0, int a1, String a2, String a3, long a4, String a5, boolean a6) { record("addAdEvent", "int,int,String,String,long,String,boolean", a0, a1, a2, a3, a4, a5, a6); }
    public static void addAdEvent(int a0, int a1, String a2, String a3, int a4) { record("addAdEvent", "int,int,String,String,int", a0, a1, a2, a3, a4); }
    public static void addAdEvent(int a0, int a1, String a2, String a3, int a4, String a5) { record("addAdEvent", "int,int,String,String,int,String", a0, a1, a2, a3, a4, a5); }
    public static void addAdEvent(int a0, int a1, String a2, String a3, int a4, String a5, boolean a6) { record("addAdEvent", "int,int,String,String,int,String,boolean", a0, a1, a2, a3, a4, a5, a6); }
    public static void setEnabledInfoLog(boolean a0) { record("setEnabledInfoLog", "boolean", a0); }
    public static void setEnabledVerboseLog(boolean a0) { record("setEnabledVerboseLog", "boolean", a0); }
    public static void setEnabledManualSessionHandling(boolean a0) { record("setEnabledManualSessionHandling", "boolean", a0); }
    public static void setEnabledEventSubmission(boolean a0) { record("setEnabledEventSubmission", "boolean", a0); }
    public static void setCustomDimension01(String a0) { record("setCustomDimension01", "String", a0); }
    public static void setCustomDimension02(String a0) { record("setCustomDimension02", "String", a0); }
    public static void setCustomDimension03(String a0) { record("setCustomDimension03", "String", a0); }
    public static void setGlobalCustomEventFields(String a0) { record("setGlobalCustomEventFields", "String", a0); }
    public static void startSession() { record("startSession", ""); }
    public static void endSession() { record("endSession", ""); }
    public static String getRemoteConfigsValueAsString(String a0) { record("getRemoteConfigsValueAsString", "String", a0); return stringResult; }
    public static String getRemoteConfigsValueAsString(String a0, String a1) { record("getRemoteConfigsValueAsString", "String,String", a0, a1); return stringResult; }
    public static boolean isRemoteConfigsReady() { record("isRemoteConfigsReady", ""); return boolResult; }
    public static String getRemoteConfigsContentAsString() { record("getRemoteConfigsContentAsString", ""); return stringResult; }
    public static String getABTestingId() { record("getABTestingId", ""); return stringResult; }
    public static String getABTestingVariantId() { record("getABTestingVariantId", ""); return stringResult; }
}
