// Unit tests for the iOS bridge. The real GameAnalyticsCordova.m is compiled
// against recording stubs of Cordova and the GameAnalytics SDK (see stubs/) and
// driven the way Cordova drives it: one CDVInvokedUrlCommand per call, with the
// arguments parsed from JSON.
#import <Foundation/Foundation.h>
#import <Cordova/Cordova.h>
#import <objc/message.h>
#import "GameAnalytics/GameAnalyticsWrapper.h"
#import "GameAnalyticsCordova.h"

static int gPassed = 0, gFailed = 0;
static NSString *gCurrent = @"";

#define CHECK(cond, ...) do { if (!(cond)) { gFailed++; printf("  FAIL  %s: %s (line %d)\n", gCurrent.UTF8String, [NSString stringWithFormat:__VA_ARGS__].UTF8String, __LINE__); return; } } while (0)

@interface Recorder : NSObject <CDVCommandDelegate>
@property (nonatomic, strong) NSMutableArray<CDVPluginResult *> *results;
@property (nonatomic, strong) NSMutableArray<NSString *> *callbackIds;
@end
@implementation Recorder
- (instancetype)init { if ((self = [super init])) { _results = [NSMutableArray array]; _callbackIds = [NSMutableArray array]; } return self; }
- (void)sendPluginResult:(CDVPluginResult *)result callbackId:(NSString *)callbackId { [_results addObject:result]; [_callbackIds addObject:callbackId]; }
@end

@interface Outcome : NSObject
@property BOOL handled;
@property (nonatomic, copy) NSString *exception;
@property (nonatomic, strong) NSArray *calls;
@property (nonatomic, strong) Recorder *recorder;
@end
@implementation Outcome
@end

static Outcome *Run(NSString *action, NSString *argsJson) {
    GACalls = [NSMutableArray array];
    GAStringResult = @"stub-string";
    GABoolResult = YES;
    Outcome *o = [Outcome new];
    o.recorder = [Recorder new];
    GameAnalyticsCordova *plugin = [GameAnalyticsCordova new];
    plugin.commandDelegate = o.recorder;
    NSArray *args = [NSJSONSerialization JSONObjectWithData:[argsJson dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    CDVInvokedUrlCommand *cmd = [[CDVInvokedUrlCommand alloc] initWithArguments:args callbackId:@"cb-1" className:@"GameAnalyticsCordova" methodName:action];
    SEL sel = NSSelectorFromString([action stringByAppendingString:@":"]);
    o.handled = [plugin respondsToSelector:sel];
    if (o.handled) {
        @try { ((void (*)(id, SEL, id))objc_msgSend)(plugin, sel, cmd); }
        @catch (NSException *e) { o.exception = [NSString stringWithFormat:@"%@: %@", e.name, e.reason]; }
    }
    o.calls = [GACalls copy];
    return o;
}

static id Nul(void) { return [NSNull null]; }

#define NO_THROW(o) CHECK((o).exception == nil, @"bridge threw %@", (o).exception)
#define HANDLED(o) CHECK((o).handled, @"action must be handled")
/// Exactly one native call, equal to @[selector, args...].
#define ONE_CALL(o, ...) do { NO_THROW(o); HANDLED(o); NSArray *exp_ = @[__VA_ARGS__]; \
    CHECK((o).calls.count == 1, @"native calls: %@", (o).calls); \
    CHECK([(o).calls[0] isEqual:exp_], @"expected %@ got %@", exp_, (o).calls[0]); } while (0)
/// Exactly one callback result with status OK on the right callback id and no message.
#define CALLBACK_ONCE(o) do { CHECK((o).recorder.results.count == 1, @"callback fired %lu times", (unsigned long)(o).recorder.results.count); \
    CHECK([(o).recorder.callbackIds[0] isEqualToString:@"cb-1"], @"wrong callback id"); \
    CHECK([(o).recorder.results[0].status isEqual:@(CDVCommandStatus_OK)], @"status %@", (o).recorder.results[0].status); } while (0)
#define RESULT_IS(o, expected) do { CALLBACK_ONCE(o); CHECK([(o).recorder.results[0].message isEqual:(expected)], @"result message %@", (o).recorder.results[0].message); } while (0)

static NSString *Q(NSString *s) {
    NSData *d = [NSJSONSerialization dataWithJSONObject:@[s] options:0 error:nil];
    NSString *arr = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
    return [arr substringWithRange:NSMakeRange(1, arr.length - 2)];
}

#pragma mark - test registry

typedef void (^TestBlock)(void);
static NSMutableArray *gNames, *gBlocks;
static void Test(NSString *name, TestBlock b) { [gNames addObject:name]; [gBlocks addObject:[b copy]]; }
#define T(name) Test(name, ^

static NSArray<NSArray<NSString *> *> *EveryAction(void) {
    return @[
        @[@"configureAvailableCustomDimensions01", @"[[\"a\",\"b\"]]"],
        @[@"configureAvailableCustomDimensions02", @"[[\"a\",\"b\"]]"],
        @[@"configureAvailableCustomDimensions03", @"[[\"a\",\"b\"]]"],
        @[@"configureAvailableResourceCurrencies", @"[[\"gems\"]]"],
        @[@"configureAvailableResourceItemTypes", @"[[\"boost\"]]"],
        @[@"configureBuild", @"[\"1.2.3\"]"],
        @[@"configureAutoDetectAppVersion", @"[true]"],
        @[@"configureUserId", @"[\"u1\"]"],
        @[@"initialize", @"[{\"gameKey\":\"GAME_KEY_PLACEHOLDER\",\"secretKey\":\"SECRET_KEY_PLACEHOLDER\"}]"],
        @[@"addBusinessEvent", @"[{\"currency\":\"USD\",\"amount\":99,\"itemType\":\"IAP\",\"itemId\":\"gems\",\"cartType\":\"shop\"}]"],
        @[@"addResourceEvent", @"[{\"flowType\":1,\"currency\":\"gems\",\"amount\":5,\"itemType\":\"boost\",\"itemId\":\"speed\"}]"],
        @[@"addProgressionEvent", @"[{\"progressionStatus\":1,\"progression01\":\"w1\"}]"],
        @[@"addDesignEvent", @"[{\"eventId\":\"ui:click\"}]"],
        @[@"addErrorEvent", @"[{\"severity\":4,\"message\":\"oops\"}]"],
        @[@"addAdEvent", @"[{\"adAction\":2,\"adType\":1,\"adSdkName\":\"s\",\"adPlacement\":\"p\"}]"],
        @[@"setEnabledInfoLog", @"[true]"],
        @[@"setEnabledVerboseLog", @"[true]"],
        @[@"setEnabledManualSessionHandling", @"[true]"],
        @[@"setEnabledEventSubmission", @"[false]"],
        @[@"setCustomDimension01", @"[\"x\"]"],
        @[@"setCustomDimension02", @"[\"x\"]"],
        @[@"setCustomDimension03", @"[\"x\"]"],
        @[@"setGlobalCustomEventFields", @"[\"{\\\"a\\\":1}\"]"],
        @[@"startSession", @"[]"],
        @[@"endSession", @"[]"],
        @[@"getRemoteConfigsValueAsString", @"[{\"key\":\"k\",\"defaultValue\":\"d\"}]"],
        @[@"isRemoteConfigsReady", @"[]"],
        @[@"getRemoteConfigsContentAsString", @"[]"],
        @[@"getABTestingId", @"[]"],
        @[@"getABTestingVariantId", @"[]"],
    ];
}

#define BIZ @"\"currency\":\"USD\",\"amount\":99,\"itemType\":\"IAP\",\"itemId\":\"gems_100\",\"cartType\":\"shop\""

static void Register(void) {
    T(@"surface: thirty actions") {
        CHECK(EveryAction().count == 30, @"count %lu", (unsigned long)EveryAction().count);
    });

    for (NSArray *a in EveryAction()) {
        NSString *action = a[0], *args = a[1];
        Test([NSString stringWithFormat:@"%@: is handled, reaches the SDK and completes the callback exactly once", action], ^{
            Outcome *o = Run(action, args);
            NO_THROW(o); HANDLED(o);
            CHECK(o.calls.count >= 1, @"must reach a GameAnalytics call");
            CALLBACK_ONCE(o);
        });
        // Cordova delivers a JSON null for an argument the game left out ([undefined] serialises to [null]).
        if (![args isEqualToString:@"[]"]) {
            Test([NSString stringWithFormat:@"%@: completes the callback exactly once when the argument is JSON null", action], ^{
                Outcome *o = Run(action, @"[null]");
                NO_THROW(o); HANDLED(o);
                CALLBACK_ONCE(o);
            });
        }
    }

    T(@"unknown action: is not handled (Cordova reports INVALID_ACTION) and the SDK is untouched") {
        Outcome *o = Run(@"doesNotExist", @"[]");
        CHECK(!o.handled, @"must not be handled");
        CHECK(o.calls.count == 0, @"%@", o.calls);
        CHECK(o.recorder.results.count == 0, @"no callback");
    });

    T(@"unsupported actions: functions outside the supported surface do not exist on the plugin") {
        for (NSString *n in @[@"getUserId", @"setEnabledWarningLog", @"addImpressionEvent", @"startTimer", @"addAdEventWithDuration", @"addDesignEventWithValue", @"Initialize"]) {
            Outcome *o = Run(n, @"[]");
            CHECK(!o.handled, @"%@ must not be handled", n);
        }
    });

    // ---- configure* ----
    T(@"configureAvailableCustomDimensions01: forwards the values in order") {
        Outcome *o = Run(@"configureAvailableCustomDimensions01", @"[[\"ninja\",\"samurai\"]]");
        ONE_CALL(o, @"configureAvailableCustomDimensions01:", (@[@"ninja", @"samurai"])); CALLBACK_ONCE(o);
    });
    T(@"configureAvailableCustomDimensions02: forwards the values in order") {
        Outcome *o = Run(@"configureAvailableCustomDimensions02", @"[[\"gold\",\"silver\",\"bronze\"]]");
        ONE_CALL(o, @"configureAvailableCustomDimensions02:", (@[@"gold", @"silver", @"bronze"])); CALLBACK_ONCE(o);
    });
    T(@"configureAvailableCustomDimensions03: forwards the values in order") {
        Outcome *o = Run(@"configureAvailableCustomDimensions03", @"[[\"a\",\"b\",\"c\"]]");
        ONE_CALL(o, @"configureAvailableCustomDimensions03:", (@[@"a", @"b", @"c"])); CALLBACK_ONCE(o);
    });
    T(@"configureAvailableResourceCurrencies: forwards the values") {
        Outcome *o = Run(@"configureAvailableResourceCurrencies", @"[[\"gems\",\"gold\"]]");
        ONE_CALL(o, @"configureAvailableResourceCurrencies:", (@[@"gems", @"gold"])); CALLBACK_ONCE(o);
    });
    T(@"configureAvailableResourceItemTypes: forwards the values") {
        Outcome *o = Run(@"configureAvailableResourceItemTypes", @"[[\"boost\",\"lives\"]]");
        ONE_CALL(o, @"configureAvailableResourceItemTypes:", (@[@"boost", @"lives"])); CALLBACK_ONCE(o);
    });
    T(@"configureAvailableCustomDimensions01: an empty array forwards an empty array") {
        Outcome *o = Run(@"configureAvailableCustomDimensions01", @"[[]]");
        ONE_CALL(o, @"configureAvailableCustomDimensions01:", @[]);
    });
    T(@"configureAvailableCustomDimensions01: unicode and quotes are kept") {
        NSString *v = @"café 日本語 \"q\" \\ \U0001F600";
        Outcome *o = Run(@"configureAvailableCustomDimensions01", [NSString stringWithFormat:@"[[%@]]", Q(v)]);
        ONE_CALL(o, @"configureAvailableCustomDimensions01:", @[v]);
    });
    T(@"configureBuild: forwards the build string") {
        Outcome *o = Run(@"configureBuild", @"[\"1.2.3\"]");
        ONE_CALL(o, @"configureBuild:", @"1.2.3"); CALLBACK_ONCE(o);
    });
    T(@"configureBuild: a very long string is forwarded unchanged") {
        NSString *v = [@"" stringByPaddingToLength:20000 withString:@"x" startingAtIndex:0];
        Outcome *o = Run(@"configureBuild", [NSString stringWithFormat:@"[%@]", Q(v)]);
        ONE_CALL(o, @"configureBuild:", v);
    });
    T(@"configureAutoDetectAppVersion: forwards true") {
        Outcome *o = Run(@"configureAutoDetectAppVersion", @"[true]");
        ONE_CALL(o, @"configureAutoDetectAppVersion:", @YES); CALLBACK_ONCE(o);
    });
    T(@"configureAutoDetectAppVersion: forwards false") {
        Outcome *o = Run(@"configureAutoDetectAppVersion", @"[false]");
        ONE_CALL(o, @"configureAutoDetectAppVersion:", @NO); CALLBACK_ONCE(o);
    });
    T(@"configureUserId: forwards the id") {
        Outcome *o = Run(@"configureUserId", @"[\"player-42\"]");
        ONE_CALL(o, @"configureUserId:", @"player-42"); CALLBACK_ONCE(o);
    });

    // ---- initialize ----
    T(@"initialize: passes both keys to the SDK") {
        Outcome *o = Run(@"initialize", @"[{\"gameKey\":\"GAME_KEY_PLACEHOLDER\",\"secretKey\":\"SECRET_KEY_PLACEHOLDER\"}]");
        NO_THROW(o); HANDLED(o);
        NSArray *last = o.calls.lastObject;
        CHECK([last isEqual:(@[@"initializeWithGameKey:gameSecret:", @"GAME_KEY_PLACEHOLDER", @"SECRET_KEY_PLACEHOLDER"])], @"%@", last);
        CALLBACK_ONCE(o);
    });
    T(@"initialize: identifies the plugin as the wrapper before initializing") {
        Outcome *o = Run(@"initialize", @"[{\"gameKey\":\"k\",\"secretKey\":\"s\"}]");
        CHECK(o.calls.count == 2, @"%@", o.calls);
        NSString *pkg = [NSString stringWithContentsOfFile:@"../../gameanalytics/package.json" encoding:NSUTF8StringEncoding error:nil];
        NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"\"version\"\\s*:\\s*\"([^\"]+)\"" options:0 error:nil];
        NSTextCheckingResult *m = [re firstMatchInString:pkg ?: @"" options:0 range:NSMakeRange(0, pkg.length)];
        CHECK(m != nil, @"cannot read the plugin version");
        NSString *version = [pkg substringWithRange:[m rangeAtIndex:1]];
        CHECK([o.calls[0] isEqual:(@[@"configureSdkVersion:", [@"cordova " stringByAppendingString:version]])], @"%@", o.calls[0]);
        CHECK([o.calls[1][0] isEqual:@"initializeWithGameKey:gameSecret:"], @"%@", o.calls[1]);
    });

    // ---- business ----
    T(@"addBusinessEvent: without a receipt uses the receipt overload with an empty receipt") {
        Outcome *o = Run(@"addBusinessEvent", [NSString stringWithFormat:@"[{%@}]", BIZ]);
        ONE_CALL(o, @"addBusinessEventWithCurrency:amount:itemType:itemId:cartType:receipt:customFields:mergeFields:",
                 @"USD", @99, @"IAP", @"gems_100", @"shop", @"", Nul(), @NO);
        CALLBACK_ONCE(o);
    });
    T(@"addBusinessEvent: with a receipt forwards the receipt, custom fields as a dictionary and mergeFields") {
        Outcome *o = Run(@"addBusinessEvent", [NSString stringWithFormat:@"[{%@,\"receipt\":\"RECEIPT\",\"customFields\":\"{\\\"promo\\\":\\\"summer\\\",\\\"n\\\":1.5}\",\"mergeFields\":true}]", BIZ]);
        ONE_CALL(o, @"addBusinessEventWithCurrency:amount:itemType:itemId:cartType:receipt:customFields:mergeFields:",
                 @"USD", @99, @"IAP", @"gems_100", @"shop", @"RECEIPT", (@{@"promo": @"summer", @"n": @1.5}), @YES);
    });
    T(@"addBusinessEvent: autoFetchReceipt true selects the auto-fetch overload") {
        Outcome *o = Run(@"addBusinessEvent", [NSString stringWithFormat:@"[{%@,\"autoFetchReceipt\":true,\"customFields\":\"{\\\"a\\\":1}\",\"mergeFields\":true}]", BIZ]);
        ONE_CALL(o, @"addBusinessEventWithCurrency:amount:itemType:itemId:cartType:autoFetchReceipt:customFields:mergeFields:",
                 @"USD", @99, @"IAP", @"gems_100", @"shop", @YES, (@{@"a": @1}), @YES);
        CALLBACK_ONCE(o);
    });
    T(@"addBusinessEvent: autoFetchReceipt false keeps the receipt overload") {
        Outcome *o = Run(@"addBusinessEvent", [NSString stringWithFormat:@"[{%@,\"autoFetchReceipt\":false,\"receipt\":\"R\"}]", BIZ]);
        CHECK([o.calls[0][0] isEqual:@"addBusinessEventWithCurrency:amount:itemType:itemId:cartType:receipt:customFields:mergeFields:"], @"%@", o.calls);
        CHECK([o.calls[0][6] isEqual:@"R"], @"%@", o.calls);
    });
    T(@"addBusinessEvent: the Android signature key is ignored on iOS") {
        Outcome *o = Run(@"addBusinessEvent", [NSString stringWithFormat:@"[{%@,\"receipt\":\"R\",\"signature\":\"S\"}]", BIZ]);
        CHECK(o.calls.count == 1, @"%@", o.calls);
        CHECK([o.calls[0][0] isEqual:@"addBusinessEventWithCurrency:amount:itemType:itemId:cartType:receipt:customFields:mergeFields:"], @"%@", o.calls);
    });
    T(@"addBusinessEvent: unicode in the item id is kept") {
        Outcome *o = Run(@"addBusinessEvent", [NSString stringWithFormat:@"[{\"currency\":\"EUR\",\"amount\":1,\"itemType\":\"t\",\"itemId\":%@,\"cartType\":\"c\"}]", Q(@"sword ⚔ é")]);
        CHECK([o.calls[0][4] isEqual:@"sword ⚔ é"], @"%@", o.calls);
    });

    // ---- resource ----
    T(@"addResourceEvent: forwards flow type, amount and strings") {
        Outcome *o = Run(@"addResourceEvent", @"[{\"flowType\":2,\"currency\":\"gems\",\"amount\":2.5,\"itemType\":\"boost\",\"itemId\":\"speed\"}]");
        ONE_CALL(o, @"addResourceEventWithFlowType:currency:amount:itemType:itemId:customFields:mergeFields:",
                 @(GAResourceFlowTypeSink), @"gems", @2.5, @"boost", @"speed", Nul(), @NO);
        CALLBACK_ONCE(o);
    });
    T(@"addResourceEvent: Source flow type is one") {
        Outcome *o = Run(@"addResourceEvent", @"[{\"flowType\":1,\"currency\":\"gold\",\"amount\":10,\"itemType\":\"chest\",\"itemId\":\"c1\"}]");
        CHECK([o.calls[0][1] isEqual:@1], @"%@", o.calls);
        CHECK([o.calls[0][3] isEqual:@10], @"%@", o.calls);
    });
    T(@"addResourceEvent: forwards custom fields and mergeFields") {
        Outcome *o = Run(@"addResourceEvent", @"[{\"flowType\":1,\"currency\":\"gold\",\"amount\":1,\"itemType\":\"a\",\"itemId\":\"b\",\"customFields\":\"{\\\"k\\\":\\\"v\\\"}\",\"mergeFields\":true}]");
        ONE_CALL(o, @"addResourceEventWithFlowType:currency:amount:itemType:itemId:customFields:mergeFields:",
                 @1, @"gold", @1, @"a", @"b", (@{@"k": @"v"}), @YES);
    });

    // ---- progression ----
    T(@"addProgressionEvent: without score uses the no-score overload") {
        Outcome *o = Run(@"addProgressionEvent", @"[{\"progressionStatus\":1,\"progression01\":\"world1\",\"progression02\":\"level2\",\"progression03\":\"boss\"}]");
        ONE_CALL(o, @"addProgressionEventWithProgressionStatus:progression01:progression02:progression03:customFields:mergeFields:",
                 @1, @"world1", @"level2", @"boss", Nul(), @NO);
        CALLBACK_ONCE(o);
    });
    T(@"addProgressionEvent: with score uses the with-score overload") {
        Outcome *o = Run(@"addProgressionEvent", @"[{\"progressionStatus\":2,\"progression01\":\"world1\",\"progression02\":\"level2\",\"progression03\":\"boss\",\"score\":1500}]");
        ONE_CALL(o, @"addProgressionEventWithProgressionStatus:progression01:progression02:progression03:score:customFields:mergeFields:",
                 @2, @"world1", @"level2", @"boss", @1500, Nul(), @NO);
        CALLBACK_ONCE(o);
    });
    T(@"addProgressionEvent: a score of zero still uses the with-score overload") {
        Outcome *o = Run(@"addProgressionEvent", @"[{\"progressionStatus\":3,\"progression01\":\"w\",\"score\":0}]");
        CHECK([o.calls[0][0] isEqual:@"addProgressionEventWithProgressionStatus:progression01:progression02:progression03:score:customFields:mergeFields:"], @"%@", o.calls);
        CHECK([o.calls[0][5] isEqual:@0], @"%@", o.calls);
    });
    T(@"addProgressionEvent: a negative score is forwarded") {
        Outcome *o = Run(@"addProgressionEvent", @"[{\"progressionStatus\":3,\"progression01\":\"w\",\"score\":-50}]");
        CHECK([o.calls[0][5] isEqual:@(-50)], @"%@", o.calls);
    });
    T(@"addProgressionEvent: with score forwards custom fields and mergeFields") {
        Outcome *o = Run(@"addProgressionEvent", @"[{\"progressionStatus\":2,\"progression01\":\"w\",\"progression02\":\"l\",\"progression03\":\"\",\"score\":7,\"customFields\":\"{\\\"a\\\":1}\",\"mergeFields\":true}]");
        ONE_CALL(o, @"addProgressionEventWithProgressionStatus:progression01:progression02:progression03:score:customFields:mergeFields:",
                 @2, @"w", @"l", @"", @7, (@{@"a": @1}), @YES);
    });
    T(@"addProgressionEvent: only progression01 leaves the other tiers empty") {
        Outcome *o = Run(@"addProgressionEvent", @"[{\"progressionStatus\":1,\"progression01\":\"w\"}]");
        CHECK([o.calls[0][2] isEqual:@"w"] && [o.calls[0][3] isEqual:@""] && [o.calls[0][4] isEqual:@""], @"%@", o.calls);
    });

    // ---- design ----
    T(@"addDesignEvent: without value uses the no-value overload") {
        Outcome *o = Run(@"addDesignEvent", @"[{\"eventId\":\"ui:click:play\"}]");
        ONE_CALL(o, @"addDesignEventWithEventId:customFields:mergeFields:", @"ui:click:play", Nul(), @NO);
        CALLBACK_ONCE(o);
    });
    T(@"addDesignEvent: with value uses the with-value overload") {
        Outcome *o = Run(@"addDesignEvent", @"[{\"eventId\":\"ui:click:play\",\"value\":3.5}]");
        ONE_CALL(o, @"addDesignEventWithEventId:value:customFields:mergeFields:", @"ui:click:play", @3.5, Nul(), @NO);
        CALLBACK_ONCE(o);
    });
    T(@"addDesignEvent: a value of zero still uses the with-value overload") {
        Outcome *o = Run(@"addDesignEvent", @"[{\"eventId\":\"e\",\"value\":0}]");
        ONE_CALL(o, @"addDesignEventWithEventId:value:customFields:mergeFields:", @"e", @0, Nul(), @NO);
    });
    T(@"addDesignEvent: a negative value is forwarded") {
        Outcome *o = Run(@"addDesignEvent", @"[{\"eventId\":\"e\",\"value\":-2.25}]");
        CHECK([o.calls[0][2] isEqual:@(-2.25)], @"%@", o.calls);
    });
    T(@"addDesignEvent: with value forwards custom fields and mergeFields") {
        Outcome *o = Run(@"addDesignEvent", @"[{\"eventId\":\"e\",\"value\":1,\"customFields\":\"{\\\"a\\\":true}\",\"mergeFields\":true}]");
        ONE_CALL(o, @"addDesignEventWithEventId:value:customFields:mergeFields:", @"e", @1, (@{@"a": @YES}), @YES);
    });
    T(@"addDesignEvent: without value forwards custom fields and mergeFields") {
        Outcome *o = Run(@"addDesignEvent", @"[{\"eventId\":\"e\",\"customFields\":\"{\\\"a\\\":true}\",\"mergeFields\":true}]");
        ONE_CALL(o, @"addDesignEventWithEventId:customFields:mergeFields:", @"e", (@{@"a": @YES}), @YES);
    });
    T(@"addDesignEvent: unicode and escapes in the event id and fields are kept") {
        NSString *eid = @"café:日本語";
        NSString *fields = @"{\"quote\":\"say \\\"hi\\\"\",\"emoji\":\"\U0001F600\"}";
        Outcome *o = Run(@"addDesignEvent", [NSString stringWithFormat:@"[{\"eventId\":%@,\"customFields\":%@}]", Q(eid), Q(fields)]);
        ONE_CALL(o, @"addDesignEventWithEventId:customFields:mergeFields:", eid, (@{@"quote": @"say \"hi\"", @"emoji": @"\U0001F600"}), @NO);
    });
    T(@"addDesignEvent: an empty event id is forwarded as an empty string") {
        Outcome *o = Run(@"addDesignEvent", @"[{\"eventId\":\"\"}]");
        CHECK([o.calls[0][1] isEqual:@""], @"%@", o.calls);
    });

    // ---- error ----
    T(@"addErrorEvent: forwards severity and message") {
        Outcome *o = Run(@"addErrorEvent", @"[{\"severity\":4,\"message\":\"something broke\"}]");
        ONE_CALL(o, @"addErrorEventWithSeverity:message:customFields:mergeFields:", @4, @"something broke", Nul(), @NO);
        CALLBACK_ONCE(o);
    });
    T(@"addErrorEvent: Critical severity is five, with custom fields and mergeFields") {
        Outcome *o = Run(@"addErrorEvent", @"[{\"severity\":5,\"message\":\"m\",\"customFields\":\"{\\\"a\\\":1}\",\"mergeFields\":true}]");
        ONE_CALL(o, @"addErrorEventWithSeverity:message:customFields:mergeFields:", @5, @"m", (@{@"a": @1}), @YES);
    });
    T(@"addErrorEvent: multiline and unicode messages are kept") {
        NSString *m = @"line1\nline2\t\"quoted\" \\ é \U0001F600";
        Outcome *o = Run(@"addErrorEvent", [NSString stringWithFormat:@"[{\"severity\":2,\"message\":%@}]", Q(m)]);
        CHECK([o.calls[0][2] isEqual:m], @"%@", o.calls);
    });

    // ---- ad ----
    T(@"addAdEvent: with duration uses the with-duration overload") {
        Outcome *o = Run(@"addAdEvent", @"[{\"adAction\":2,\"adType\":2,\"adSdkName\":\"admob\",\"adPlacement\":\"level_end\",\"duration\":30}]");
        ONE_CALL(o, @"addAdEventWithAction:adType:adSdkName:adPlacement:duration:customFields:mergeFields:",
                 @2, @2, @"admob", @"level_end", @30, Nul(), @NO);
        CALLBACK_ONCE(o);
    });
    T(@"addAdEvent: a duration of zero still uses the with-duration overload") {
        Outcome *o = Run(@"addAdEvent", @"[{\"adAction\":2,\"adType\":1,\"adSdkName\":\"s\",\"adPlacement\":\"p\",\"duration\":0}]");
        CHECK([o.calls[0][0] isEqual:@"addAdEventWithAction:adType:adSdkName:adPlacement:duration:customFields:mergeFields:"], @"%@", o.calls);
    });
    T(@"addAdEvent: without duration uses the with-reason overload") {
        Outcome *o = Run(@"addAdEvent", @"[{\"adAction\":3,\"adType\":4,\"adSdkName\":\"admob\",\"adPlacement\":\"p\",\"noAdReason\":3}]");
        ONE_CALL(o, @"addAdEventWithAction:adType:adSdkName:adPlacement:noAdReason:customFields:mergeFields:",
                 @3, @4, @"admob", @"p", @3, Nul(), @NO);
        CALLBACK_ONCE(o);
    });
    T(@"addAdEvent: with neither duration nor reason sends reason undefined (zero)") {
        Outcome *o = Run(@"addAdEvent", @"[{\"adAction\":1,\"adType\":6,\"adSdkName\":\"s\",\"adPlacement\":\"p\"}]");
        ONE_CALL(o, @"addAdEventWithAction:adType:adSdkName:adPlacement:noAdReason:customFields:mergeFields:", @1, @6, @"s", @"p", @0, Nul(), @NO);
    });
    T(@"addAdEvent: the Request and Loaded actions are forwarded as 5 and 6") {
        Outcome *r = Run(@"addAdEvent", @"[{\"adAction\":5,\"adType\":1,\"adSdkName\":\"s\",\"adPlacement\":\"p\"}]");
        Outcome *l = Run(@"addAdEvent", @"[{\"adAction\":6,\"adType\":1,\"adSdkName\":\"s\",\"adPlacement\":\"p\"}]");
        CHECK([r.calls[0][1] isEqual:@5] && [l.calls[0][1] isEqual:@6], @"%@ %@", r.calls, l.calls);
    });
    T(@"addAdEvent: forwards custom fields and mergeFields") {
        Outcome *o = Run(@"addAdEvent", @"[{\"adAction\":2,\"adType\":1,\"adSdkName\":\"s\",\"adPlacement\":\"p\",\"duration\":5,\"customFields\":\"{\\\"a\\\":1}\",\"mergeFields\":true}]");
        ONE_CALL(o, @"addAdEventWithAction:adType:adSdkName:adPlacement:duration:customFields:mergeFields:", @2, @1, @"s", @"p", @5, (@{@"a": @1}), @YES);
    });

    // ---- flags and strings ----
    NSArray *flags = @[@"setEnabledInfoLog", @"setEnabledVerboseLog", @"setEnabledManualSessionHandling", @"setEnabledEventSubmission"];
    for (NSString *name in flags) {
        Test([NSString stringWithFormat:@"%@: forwards true and false", name], ^{
            Outcome *t = Run(name, @"[true]");
            ONE_CALL(t, [name stringByAppendingString:@":"], @YES); CALLBACK_ONCE(t);
            Outcome *f = Run(name, @"[false]");
            ONE_CALL(f, [name stringByAppendingString:@":"], @NO); CALLBACK_ONCE(f);
        });
    }
    T(@"setCustomDimension01: forwards the value") {
        Outcome *o = Run(@"setCustomDimension01", @"[\"ninja\"]"); ONE_CALL(o, @"setCustomDimension01:", @"ninja"); CALLBACK_ONCE(o);
    });
    T(@"setCustomDimension02: forwards the value") {
        Outcome *o = Run(@"setCustomDimension02", @"[\"gold\"]"); ONE_CALL(o, @"setCustomDimension02:", @"gold"); CALLBACK_ONCE(o);
    });
    T(@"setCustomDimension03: forwards the value") {
        Outcome *o = Run(@"setCustomDimension03", @"[\"c\"]"); ONE_CALL(o, @"setCustomDimension03:", @"c"); CALLBACK_ONCE(o);
    });
    T(@"setCustomDimension01: an empty string is forwarded as an empty string") {
        Outcome *o = Run(@"setCustomDimension01", @"[\"\"]"); ONE_CALL(o, @"setCustomDimension01:", @"");
    });
    T(@"setCustomDimension02: unicode is kept") {
        NSString *v = @"日本語 é";
        Outcome *o = Run(@"setCustomDimension02", [NSString stringWithFormat:@"[%@]", Q(v)]); ONE_CALL(o, @"setCustomDimension02:", v);
    });
    T(@"setGlobalCustomEventFields: the JSON string reaches the SDK as a dictionary") {
        NSString *json = @"{\"level\":3,\"name\":\"café \\\"x\\\"\",\"nested\":{\"a\":[1,2]}}";
        Outcome *o = Run(@"setGlobalCustomEventFields", [NSString stringWithFormat:@"[%@]", Q(json)]);
        ONE_CALL(o, @"setGlobalCustomEventFields:", (@{@"level": @3, @"name": @"café \"x\"", @"nested": @{@"a": @[@1, @2]}}));
        CALLBACK_ONCE(o);
    });

    // ---- sessions ----
    T(@"startSession: reaches the SDK") { Outcome *o = Run(@"startSession", @"[]"); ONE_CALL(o, @"startSession"); CALLBACK_ONCE(o); });
    T(@"endSession: reaches the SDK") { Outcome *o = Run(@"endSession", @"[]"); ONE_CALL(o, @"endSession"); CALLBACK_ONCE(o); });

    // ---- remote configs and A/B testing ----
    T(@"getRemoteConfigsValueAsString: with a default returns the SDK value through the callback") {
        Outcome *o = Run(@"getRemoteConfigsValueAsString", @"[{\"key\":\"difficulty\",\"defaultValue\":\"normal\"}]");
        ONE_CALL(o, @"getRemoteConfigsValueAsString:defaultValue:", @"difficulty", @"normal");
        RESULT_IS(o, @"stub-string");
    });
    T(@"getRemoteConfigsValueAsString: without a default still reads the key") {
        Outcome *o = Run(@"getRemoteConfigsValueAsString", @"[{\"key\":\"difficulty\"}]");
        NO_THROW(o);
        CHECK(o.calls.count == 1, @"%@", o.calls);
        NSArray *c = o.calls[0];
        BOOL oneArg = [c isEqual:(@[@"getRemoteConfigsValueAsString:", @"difficulty"])];
        BOOL emptyDefault = [c isEqual:(@[@"getRemoteConfigsValueAsString:defaultValue:", @"difficulty", @""])];
        CHECK(oneArg || emptyDefault, @"%@", c);
        RESULT_IS(o, @"stub-string");
    });
    T(@"isRemoteConfigsReady: returns a boolean through the callback") {
        Outcome *o = Run(@"isRemoteConfigsReady", @"[]");
        ONE_CALL(o, @"isRemoteConfigsReady"); RESULT_IS(o, @YES);
    });
    T(@"isRemoteConfigsReady: false is returned as false") {
        GACalls = nil;
        Outcome *o = [Outcome new]; o.recorder = [Recorder new];
        GABoolResult = NO;
        GameAnalyticsCordova *p = [GameAnalyticsCordova new]; p.commandDelegate = o.recorder;
        [p isRemoteConfigsReady:[[CDVInvokedUrlCommand alloc] initWithArguments:@[] callbackId:@"cb-1" className:@"c" methodName:@"m"]];
        GABoolResult = YES;
        CHECK(o.recorder.results.count == 1, @"callback count");
        CHECK([o.recorder.results[0].message isEqual:@NO], @"%@", o.recorder.results[0].message);
    });
    T(@"getRemoteConfigsContentAsString: returns the content through the callback") {
        Outcome *o = Run(@"getRemoteConfigsContentAsString", @"[]");
        ONE_CALL(o, @"getRemoteConfigsContentAsString"); RESULT_IS(o, @"stub-string");
    });
    T(@"getABTestingId: returns the id through the callback") {
        Outcome *o = Run(@"getABTestingId", @"[]");
        ONE_CALL(o, @"getABTestingId"); RESULT_IS(o, @"stub-string");
    });
    T(@"getABTestingVariantId: returns the id through the callback") {
        Outcome *o = Run(@"getABTestingVariantId", @"[]");
        ONE_CALL(o, @"getABTestingVariantId"); RESULT_IS(o, @"stub-string");
    });
}

int main(int argc, const char *argv[]) {
    @autoreleasepool {
        gNames = [NSMutableArray array]; gBlocks = [NSMutableArray array];
        Register();
        for (NSUInteger i = 0; i < gNames.count; i++) {
            gCurrent = gNames[i];
            int before = gFailed;
            @try { ((TestBlock)gBlocks[i])(); }
            @catch (NSException *e) { gFailed++; printf("  FAIL  %s: uncaught %s\n", gCurrent.UTF8String, e.reason.UTF8String); }
            if (gFailed == before) { gPassed++; printf("  ok    %s\n", gCurrent.UTF8String); }
        }
        printf("\n%d passed, %d failed\n", gPassed, gFailed);
    }
    return gFailed == 0 ? 0 : 1;
}
