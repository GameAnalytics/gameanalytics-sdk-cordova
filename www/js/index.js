/*
 * GameAnalytics Cordova sample.
 * Every line printed by this sample starts with the marker "GATEST:" (console and on-screen log).
 * Keys below are placeholders. Replace them with your own game key and secret key.
 */
var MARKER = "GATEST:";
var WAIT_AFTER_INIT_MS = 4000;
var WAIT_FOR_QUEUE_MS = 12000;
var WAIT_AFTER_END_MS = 4000;
var RC_POLL_INTERVAL_MS = 1000;
var RC_POLL_TIMEOUT_MS = 10000;

// Values this sample sets. There is no getter for custom dimensions, so they are echoed.
var DIMENSIONS = { d01: "ninja", d02: "dolphin", d03: "alliance" };

function log(message) {
    var line = MARKER + " " + message;
    console.log(line);
    var el = document.getElementById("galog");
    if (el) {
        el.appendChild(document.createTextNode(line + "\n"));
    }
}

// Returns an onComplete callback that logs which step finished.
function done(step) {
    return function (result) {
        log("complete " + step + (result !== undefined ? " result=" + result : ""));
    };
}

var app = {
    initialize: function () {
        document.addEventListener("deviceready", this.onDeviceReady.bind(this), false);
    },

    onDeviceReady: function () {
        this.receivedEvent("deviceready");
        log("deviceready");
        this.configure();
        setTimeout(this.sendEvents.bind(this), WAIT_AFTER_INIT_MS);
    },

    // Configure in order, then initialize, then start the session.
    configure: function () {
        log("step configure");
        GameAnalytics.setEnabledInfoLog(true, done("setEnabledInfoLog"));
        GameAnalytics.setEnabledVerboseLog(true, done("setEnabledVerboseLog"));
        GameAnalytics.configureBuild("0.1.0", done("configureBuild"));

        GameAnalytics.configureAvailableResourceCurrencies(["gems", "gold"], done("configureAvailableResourceCurrencies"));
        GameAnalytics.configureAvailableResourceItemTypes(["boost", "lives"], done("configureAvailableResourceItemTypes"));
        GameAnalytics.configureAvailableCustomDimensions01(["ninja", "samurai"], done("configureAvailableCustomDimensions01"));
        GameAnalytics.configureAvailableCustomDimensions02(["whale", "dolphin"], done("configureAvailableCustomDimensions02"));
        GameAnalytics.configureAvailableCustomDimensions03(["horde", "alliance"], done("configureAvailableCustomDimensions03"));

        GameAnalytics.setGlobalCustomEventFields(JSON.stringify({ globalField: "sample", globalNumber: 1 }), done("setGlobalCustomEventFields"));
        GameAnalytics.setEnabledManualSessionHandling(true, done("setEnabledManualSessionHandling"));

        GameAnalytics.setCustomDimension01(DIMENSIONS.d01, done("setCustomDimension01"));
        GameAnalytics.setCustomDimension02(DIMENSIONS.d02, done("setCustomDimension02"));
        GameAnalytics.setCustomDimension03(DIMENSIONS.d03, done("setCustomDimension03"));
        log("state customDimension01=" + DIMENSIONS.d01 + " customDimension02=" + DIMENSIONS.d02 + " customDimension03=" + DIMENSIONS.d03 + " (echoed, no getter)");

        GameAnalytics.initialize({
            gameKey: "your_game_key",
            secretKey: "your_secret_key"
        }, done("initialize"));
        GameAnalytics.startSession(done("startSession"));
        log("step initialized, waiting " + WAIT_AFTER_INIT_MS + "ms");
    },

    sendEvents: function () {
        var E = GameAnalytics;
        var custom = JSON.stringify({ customKey: "customValue", level: 3 });
        log("step sending events");

        log("event business plain");
        E.addBusinessEvent({ currency: "USD", amount: 100, itemType: "boost", itemId: "megaBoost", cartType: "shop" }, done("addBusinessEvent plain"));

        log("event business android receipt+signature (Google Play validation path)");
        E.addBusinessEvent({
            currency: "USD", amount: 100, itemType: "boost", itemId: "megaBoost", cartType: "shop",
            receipt: "<receipt>", signature: "<signature>"
        }, done("addBusinessEvent receipt"));

        log("event business ios autoFetchReceipt");
        E.addBusinessEvent({
            currency: "USD", amount: 100, itemType: "boost", itemId: "megaBoost", cartType: "shop",
            autoFetchReceipt: true
        }, done("addBusinessEvent autoFetchReceipt"));

        log("event business customFields mergeFields=true");
        E.addBusinessEvent({
            currency: "USD", amount: 100, itemType: "boost", itemId: "megaBoost", cartType: "shop",
            customFields: custom, mergeFields: true
        }, done("addBusinessEvent merge"));

        log("event resource source");
        E.addResourceEvent({ flowType: E.EGAResourceFlowType.Source, currency: "gems", amount: 50, itemType: "boost", itemId: "dailyReward" }, done("addResourceEvent source"));
        log("event resource sink");
        E.addResourceEvent({ flowType: E.EGAResourceFlowType.Sink, currency: "gold", amount: 10, itemType: "lives", itemId: "5lives" }, done("addResourceEvent sink"));

        log("event progression start");
        E.addProgressionEvent({ progressionStatus: E.EGAProgressionStatus.Start, progression01: "world1", progression02: "level1" }, done("addProgressionEvent start"));
        log("event progression complete score=100");
        E.addProgressionEvent({ progressionStatus: E.EGAProgressionStatus.Complete, progression01: "world1", progression02: "level1", score: 100 }, done("addProgressionEvent complete"));
        log("event progression fail");
        E.addProgressionEvent({ progressionStatus: E.EGAProgressionStatus.Fail, progression01: "world1", progression02: "level2", progression03: "boss1" }, done("addProgressionEvent fail"));

        log("event design no value");
        E.addDesignEvent({ eventId: "design:event" }, done("addDesignEvent plain"));
        log("event design value=10");
        E.addDesignEvent({ eventId: "design:event", value: 10 }, done("addDesignEvent value"));
        log("event design customFields mergeFields=false");
        E.addDesignEvent({ eventId: "design:custom", value: 1, customFields: custom, mergeFields: false }, done("addDesignEvent no merge"));

        log("event error severity=critical");
        E.addErrorEvent({ severity: E.EGAErrorSeverity.Critical, message: "This is a critical message" }, done("addErrorEvent critical"));
        log("event error severity=warning");
        E.addErrorEvent({ severity: E.EGAErrorSeverity.Warning, message: "This is a warning message" }, done("addErrorEvent warning"));
        log("event error severity=debug");
        E.addErrorEvent({ severity: E.EGAErrorSeverity.Debug, message: "This is a debug message" }, done("addErrorEvent debug"));

        log("event ad show");
        E.addAdEvent({ adAction: E.EGAAdAction.Show, adType: E.EGAAdType.Interstitial, adSdkName: "admob", adPlacement: "after_level" }, done("addAdEvent show"));
        log("event ad rewardReceived duration=5000");
        E.addAdEvent({ adAction: E.EGAAdAction.RewardReceived, adType: E.EGAAdType.RewardedVideo, adSdkName: "admob", adPlacement: "double_reward", duration: 5000 }, done("addAdEvent duration"));
        log("event ad failedShow noAdReason=noFill");
        E.addAdEvent({ adAction: E.EGAAdAction.FailedShow, adType: E.EGAAdType.Interstitial, adSdkName: "admob", adPlacement: "after_level", noAdReason: E.EGAAdError.NoFill }, done("addAdEvent noAdReason"));
        log("event ad request");
        E.addAdEvent({ adAction: E.EGAAdAction.Request, adType: E.EGAAdType.Banner, adSdkName: "admob", adPlacement: "menu_banner" }, done("addAdEvent request"));
        log("event ad loaded");
        E.addAdEvent({ adAction: E.EGAAdAction.Loaded, adType: E.EGAAdType.Banner, adSdkName: "admob", adPlacement: "menu_banner" }, done("addAdEvent loaded"));

        this.waitForRemoteConfigs();

        log("step waiting " + WAIT_FOR_QUEUE_MS + "ms for the queue to drain");
        setTimeout(this.finish.bind(this), WAIT_FOR_QUEUE_MS);
    },

    // Poll isRemoteConfigsReady, then read state. A/B ids are only read once it is true.
    waitForRemoteConfigs: function () {
        var started = Date.now();
        var self = this;
        function poll() {
            GameAnalytics.isRemoteConfigsReady(function (ready) {
                log("state remoteConfigsReady=" + ready);
                if (ready === true || ready === "true" || ready === 1) {
                    self.readState();
                } else if (Date.now() - started < RC_POLL_TIMEOUT_MS) {
                    setTimeout(poll, RC_POLL_INTERVAL_MS);
                } else {
                    log("state remote configs not ready after " + RC_POLL_TIMEOUT_MS + "ms, skipping A/B ids");
                }
            });
        }
        poll();
    },

    readState: function () {
        GameAnalytics.getRemoteConfigsContentAsString(function (result) {
            log("state remoteConfigsContent=" + result);
        });
        GameAnalytics.getRemoteConfigsValueAsString({ key: "ga_test", defaultValue: "default" }, function (result) {
            log("state remoteConfigsValue ga_test=" + result);
        });
        GameAnalytics.getABTestingId(function (result) {
            log("state abTestingId=" + result);
        });
        GameAnalytics.getABTestingVariantId(function (result) {
            log("state abTestingVariantId=" + result);
        });
    },

    finish: function () {
        log("step ending session");
        GameAnalytics.endSession(done("endSession"));
        setTimeout(function () {
            log("finished");
        }, WAIT_AFTER_END_MS);
    },

    receivedEvent: function (id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector(".listening");
        var receivedElement = parentElement.querySelector(".received");
        listeningElement.setAttribute("style", "display:none;");
        receivedElement.setAttribute("style", "display:block;");
    }
};

app.initialize();
