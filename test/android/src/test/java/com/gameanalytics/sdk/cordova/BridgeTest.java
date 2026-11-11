package com.gameanalytics.sdk.cordova;

import static com.gameanalytics.sdk.cordova.BridgeHarness.ACTIVITY;
import static com.gameanalytics.sdk.cordova.BridgeHarness.call;
import static com.gameanalytics.sdk.cordova.BridgeHarness.run;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertTrue;

import com.gameanalytics.sdk.GameAnalytics;
import org.apache.cordova.PluginResult;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.MethodSource;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.stream.Stream;

class BridgeTest {

    // ----- helpers ---------------------------------------------------------

    private static void assertSingleNativeCall(BridgeHarness.Outcome o, Object... expected) {
        assertNull(o.thrown, () -> "bridge threw " + o.thrown);
        assertTrue(o.handled, "action must be handled");
        assertEquals(1, o.nativeCalls.size(), () -> "native calls: " + o.nativeCalls);
        assertEquals(call(expected), o.nativeCalls.get(0));
    }

    private static void assertSuccessOnce(BridgeHarness.Outcome o) {
        assertEquals(Collections.singletonList("success"), o.callback.completions);
    }

    private static String q(String s) {
        return org.json.JSONObject.quote(s);
    }

    /** Every action of the supported surface with realistic arguments (JSON array as Cordova delivers it). */
    static Stream<String[]> everyAction() {
        return Stream.of(
            new String[]{"configureAvailableCustomDimensions01", "[[\"a\",\"b\"]]"},
            new String[]{"configureAvailableCustomDimensions02", "[[\"a\",\"b\"]]"},
            new String[]{"configureAvailableCustomDimensions03", "[[\"a\",\"b\"]]"},
            new String[]{"configureAvailableResourceCurrencies", "[[\"gems\"]]"},
            new String[]{"configureAvailableResourceItemTypes", "[[\"boost\"]]"},
            new String[]{"configureBuild", "[\"1.2.3\"]"},
            new String[]{"configureAutoDetectAppVersion", "[true]"},
            new String[]{"configureUserId", "[\"u1\"]"},
            new String[]{"initialize", "[{\"gameKey\":\"GAME_KEY_PLACEHOLDER\",\"secretKey\":\"SECRET_KEY_PLACEHOLDER\"}]"},
            new String[]{"addBusinessEvent", "[{\"currency\":\"USD\",\"amount\":99,\"itemType\":\"IAP\",\"itemId\":\"gems\",\"cartType\":\"shop\"}]"},
            new String[]{"addResourceEvent", "[{\"flowType\":1,\"currency\":\"gems\",\"amount\":5,\"itemType\":\"boost\",\"itemId\":\"speed\"}]"},
            new String[]{"addProgressionEvent", "[{\"progressionStatus\":1,\"progression01\":\"w1\"}]"},
            new String[]{"addDesignEvent", "[{\"eventId\":\"ui:click\"}]"},
            new String[]{"addErrorEvent", "[{\"severity\":4,\"message\":\"oops\"}]"},
            new String[]{"addAdEvent", "[{\"adAction\":2,\"adType\":1,\"adSdkName\":\"s\",\"adPlacement\":\"p\"}]"},
            new String[]{"setEnabledInfoLog", "[true]"},
            new String[]{"setEnabledVerboseLog", "[true]"},
            new String[]{"setEnabledManualSessionHandling", "[true]"},
            new String[]{"setEnabledEventSubmission", "[false]"},
            new String[]{"setCustomDimension01", "[\"x\"]"},
            new String[]{"setCustomDimension02", "[\"x\"]"},
            new String[]{"setCustomDimension03", "[\"x\"]"},
            new String[]{"setGlobalCustomEventFields", "[\"{\\\"a\\\":1}\"]"},
            new String[]{"startSession", "[]"},
            new String[]{"endSession", "[]"},
            new String[]{"getRemoteConfigsValueAsString", "[{\"key\":\"k\",\"defaultValue\":\"d\"}]"},
            new String[]{"isRemoteConfigsReady", "[]"},
            new String[]{"getRemoteConfigsContentAsString", "[]"},
            new String[]{"getABTestingId", "[]"},
            new String[]{"getABTestingVariantId", "[]"});
    }

    // ----- every action: handled, one native call, one callback --------------

    @Test
    void surfaceHasThirtyActions() {
        assertEquals(30, everyAction().count());
    }

    @ParameterizedTest(name = "{0}: is handled, reaches the SDK and completes the callback exactly once")
    @MethodSource("everyAction")
    void everyActionIsHandledAndCompletesOnce(String action, String args) {
        BridgeHarness.Outcome o = run(action, args);
        assertNull(o.thrown, () -> "bridge threw " + o.thrown);
        assertTrue(o.handled, action + " must be handled");
        assertFalse(o.nativeCalls.isEmpty(), action + " must reach a GameAnalytics call");
        assertEquals(1, o.callback.completions.size(), () -> "completions: " + o.callback.completions);
        assertFalse(o.callback.completions.get(0).startsWith("error"), o.callback.completions.get(0));
    }

    @ParameterizedTest(name = "{0}: completes exactly once even when its argument is JSON null or missing")
    @MethodSource("everyAction")
    void everyActionCompletesOnceWithoutArguments(String action, String ignored) {
        for (String args : new String[]{"[]", "[null]"}) {
            BridgeHarness.Outcome o = run(action, args);
            assertNull(o.thrown, () -> action + " with " + args + " threw " + o.thrown);
            assertTrue(o.handled);
            assertEquals(1, o.callback.completions.size(), () -> action + " " + args + ": " + o.callback.completions);
        }
    }

    // ----- unknown action ----------------------------------------------------

    @Test
    void unknownActionIsRejectedWithoutTouchingTheSdk() {
        BridgeHarness.Outcome o = run("doesNotExist", "[]");
        assertNull(o.thrown);
        assertFalse(o.handled, "execute must return false so Cordova reports INVALID_ACTION");
        assertTrue(o.nativeCalls.isEmpty());
        assertTrue(o.callback.completions.isEmpty());
    }

    @Test
    void actionsOutsideTheSupportedSurfaceAreRejected() {
        for (String action : new String[]{"", "INITIALIZE", "Initialize", "initialize ", "setEnabledWarningLog",
                "addImpressionEvent", "getUserId", "startTimer", "addAdEventWithDuration", "addDesignEventWithValue"}) {
            BridgeHarness.Outcome o = run(action, "[]");
            assertFalse(o.handled, action);
            assertTrue(o.nativeCalls.isEmpty(), action);
            assertTrue(o.callback.completions.isEmpty(), action);
        }
    }

    // ----- configure* ---------------------------------------------------------

    @Test
    void configureAvailableCustomDimensions01ForwardsTheValuesInOrder() {
        BridgeHarness.Outcome o = run("configureAvailableCustomDimensions01", "[[\"ninja\",\"samurai\"]]");
        assertSingleNativeCall(o, "configureAvailableCustomDimensions01(String...)", Arrays.asList("ninja", "samurai"));
        assertSuccessOnce(o);
    }

    @Test
    void configureAvailableCustomDimensions02ForwardsTheValuesInOrder() {
        BridgeHarness.Outcome o = run("configureAvailableCustomDimensions02", "[[\"gold\",\"silver\",\"bronze\"]]");
        assertSingleNativeCall(o, "configureAvailableCustomDimensions02(String...)", Arrays.asList("gold", "silver", "bronze"));
        assertSuccessOnce(o);
    }

    @Test
    void configureAvailableCustomDimensions03ForwardsTheValuesInOrder() {
        BridgeHarness.Outcome o = run("configureAvailableCustomDimensions03", "[[\"a\",\"b\",\"c\"]]");
        assertSingleNativeCall(o, "configureAvailableCustomDimensions03(String...)", Arrays.asList("a", "b", "c"));
        assertSuccessOnce(o);
    }

    @Test
    void configureAvailableResourceCurrenciesForwardsTheValues() {
        BridgeHarness.Outcome o = run("configureAvailableResourceCurrencies", "[[\"gems\",\"gold\"]]");
        assertSingleNativeCall(o, "configureAvailableResourceCurrencies(String...)", Arrays.asList("gems", "gold"));
        assertSuccessOnce(o);
    }

    @Test
    void configureAvailableResourceItemTypesForwardsTheValues() {
        BridgeHarness.Outcome o = run("configureAvailableResourceItemTypes", "[[\"boost\",\"lives\"]]");
        assertSingleNativeCall(o, "configureAvailableResourceItemTypes(String...)", Arrays.asList("boost", "lives"));
        assertSuccessOnce(o);
    }

    @Test
    void configureAvailableCustomDimensionsWithEmptyArrayForwardsAnEmptyList() {
        BridgeHarness.Outcome o = run("configureAvailableCustomDimensions01", "[[]]");
        assertSingleNativeCall(o, "configureAvailableCustomDimensions01(String...)", Collections.emptyList());
        assertSuccessOnce(o);
    }

    @Test
    void configureAvailableCustomDimensionsKeepsUnicodeAndQuotes() {
        String v = "café 日本語 \"q\" \\ 😀";
        BridgeHarness.Outcome o = run("configureAvailableCustomDimensions01", "[[" + q(v) + "]]");
        assertSingleNativeCall(o, "configureAvailableCustomDimensions01(String...)", Collections.singletonList(v));
    }

    @Test
    void configureBuildForwardsTheBuildString() {
        BridgeHarness.Outcome o = run("configureBuild", "[\"1.2.3\"]");
        assertSingleNativeCall(o, "configureBuild(String)", "1.2.3");
        assertSuccessOnce(o);
    }

    @Test
    void configureBuildForwardsAVeryLongString() {
        String v = new String(new char[20000]).replace('\0', 'x');
        BridgeHarness.Outcome o = run("configureBuild", "[" + q(v) + "]");
        assertSingleNativeCall(o, "configureBuild(String)", v);
    }

    @Test
    void configureAutoDetectAppVersionForwardsTrue() {
        assertSingleNativeCall(run("configureAutoDetectAppVersion", "[true]"), "configureAutoDetectAppVersion(boolean)", true);
    }

    @Test
    void configureAutoDetectAppVersionForwardsFalse() {
        BridgeHarness.Outcome o = run("configureAutoDetectAppVersion", "[false]");
        assertSingleNativeCall(o, "configureAutoDetectAppVersion(boolean)", false);
        assertSuccessOnce(o);
    }

    @Test
    void configureUserIdForwardsTheId() {
        BridgeHarness.Outcome o = run("configureUserId", "[\"player-42\"]");
        assertSingleNativeCall(o, "configureUserId(String)", "player-42");
        assertSuccessOnce(o);
    }

    // ----- initialize ---------------------------------------------------------

    @Test
    void initializePassesTheActivityAndBothKeysToTheSdk() {
        BridgeHarness.Outcome o = run("initialize", "[{\"gameKey\":\"GAME_KEY_PLACEHOLDER\",\"secretKey\":\"SECRET_KEY_PLACEHOLDER\"}]");
        assertNull(o.thrown);
        assertTrue(o.handled);
        List<Object> last = o.nativeCalls.get(o.nativeCalls.size() - 1);
        assertEquals("initialize(Activity,String,String)", last.get(0));
        assertSame(ACTIVITY, last.get(1));
        assertEquals("GAME_KEY_PLACEHOLDER", last.get(2));
        assertEquals("SECRET_KEY_PLACEHOLDER", last.get(3));
        assertSuccessOnce(o);
    }

    @Test
    void initializeIdentifiesThePluginAsTheGameEngineBeforeInitializing() throws Exception {
        BridgeHarness.Outcome o = run("initialize", "[{\"gameKey\":\"k\",\"secretKey\":\"s\"}]");
        assertEquals(2, o.nativeCalls.size(), () -> String.valueOf(o.nativeCalls));
        assertEquals(call("configureSdkGameEngineVersion(String)", "cordova " + BridgeHarness.pluginVersion()),
                o.nativeCalls.get(0), "engine version must be set before initialize");
        assertEquals("initialize(Activity,String,String)", o.nativeCalls.get(1).get(0));
    }

    // ----- business event -------------------------------------------------------

    private static final String BIZ = "\"currency\":\"USD\",\"amount\":99,\"itemType\":\"IAP\",\"itemId\":\"gems_100\",\"cartType\":\"shop\"";

    @Test
    void addBusinessEventWithoutReceiptUsesTheBasicOverload() {
        BridgeHarness.Outcome o = run("addBusinessEvent", "[{" + BIZ + "}]");
        assertSingleNativeCall(o, "addBusinessEvent(String,int,String,String,String,String,boolean)",
                "USD", 99, "IAP", "gems_100", "shop", "", false);
        assertSuccessOnce(o);
    }

    @Test
    void addBusinessEventWithCustomFieldsAndMergeFieldsForwardsBoth() {
        String fields = "{\"promo\":\"summer\",\"n\":1.5}";
        BridgeHarness.Outcome o = run("addBusinessEvent", "[{" + BIZ + ",\"customFields\":" + q(fields) + ",\"mergeFields\":true}]");
        assertSingleNativeCall(o, "addBusinessEvent(String,int,String,String,String,String,boolean)",
                "USD", 99, "IAP", "gems_100", "shop", fields, true);
    }

    @Test
    void addBusinessEventWithReceiptAndSignatureUsesTheGooglePlayValidationOverload() {
        BridgeHarness.Outcome o = run("addBusinessEvent",
                "[{" + BIZ + ",\"receipt\":\"RECEIPT\",\"signature\":\"SIGNATURE\",\"customFields\":\"{\\\"a\\\":1}\",\"mergeFields\":true}]");
        assertSingleNativeCall(o, "addBusinessEvent(String,int,String,String,String,String,String,String,String,boolean)",
                "USD", 99, "IAP", "gems_100", "shop", "RECEIPT", "google_play", "SIGNATURE", "{\"a\":1}", true);
        assertSuccessOnce(o);
    }

    @Test
    void addBusinessEventWithReceiptOnlyDoesNotUseTheValidationOverload() {
        BridgeHarness.Outcome o = run("addBusinessEvent", "[{" + BIZ + ",\"receipt\":\"RECEIPT\"}]");
        assertEquals("addBusinessEvent(String,int,String,String,String,String,boolean)", o.nativeCalls.get(0).get(0));
    }

    @Test
    void addBusinessEventWithSignatureOnlyDoesNotUseTheValidationOverload() {
        BridgeHarness.Outcome o = run("addBusinessEvent", "[{" + BIZ + ",\"signature\":\"SIGNATURE\"}]");
        assertEquals("addBusinessEvent(String,int,String,String,String,String,boolean)", o.nativeCalls.get(0).get(0));
    }

    @Test
    void addBusinessEventWithEmptyReceiptAndSignatureDoesNotUseTheValidationOverload() {
        BridgeHarness.Outcome o = run("addBusinessEvent", "[{" + BIZ + ",\"receipt\":\"\",\"signature\":\"\"}]");
        assertEquals("addBusinessEvent(String,int,String,String,String,String,boolean)", o.nativeCalls.get(0).get(0));
    }

    @Test
    void addBusinessEventAutoFetchReceiptIsIosOnlyAndIgnoredOnAndroid() {
        BridgeHarness.Outcome o = run("addBusinessEvent", "[{" + BIZ + ",\"autoFetchReceipt\":true}]");
        assertSingleNativeCall(o, "addBusinessEvent(String,int,String,String,String,String,boolean)",
                "USD", 99, "IAP", "gems_100", "shop", "", false);
        assertSuccessOnce(o);
    }

    @Test
    void addBusinessEventKeepsUnicodeInItemId() {
        BridgeHarness.Outcome o = run("addBusinessEvent",
                "[{\"currency\":\"EUR\",\"amount\":1,\"itemType\":\"t\",\"itemId\":" + q("sword ⚔ é") + ",\"cartType\":\"c\"}]");
        assertEquals("sword ⚔ é", o.nativeCalls.get(0).get(4));
    }

    // ----- resource event ----------------------------------------------------------

    @Test
    void addResourceEventForwardsFlowTypeAmountAndStrings() {
        BridgeHarness.Outcome o = run("addResourceEvent",
                "[{\"flowType\":2,\"currency\":\"gems\",\"amount\":2.5,\"itemType\":\"boost\",\"itemId\":\"speed\"}]");
        assertSingleNativeCall(o, "addResourceEvent(int,String,float,String,String,String,boolean)",
                2, "gems", 2.5f, "boost", "speed", "", false);
        assertSuccessOnce(o);
    }

    @Test
    void addResourceEventSourceFlowTypeIsOne() {
        BridgeHarness.Outcome o = run("addResourceEvent",
                "[{\"flowType\":1,\"currency\":\"gold\",\"amount\":10,\"itemType\":\"chest\",\"itemId\":\"c1\"}]");
        assertEquals(1, o.nativeCalls.get(0).get(1));
        assertEquals(10.0f, o.nativeCalls.get(0).get(3));
    }

    @Test
    void addResourceEventForwardsCustomFieldsAndMergeFields() {
        BridgeHarness.Outcome o = run("addResourceEvent",
                "[{\"flowType\":1,\"currency\":\"gold\",\"amount\":1,\"itemType\":\"a\",\"itemId\":\"b\",\"customFields\":\"{\\\"k\\\":\\\"v\\\"}\",\"mergeFields\":true}]");
        assertSingleNativeCall(o, "addResourceEvent(int,String,float,String,String,String,boolean)",
                1, "gold", 1.0f, "a", "b", "{\"k\":\"v\"}", true);
    }

    // ----- progression event ---------------------------------------------------------

    @Test
    void addProgressionEventWithoutScoreUsesTheNoScoreOverload() {
        BridgeHarness.Outcome o = run("addProgressionEvent",
                "[{\"progressionStatus\":1,\"progression01\":\"world1\",\"progression02\":\"level2\",\"progression03\":\"boss\"}]");
        assertSingleNativeCall(o, "addProgressionEvent(int,String,String,String,String,boolean)",
                1, "world1", "level2", "boss", "", false);
        assertSuccessOnce(o);
    }

    @Test
    void addProgressionEventWithScoreUsesTheWithScoreOverload() {
        BridgeHarness.Outcome o = run("addProgressionEvent",
                "[{\"progressionStatus\":2,\"progression01\":\"world1\",\"progression02\":\"level2\",\"progression03\":\"boss\",\"score\":1500}]");
        assertSingleNativeCall(o, "addProgressionEvent(int,String,String,String,double,String,boolean)",
                2, "world1", "level2", "boss", 1500.0, "", false);
        assertSuccessOnce(o);
    }

    @Test
    void addProgressionEventWithScoreZeroStillUsesTheWithScoreOverload() {
        BridgeHarness.Outcome o = run("addProgressionEvent", "[{\"progressionStatus\":3,\"progression01\":\"w\",\"score\":0}]");
        assertEquals("addProgressionEvent(int,String,String,String,double,String,boolean)", o.nativeCalls.get(0).get(0));
        assertEquals(0.0, o.nativeCalls.get(0).get(5));
    }

    @Test
    void addProgressionEventWithNegativeScoreForwardsTheNegativeValue() {
        BridgeHarness.Outcome o = run("addProgressionEvent", "[{\"progressionStatus\":3,\"progression01\":\"w\",\"score\":-50}]");
        assertEquals(-50.0, o.nativeCalls.get(0).get(5));
    }

    @Test
    void addProgressionEventWithScoreForwardsCustomFieldsAndMergeFields() {
        BridgeHarness.Outcome o = run("addProgressionEvent",
                "[{\"progressionStatus\":2,\"progression01\":\"w\",\"progression02\":\"l\",\"progression03\":\"\",\"score\":7,\"customFields\":\"{\\\"a\\\":1}\",\"mergeFields\":true}]");
        assertSingleNativeCall(o, "addProgressionEvent(int,String,String,String,double,String,boolean)",
                2, "w", "l", "", 7.0, "{\"a\":1}", true);
    }

    @Test
    void addProgressionEventWithOnlyProgression01LeavesTheOtherTiersEmpty() {
        BridgeHarness.Outcome o = run("addProgressionEvent", "[{\"progressionStatus\":1,\"progression01\":\"w\"}]");
        assertEquals("w", o.nativeCalls.get(0).get(2));
        assertEquals("", o.nativeCalls.get(0).get(3));
        assertEquals("", o.nativeCalls.get(0).get(4));
    }

    // ----- design event --------------------------------------------------------------

    @Test
    void addDesignEventWithoutValueUsesTheNoValueOverload() {
        BridgeHarness.Outcome o = run("addDesignEvent", "[{\"eventId\":\"ui:click:play\"}]");
        assertSingleNativeCall(o, "addDesignEvent(String,String,boolean)", "ui:click:play", "", false);
        assertSuccessOnce(o);
    }

    @Test
    void addDesignEventWithValueUsesTheWithValueOverload() {
        BridgeHarness.Outcome o = run("addDesignEvent", "[{\"eventId\":\"ui:click:play\",\"value\":3.5}]");
        assertSingleNativeCall(o, "addDesignEvent(String,double,String,boolean)", "ui:click:play", 3.5, "", false);
        assertSuccessOnce(o);
    }

    @Test
    void addDesignEventWithValueZeroStillUsesTheWithValueOverload() {
        BridgeHarness.Outcome o = run("addDesignEvent", "[{\"eventId\":\"e\",\"value\":0}]");
        assertSingleNativeCall(o, "addDesignEvent(String,double,String,boolean)", "e", 0.0, "", false);
    }

    @Test
    void addDesignEventWithNegativeValueForwardsTheNegativeValue() {
        BridgeHarness.Outcome o = run("addDesignEvent", "[{\"eventId\":\"e\",\"value\":-2.25}]");
        assertEquals(-2.25, o.nativeCalls.get(0).get(2));
    }

    @Test
    void addDesignEventForwardsCustomFieldsAndMergeFieldsWithValue() {
        BridgeHarness.Outcome o = run("addDesignEvent", "[{\"eventId\":\"e\",\"value\":1,\"customFields\":\"{\\\"a\\\":true}\",\"mergeFields\":true}]");
        assertSingleNativeCall(o, "addDesignEvent(String,double,String,boolean)", "e", 1.0, "{\"a\":true}", true);
    }

    @Test
    void addDesignEventForwardsCustomFieldsAndMergeFieldsWithoutValue() {
        BridgeHarness.Outcome o = run("addDesignEvent", "[{\"eventId\":\"e\",\"customFields\":\"{\\\"a\\\":true}\",\"mergeFields\":true}]");
        assertSingleNativeCall(o, "addDesignEvent(String,String,boolean)", "e", "{\"a\":true}", true);
    }

    @Test
    void addDesignEventKeepsUnicodeAndEscapesInTheEventIdAndFields() {
        String id = "café:日本語";
        String fields = "{\"quote\":\"say \\\"hi\\\"\",\"emoji\":\"😀\"}";
        BridgeHarness.Outcome o = run("addDesignEvent", "[{\"eventId\":" + q(id) + ",\"customFields\":" + q(fields) + "}]");
        assertSingleNativeCall(o, "addDesignEvent(String,String,boolean)", id, fields, false);
    }

    @Test
    void addDesignEventWithEmptyEventIdForwardsAnEmptyString() {
        BridgeHarness.Outcome o = run("addDesignEvent", "[{\"eventId\":\"\"}]");
        assertEquals("", o.nativeCalls.get(0).get(1));
    }

    // ----- error event -----------------------------------------------------------------

    @Test
    void addErrorEventForwardsSeverityAndMessage() {
        BridgeHarness.Outcome o = run("addErrorEvent", "[{\"severity\":4,\"message\":\"something broke\"}]");
        assertSingleNativeCall(o, "addErrorEvent(int,String,String,boolean)", 4, "something broke", "", false);
        assertSuccessOnce(o);
    }

    @Test
    void addErrorEventForwardsCriticalSeverityAsFive() {
        BridgeHarness.Outcome o = run("addErrorEvent", "[{\"severity\":5,\"message\":\"m\",\"customFields\":\"{\\\"a\\\":1}\",\"mergeFields\":true}]");
        assertSingleNativeCall(o, "addErrorEvent(int,String,String,boolean)", 5, "m", "{\"a\":1}", true);
    }

    @Test
    void addErrorEventKeepsMultilineAndUnicodeMessages() {
        String m = "line1\nline2\t\"quoted\" \\ é 😀";
        BridgeHarness.Outcome o = run("addErrorEvent", "[{\"severity\":2,\"message\":" + q(m) + "}]");
        assertEquals(m, o.nativeCalls.get(0).get(2));
    }

    // ----- ad event -----------------------------------------------------------------------

    @Test
    void addAdEventWithDurationUsesTheWithDurationOverload() {
        BridgeHarness.Outcome o = run("addAdEvent",
                "[{\"adAction\":2,\"adType\":2,\"adSdkName\":\"admob\",\"adPlacement\":\"level_end\",\"duration\":30}]");
        assertSingleNativeCall(o, "addAdEvent(int,int,String,String,long,String,boolean)",
                2, 2, "admob", "level_end", 30L, "", false);
        assertSuccessOnce(o);
    }

    @Test
    void addAdEventWithDurationZeroStillUsesTheWithDurationOverload() {
        BridgeHarness.Outcome o = run("addAdEvent", "[{\"adAction\":2,\"adType\":1,\"adSdkName\":\"s\",\"adPlacement\":\"p\",\"duration\":0}]");
        assertEquals("addAdEvent(int,int,String,String,long,String,boolean)", o.nativeCalls.get(0).get(0));
        assertEquals(0L, o.nativeCalls.get(0).get(5));
    }

    @Test
    void addAdEventWithoutDurationUsesTheWithReasonOverload() {
        BridgeHarness.Outcome o = run("addAdEvent",
                "[{\"adAction\":3,\"adType\":4,\"adSdkName\":\"admob\",\"adPlacement\":\"p\",\"noAdReason\":3}]");
        assertSingleNativeCall(o, "addAdEvent(int,int,String,String,int,String,boolean)",
                3, 4, "admob", "p", 3, "", false);
        assertSuccessOnce(o);
    }

    @Test
    void addAdEventWithNeitherDurationNorReasonSendsReasonUndefined() {
        BridgeHarness.Outcome o = run("addAdEvent", "[{\"adAction\":1,\"adType\":6,\"adSdkName\":\"s\",\"adPlacement\":\"p\"}]");
        assertSingleNativeCall(o, "addAdEvent(int,int,String,String,int,String,boolean)", 1, 6, "s", "p", 0, "", false);
    }

    @Test
    void addAdEventForwardsTheNewRequestAndLoadedActions() {
        BridgeHarness.Outcome request = run("addAdEvent", "[{\"adAction\":5,\"adType\":1,\"adSdkName\":\"s\",\"adPlacement\":\"p\"}]");
        BridgeHarness.Outcome loaded = run("addAdEvent", "[{\"adAction\":6,\"adType\":1,\"adSdkName\":\"s\",\"adPlacement\":\"p\"}]");
        assertEquals(5, request.nativeCalls.get(0).get(1));
        assertEquals(6, loaded.nativeCalls.get(0).get(1));
    }

    @Test
    void addAdEventForwardsCustomFieldsAndMergeFields() {
        BridgeHarness.Outcome o = run("addAdEvent",
                "[{\"adAction\":2,\"adType\":1,\"adSdkName\":\"s\",\"adPlacement\":\"p\",\"duration\":5,\"customFields\":\"{\\\"a\\\":1}\",\"mergeFields\":true}]");
        assertSingleNativeCall(o, "addAdEvent(int,int,String,String,long,String,boolean)", 2, 1, "s", "p", 5L, "{\"a\":1}", true);
    }

    // ----- flags and strings ---------------------------------------------------------------

    @Test
    void setEnabledInfoLogForwardsTheFlag() {
        assertSingleNativeCall(run("setEnabledInfoLog", "[true]"), "setEnabledInfoLog(boolean)", true);
        assertSingleNativeCall(run("setEnabledInfoLog", "[false]"), "setEnabledInfoLog(boolean)", false);
    }

    @Test
    void setEnabledVerboseLogForwardsTheFlag() {
        assertSingleNativeCall(run("setEnabledVerboseLog", "[true]"), "setEnabledVerboseLog(boolean)", true);
        assertSingleNativeCall(run("setEnabledVerboseLog", "[false]"), "setEnabledVerboseLog(boolean)", false);
    }

    @Test
    void setEnabledManualSessionHandlingForwardsTheFlag() {
        assertSingleNativeCall(run("setEnabledManualSessionHandling", "[true]"), "setEnabledManualSessionHandling(boolean)", true);
        assertSingleNativeCall(run("setEnabledManualSessionHandling", "[false]"), "setEnabledManualSessionHandling(boolean)", false);
    }

    @Test
    void setEnabledEventSubmissionForwardsTheFlag() {
        assertSingleNativeCall(run("setEnabledEventSubmission", "[true]"), "setEnabledEventSubmission(boolean)", true);
        BridgeHarness.Outcome o = run("setEnabledEventSubmission", "[false]");
        assertSingleNativeCall(o, "setEnabledEventSubmission(boolean)", false);
        assertSuccessOnce(o);
    }

    @Test
    void setCustomDimensionsForwardTheValue() {
        assertSingleNativeCall(run("setCustomDimension01", "[\"ninja\"]"), "setCustomDimension01(String)", "ninja");
        assertSingleNativeCall(run("setCustomDimension02", "[\"gold\"]"), "setCustomDimension02(String)", "gold");
        BridgeHarness.Outcome o = run("setCustomDimension03", "[\"c\"]");
        assertSingleNativeCall(o, "setCustomDimension03(String)", "c");
        assertSuccessOnce(o);
    }

    @Test
    void setCustomDimensionWithEmptyStringForwardsAnEmptyString() {
        assertSingleNativeCall(run("setCustomDimension01", "[\"\"]"), "setCustomDimension01(String)", "");
    }

    @Test
    void setCustomDimensionKeepsUnicode() {
        String v = "日本語 é";
        assertSingleNativeCall(run("setCustomDimension02", "[" + q(v) + "]"), "setCustomDimension02(String)", v);
    }

    @Test
    void setGlobalCustomEventFieldsForwardsTheJsonStringUnchanged() {
        String json = "{\"level\":3,\"name\":\"café \\\"x\\\"\",\"nested\":{\"a\":[1,2]}}";
        BridgeHarness.Outcome o = run("setGlobalCustomEventFields", "[" + q(json) + "]");
        assertSingleNativeCall(o, "setGlobalCustomEventFields(String)", json);
        assertSuccessOnce(o);
    }

    // ----- sessions ------------------------------------------------------------------------

    @Test
    void startSessionReachesTheSdk() {
        BridgeHarness.Outcome o = run("startSession", "[]");
        assertSingleNativeCall(o, "startSession()");
        assertSuccessOnce(o);
    }

    @Test
    void endSessionReachesTheSdk() {
        BridgeHarness.Outcome o = run("endSession", "[]");
        assertSingleNativeCall(o, "endSession()");
        assertSuccessOnce(o);
    }

    // ----- remote configs and A/B testing: values come back through the callback -------------

    private static void assertResult(BridgeHarness.Outcome o, Object expected) {
        assertEquals(1, o.callback.results.size(), () -> o.callback.completions.toString());
        assertEquals(1, o.callback.completions.size(), () -> o.callback.completions.toString());
        assertEquals(PluginResult.Status.OK, o.callback.results.get(0).getStatus());
        assertEquals(expected, o.callback.results.get(0).getMessageObject());
    }

    @Test
    void getRemoteConfigsValueAsStringWithDefaultReturnsTheSdkValueThroughTheCallback() {
        GameAnalytics.reset();
        BridgeHarness.Outcome o = run("getRemoteConfigsValueAsString", "[{\"key\":\"difficulty\",\"defaultValue\":\"normal\"}]");
        assertSingleNativeCall(o, "getRemoteConfigsValueAsString(String,String)", "difficulty", "normal");
        assertResult(o, "stub-string");
    }

    @Test
    void getRemoteConfigsValueAsStringWithoutDefaultStillReturnsTheKeysValue() {
        BridgeHarness.Outcome o = run("getRemoteConfigsValueAsString", "[{\"key\":\"difficulty\"}]");
        assertNull(o.thrown);
        assertEquals(1, o.nativeCalls.size());
        List<Object> c = o.nativeCalls.get(0);
        assertTrue(c.equals(call("getRemoteConfigsValueAsString(String)", "difficulty"))
                || c.equals(call("getRemoteConfigsValueAsString(String,String)", "difficulty", "")), c.toString());
        assertResult(o, "stub-string");
    }

    @Test
    void isRemoteConfigsReadyReturnsABooleanThroughTheCallback() {
        BridgeHarness.Outcome o = run("isRemoteConfigsReady", "[]");
        assertSingleNativeCall(o, "isRemoteConfigsReady()");
        assertResult(o, Boolean.TRUE);
    }

    @Test
    void getRemoteConfigsContentAsStringReturnsTheContentThroughTheCallback() {
        BridgeHarness.Outcome o = run("getRemoteConfigsContentAsString", "[]");
        assertSingleNativeCall(o, "getRemoteConfigsContentAsString()");
        assertResult(o, "stub-string");
    }

    @Test
    void getABTestingIdReturnsTheIdThroughTheCallback() {
        BridgeHarness.Outcome o = run("getABTestingId", "[]");
        assertSingleNativeCall(o, "getABTestingId()");
        assertResult(o, "stub-string");
    }

    @Test
    void getABTestingVariantIdReturnsTheIdThroughTheCallback() {
        BridgeHarness.Outcome o = run("getABTestingVariantId", "[]");
        assertSingleNativeCall(o, "getABTestingVariantId()");
        assertResult(o, "stub-string");
    }

    // ----- optional keys absent ---------------------------------------------------------------

    @Test
    void eventsWithAnAbsentOptionsObjectStillCompleteExactlyOnce() {
        for (String action : new String[]{"addBusinessEvent", "addResourceEvent", "addProgressionEvent",
                "addDesignEvent", "addErrorEvent", "addAdEvent"}) {
            BridgeHarness.Outcome o = run(action, "[null]");
            assertNull(o.thrown, action);
            assertEquals(Collections.singletonList("success"), o.callback.completions, action);
        }
    }
}
