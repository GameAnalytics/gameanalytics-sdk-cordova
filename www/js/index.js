/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        document.addEventListener('deviceready', this.onDeviceReady.bind(this), false);
    },

    // deviceready Event Handler
    //
    // Bind any cordova events here. Common events are:
    // 'pause', 'resume', etc.
    onDeviceReady: function() {
        this.receivedEvent('deviceready');

        GameAnalytics.setEnabledInfoLog(true);
        GameAnalytics.setEnabledVerboseLog(true);

        GameAnalytics.configureAvailableResourceCurrencies(["gems", "gold"]);
        GameAnalytics.configureAvailableResourceItemTypes(["boost", "lives"]);

        GameAnalytics.configureAvailableCustomDimensions01(["ninja", "samurai"]);
        GameAnalytics.configureAvailableCustomDimensions02(["whale", "dolphin"]);
        GameAnalytics.configureAvailableCustomDimensions03(["horde", "alliance"]);

        GameAnalytics.configureBuild("0.1.0");
        //GameAnalytics.configureUserId("my_custom_id");

        GameAnalytics.setCustomDimension01("ninja");
        GameAnalytics.setCustomDimension02("dolphin");
        GameAnalytics.setCustomDimension03("alliance");

        GameAnalytics.initialize({
            gameKey: "your_game_key",
            secretKey: "your_secret_key"
        });

        setTimeout(() => {
            GameAnalytics.addBusinessEvent({
                currency: "USD",
                amount: 100,
                itemType: "boost",
                itemId: "megaBoost",
                cartType: "shop"
            });

            GameAnalytics.addBusinessEvent({
                currency: "USD",
                amount: 100,
                itemType: "boost",
                itemId: "megaBoost",
                cartType: "shop",
                receipt: "<receipt>",
                signature: "<signature>",
                autoFetchReceipt: true
            });

            GameAnalytics.addResourceEvent({
                flowType: GameAnalytics.EGAResourceFlowType.Sink,
                currency: "gold",
                amount: 10,
                itemType: "lives",
                itemId: "5lives"
            });

            GameAnalytics.addProgressionEvent({
                progressionStatus: GameAnalytics.EGAProgressionStatus.Start,
                progression01: "world1"
            });
            GameAnalytics.addProgressionEvent({
                progressionStatus: GameAnalytics.EGAProgressionStatus.Fail,
                progression01: "world1",
                score: 100
            });
            GameAnalytics.addProgressionEvent({
                progressionStatus: GameAnalytics.EGAProgressionStatus.Start,
                progression01: "world1",
                progression02: "level1"
            });
            GameAnalytics.addProgressionEvent({
                progressionStatus: GameAnalytics.EGAProgressionStatus.Complete,
                progression01: "world1",
                progression02: "level1",
                score: 100
            });
            GameAnalytics.addProgressionEvent({
                progressionStatus: GameAnalytics.EGAProgressionStatus.Start,
                progression01: "world1",
                progression02: "level1",
                progression03: "boss1"
            });
            GameAnalytics.addProgressionEvent({
                progressionStatus: GameAnalytics.EGAProgressionStatus.Fail,
                progression01: "world1",
                progression02: "level1",
                progression03: "boss1",
                score: 100
            });

            GameAnalytics.addDesignEvent({
                eventId: "design:event"
            });
            GameAnalytics.addDesignEvent({
                eventId: "design:event",
                value: 10
            });

            GameAnalytics.addErrorEvent({
                severity: GameAnalytics.EGAErrorSeverity.Critical,
                message: "This is a message!!"
            });
            GameAnalytics.addErrorEvent({
                severity: GameAnalytics.EGAErrorSeverity.Debug,
                message: "This is a message!!"
            });
            GameAnalytics.addErrorEvent({
                severity: GameAnalytics.EGAErrorSeverity.Error,
                message: "This is a message!!"
            });
            GameAnalytics.addErrorEvent({
                severity: GameAnalytics.EGAErrorSeverity.Info,
                message: "This is a message!!"
            });
            GameAnalytics.addErrorEvent({
                severity: GameAnalytics.EGAErrorSeverity.Warning,
                message: "This is a message!!"
            });

            GameAnalytics.addAdEvent({
                adAction: GameAnalytics.EGAAdAction.Show,
                adType: GameAnalytics.EGAAdType.Interstitial,
                adSdkName: "admob",
                adPlacement: "after_level"
            });
            GameAnalytics.addAdEvent({
                adAction: GameAnalytics.EGAAdAction.Clicked,
                adType: GameAnalytics.EGAAdType.Interstitial,
                adSdkName: "admob",
                adPlacement: "after_level"
            });

            GameAnalytics.isRemoteConfigsReady(result => {
                console.log("is RC ready? " + result);
            });
            GameAnalytics.getRemoteConfigsValueAsString({
                key: "ga_test"
            }, result => {
                console.log("getRemoteConfigsValueAsString: ga_test=" + result);
            });
            GameAnalytics.getABTestingId(result => {
                console.log("getABTestingId=" + result);
            });
            GameAnalytics.getABTestingVariantId(result => {
                console.log("getABTestingVariantId=" + result);
            });

        }, 2000);
    },

    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

app.initialize();
