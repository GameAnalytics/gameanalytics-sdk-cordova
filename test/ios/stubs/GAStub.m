#import "GameAnalytics/GameAnalyticsWrapper.h"

NSMutableArray *GACalls;
NSString *GAStringResult = @"stub-string";
BOOL GABoolResult = YES;

static void GARecord(SEL sel, NSArray *args) {
    if (!GACalls) GACalls = [NSMutableArray array];
    NSMutableArray *call = [NSMutableArray arrayWithObject:NSStringFromSelector(sel)];
    for (id a in args) [call addObject:a ?: [NSNull null]];
    [GACalls addObject:call];
}

#define N(x) ((id)(x) ?: [NSNull null])

@implementation GameAnalytics

+ (void)configureSdkVersion:(NSString *)wrapperSdkVersion
{
    GARecord(_cmd, @[N(wrapperSdkVersion)]);
}

+ (void)configureAvailableCustomDimensions01:(NSArray *)customDimensions
{
    GARecord(_cmd, @[N(customDimensions)]);
}

+ (void)configureAvailableCustomDimensions02:(NSArray *)customDimensions
{
    GARecord(_cmd, @[N(customDimensions)]);
}

+ (void)configureAvailableCustomDimensions03:(NSArray *)customDimensions
{
    GARecord(_cmd, @[N(customDimensions)]);
}

+ (void)configureAvailableResourceCurrencies:(NSArray *)resourceCurrencies
{
    GARecord(_cmd, @[N(resourceCurrencies)]);
}

+ (void)configureAvailableResourceItemTypes:(NSArray *)resourceItemTypes
{
    GARecord(_cmd, @[N(resourceItemTypes)]);
}

+ (void)configureBuild:(NSString *)build
{
    GARecord(_cmd, @[N(build)]);
}

+ (void)configureUserId:(NSString *)userId
{
    GARecord(_cmd, @[N(userId)]);
}

+ (void)configureAutoDetectAppVersion:(BOOL)flag
{
    GARecord(_cmd, @[@(flag)]);
}

+ (void)initializeWithGameKey:(NSString *)gameKey gameSecret:(NSString *)gameSecret
{
    GARecord(_cmd, @[N(gameKey), N(gameSecret)]);
}

+ (void)addBusinessEventWithCurrency:(NSString *)currency amount:(NSInteger)amount itemType:(NSString *)itemType itemId:(NSString *)itemId cartType:(NSString *)cartType receipt:(NSString *)receipt
{
    GARecord(_cmd, @[N(currency), @(amount), N(itemType), N(itemId), N(cartType), N(receipt)]);
}

+ (void)addBusinessEventWithCurrency:(NSString *)currency amount:(NSInteger)amount itemType:(NSString *)itemType itemId:(NSString *)itemId cartType:(NSString *)cartType receipt:(NSString *)receipt customFields:(NSDictionary *)customFields
{
    GARecord(_cmd, @[N(currency), @(amount), N(itemType), N(itemId), N(cartType), N(receipt), N(customFields)]);
}

+ (void)addBusinessEventWithCurrency:(NSString *)currency amount:(NSInteger)amount itemType:(NSString *)itemType itemId:(NSString *)itemId cartType:(NSString *)cartType receipt:(NSString *)receipt customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields
{
    GARecord(_cmd, @[N(currency), @(amount), N(itemType), N(itemId), N(cartType), N(receipt), N(customFields), @(mergeFields)]);
}

+ (void)addBusinessEventWithCurrency:(NSString *)currency amount:(NSInteger)amount itemType:(NSString *)itemType itemId:(NSString *)itemId cartType:(NSString *)cartType autoFetchReceipt:(BOOL)autoFetchReceipt
{
    GARecord(_cmd, @[N(currency), @(amount), N(itemType), N(itemId), N(cartType), @(autoFetchReceipt)]);
}

+ (void)addBusinessEventWithCurrency:(NSString *)currency amount:(NSInteger)amount itemType:(NSString *)itemType itemId:(NSString *)itemId cartType:(NSString *)cartType autoFetchReceipt:(BOOL)autoFetchReceipt customFields:(NSDictionary *)customFields
{
    GARecord(_cmd, @[N(currency), @(amount), N(itemType), N(itemId), N(cartType), @(autoFetchReceipt), N(customFields)]);
}

+ (void)addBusinessEventWithCurrency:(NSString *)currency amount:(NSInteger)amount itemType:(NSString *)itemType itemId:(NSString *)itemId cartType:(NSString *)cartType autoFetchReceipt:(BOOL)autoFetchReceipt customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields
{
    GARecord(_cmd, @[N(currency), @(amount), N(itemType), N(itemId), N(cartType), @(autoFetchReceipt), N(customFields), @(mergeFields)]);
}

+ (void)addResourceEventWithFlowType:(GAResourceFlowType)flowType currency:(NSString *)currency amount:(NSNumber *)amount itemType:(NSString *)itemType itemId:(NSString *)itemId
{
    GARecord(_cmd, @[@(flowType), N(currency), N(amount), N(itemType), N(itemId)]);
}

+ (void)addResourceEventWithFlowType:(GAResourceFlowType)flowType currency:(NSString *)currency amount:(NSNumber *)amount itemType:(NSString *)itemType itemId:(NSString *)itemId customFields:(NSDictionary *)customFields
{
    GARecord(_cmd, @[@(flowType), N(currency), N(amount), N(itemType), N(itemId), N(customFields)]);
}

+ (void)addResourceEventWithFlowType:(GAResourceFlowType)flowType currency:(NSString *)currency amount:(NSNumber *)amount itemType:(NSString *)itemType itemId:(NSString *)itemId customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields
{
    GARecord(_cmd, @[@(flowType), N(currency), N(amount), N(itemType), N(itemId), N(customFields), @(mergeFields)]);
}

+ (void)addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:(NSString *)progression01 progression02:(NSString *)progression02 progression03:(NSString *)progression03
{
    GARecord(_cmd, @[@(progressionStatus), N(progression01), N(progression02), N(progression03)]);
}

+ (void)addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:(NSString *)progression01 progression02:(NSString *)progression02 progression03:(NSString *)progression03 customFields:(NSDictionary *)customFields
{
    GARecord(_cmd, @[@(progressionStatus), N(progression01), N(progression02), N(progression03), N(customFields)]);
}

+ (void)addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:(NSString *)progression01 progression02:(NSString *)progression02 progression03:(NSString *)progression03 customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields
{
    GARecord(_cmd, @[@(progressionStatus), N(progression01), N(progression02), N(progression03), N(customFields), @(mergeFields)]);
}

+ (void)addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:(NSString *)progression01 progression02:(NSString *)progression02 progression03:(NSString *)progression03 score:(NSInteger)score
{
    GARecord(_cmd, @[@(progressionStatus), N(progression01), N(progression02), N(progression03), @(score)]);
}

+ (void)addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:(NSString *)progression01 progression02:(NSString *)progression02 progression03:(NSString *)progression03 score:(NSInteger)score customFields:(NSDictionary *)customFields
{
    GARecord(_cmd, @[@(progressionStatus), N(progression01), N(progression02), N(progression03), @(score), N(customFields)]);
}

+ (void)addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:(NSString *)progression01 progression02:(NSString *)progression02 progression03:(NSString *)progression03 score:(NSInteger)score customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields
{
    GARecord(_cmd, @[@(progressionStatus), N(progression01), N(progression02), N(progression03), @(score), N(customFields), @(mergeFields)]);
}

+ (void)addDesignEventWithEventId:(NSString *)eventId
{
    GARecord(_cmd, @[N(eventId)]);
}

+ (void)addDesignEventWithEventId:(NSString *)eventId customFields:(NSDictionary *)customFields
{
    GARecord(_cmd, @[N(eventId), N(customFields)]);
}

+ (void)addDesignEventWithEventId:(NSString *)eventId customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields
{
    GARecord(_cmd, @[N(eventId), N(customFields), @(mergeFields)]);
}

+ (void)addDesignEventWithEventId:(NSString *)eventId value:(NSNumber *)value
{
    GARecord(_cmd, @[N(eventId), N(value)]);
}

+ (void)addDesignEventWithEventId:(NSString *)eventId value:(NSNumber *)value customFields:(NSDictionary *)customFields
{
    GARecord(_cmd, @[N(eventId), N(value), N(customFields)]);
}

+ (void)addDesignEventWithEventId:(NSString *)eventId value:(NSNumber *)value customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields
{
    GARecord(_cmd, @[N(eventId), N(value), N(customFields), @(mergeFields)]);
}

+ (void)addErrorEventWithSeverity:(GAErrorSeverity)severity message:(NSString *)message
{
    GARecord(_cmd, @[@(severity), N(message)]);
}

+ (void)addErrorEventWithSeverity:(GAErrorSeverity)severity message:(NSString *)message customFields:(NSDictionary *)customFields
{
    GARecord(_cmd, @[@(severity), N(message), N(customFields)]);
}

+ (void)addErrorEventWithSeverity:(GAErrorSeverity)severity message:(NSString *)message customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields
{
    GARecord(_cmd, @[@(severity), N(message), N(customFields), @(mergeFields)]);
}

+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement duration:(NSInteger)duration
{
    GARecord(_cmd, @[@(action), @(adType), N(adSdkName), N(adPlacement), @(duration)]);
}

+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement duration:(NSInteger)duration customFields:(NSDictionary *)customFields
{
    GARecord(_cmd, @[@(action), @(adType), N(adSdkName), N(adPlacement), @(duration), N(customFields)]);
}

+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement duration:(NSInteger)duration customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields
{
    GARecord(_cmd, @[@(action), @(adType), N(adSdkName), N(adPlacement), @(duration), N(customFields), @(mergeFields)]);
}

+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement noAdReason:(GAAdError)noAdReason
{
    GARecord(_cmd, @[@(action), @(adType), N(adSdkName), N(adPlacement), @(noAdReason)]);
}

+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement noAdReason:(GAAdError)noAdReason customFields:(NSDictionary *)customFields
{
    GARecord(_cmd, @[@(action), @(adType), N(adSdkName), N(adPlacement), @(noAdReason), N(customFields)]);
}

+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement noAdReason:(GAAdError)noAdReason customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields
{
    GARecord(_cmd, @[@(action), @(adType), N(adSdkName), N(adPlacement), @(noAdReason), N(customFields), @(mergeFields)]);
}

+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement
{
    GARecord(_cmd, @[@(action), @(adType), N(adSdkName), N(adPlacement)]);
}

+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement customFields:(NSDictionary *)customFields
{
    GARecord(_cmd, @[@(action), @(adType), N(adSdkName), N(adPlacement), N(customFields)]);
}

+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields
{
    GARecord(_cmd, @[@(action), @(adType), N(adSdkName), N(adPlacement), N(customFields), @(mergeFields)]);
}

+ (void)setEnabledInfoLog:(BOOL)flag
{
    GARecord(_cmd, @[@(flag)]);
}

+ (void)setEnabledVerboseLog:(BOOL)flag
{
    GARecord(_cmd, @[@(flag)]);
}

+ (void)setEnabledManualSessionHandling:(BOOL)flag
{
    GARecord(_cmd, @[@(flag)]);
}

+ (void)setEnabledEventSubmission:(BOOL)flag
{
    GARecord(_cmd, @[@(flag)]);
}

+ (void)setCustomDimension01:(NSString *)dimension
{
    GARecord(_cmd, @[N(dimension)]);
}

+ (void)setCustomDimension02:(NSString *)dimension
{
    GARecord(_cmd, @[N(dimension)]);
}

+ (void)setCustomDimension03:(NSString *)dimension
{
    GARecord(_cmd, @[N(dimension)]);
}

+ (void)setGlobalCustomEventFields:(NSDictionary *)customFields
{
    GARecord(_cmd, @[N(customFields)]);
}

+ (void)startSession
{
    GARecord(_cmd, @[]);
}

+ (void)endSession
{
    GARecord(_cmd, @[]);
}

+ (NSString *)getRemoteConfigsValueAsString:(NSString *)key
{
    GARecord(_cmd, @[N(key)]);
    return GAStringResult;
}

+ (NSString *)getRemoteConfigsValueAsString:(NSString *)key defaultValue:(NSString *)defaultValue
{
    GARecord(_cmd, @[N(key), N(defaultValue)]);
    return GAStringResult;
}

+ (BOOL)isRemoteConfigsReady
{
    GARecord(_cmd, @[]);
    return GABoolResult;
}

+ (NSString *)getRemoteConfigsContentAsString
{
    GARecord(_cmd, @[]);
    return GAStringResult;
}

+ (NSString *)getABTestingId
{
    GARecord(_cmd, @[]);
    return GAStringResult;
}

+ (NSString *)getABTestingVariantId
{
    GARecord(_cmd, @[]);
    return GAStringResult;
}

@end
