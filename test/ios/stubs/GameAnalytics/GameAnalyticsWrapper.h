// Recording test stub of the GameAnalytics iOS SDK 5.0.2 class methods the bridge calls.
// The declarations are copied from the SDK's public headers; the bridge is also
// compiled against the real headers by syntax-check.sh, which catches any drift.
#import <Foundation/Foundation.h>

typedef enum GAResourceFlowType : NSInteger { GAResourceFlowTypeSource = 1, GAResourceFlowTypeSink = 2 } GAResourceFlowType;
typedef enum GAProgressionStatus : NSInteger { GAProgressionStatusStart = 1, GAProgressionStatusComplete = 2, GAProgressionStatusFail = 3 } GAProgressionStatus;
typedef enum GAErrorSeverity : NSInteger { GAErrorSeverityDebug = 1, GAErrorSeverityInfo = 2, GAErrorSeverityWarning = 3, GAErrorSeverityError = 4, GAErrorSeverityCritical = 5 } GAErrorSeverity;
typedef enum GAAdAction : NSInteger { GAAdActionClicked = 1, GAAdActionShow = 2, GAAdActionFailedShow = 3, GAAdActionRewardReceived = 4, GAAdActionRequest = 5, GAAdActionLoaded = 6 } GAAdAction;
typedef enum GAAdType : NSInteger { GAAdTypeVideo = 1, GAAdTypeRewardedVideo = 2, GAAdTypePlayable = 3, GAAdTypeInterstitial = 4, GAAdTypeOfferWall = 5, GAAdTypeBanner = 6, GAAdTypeAppOpen = 7 } GAAdType;
typedef enum GAAdError : NSInteger { GAAdErrorUnknown = 1, GAAdErrorOffline = 2, GAAdErrorNoFill = 3, GAAdErrorInternalError = 4, GAAdErrorInvalidRequest = 5, GAAdErrorUnableToPrecache = 6 } GAAdError;

/// Every call is recorded as @[selectorName, arg0, arg1, ...] with nil as NSNull.
extern NSMutableArray *GACalls;
extern NSString *GAStringResult;
extern BOOL GABoolResult;

@interface GameAnalytics : NSObject
+ (void)configureSdkVersion:(NSString *)wrapperSdkVersion;
+ (void)configureAvailableCustomDimensions01:(NSArray *)customDimensions;
+ (void)configureAvailableCustomDimensions02:(NSArray *)customDimensions;
+ (void)configureAvailableCustomDimensions03:(NSArray *)customDimensions;
+ (void)configureAvailableResourceCurrencies:(NSArray *)resourceCurrencies;
+ (void)configureAvailableResourceItemTypes:(NSArray *)resourceItemTypes;
+ (void)configureBuild:(NSString *)build;
+ (void)configureUserId:(NSString *)userId;
+ (void)configureAutoDetectAppVersion:(BOOL)flag;
+ (void)initializeWithGameKey:(NSString *)gameKey gameSecret:(NSString *)gameSecret;

+ (void)addBusinessEventWithCurrency:(NSString *)currency amount:(NSInteger)amount itemType:(NSString *)itemType itemId:(NSString *)itemId cartType:(NSString *)cartType receipt:(NSString *)receipt;
+ (void)addBusinessEventWithCurrency:(NSString *)currency amount:(NSInteger)amount itemType:(NSString *)itemType itemId:(NSString *)itemId cartType:(NSString *)cartType receipt:(NSString *)receipt customFields:(NSDictionary *)customFields;
+ (void)addBusinessEventWithCurrency:(NSString *)currency amount:(NSInteger)amount itemType:(NSString *)itemType itemId:(NSString *)itemId cartType:(NSString *)cartType receipt:(NSString *)receipt customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields;
+ (void)addBusinessEventWithCurrency:(NSString *)currency amount:(NSInteger)amount itemType:(NSString *)itemType itemId:(NSString *)itemId cartType:(NSString *)cartType autoFetchReceipt:(BOOL)autoFetchReceipt;
+ (void)addBusinessEventWithCurrency:(NSString *)currency amount:(NSInteger)amount itemType:(NSString *)itemType itemId:(NSString *)itemId cartType:(NSString *)cartType autoFetchReceipt:(BOOL)autoFetchReceipt customFields:(NSDictionary *)customFields;
+ (void)addBusinessEventWithCurrency:(NSString *)currency amount:(NSInteger)amount itemType:(NSString *)itemType itemId:(NSString *)itemId cartType:(NSString *)cartType autoFetchReceipt:(BOOL)autoFetchReceipt customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields;

+ (void)addResourceEventWithFlowType:(GAResourceFlowType)flowType currency:(NSString *)currency amount:(NSNumber *)amount itemType:(NSString *)itemType itemId:(NSString *)itemId;
+ (void)addResourceEventWithFlowType:(GAResourceFlowType)flowType currency:(NSString *)currency amount:(NSNumber *)amount itemType:(NSString *)itemType itemId:(NSString *)itemId customFields:(NSDictionary *)customFields;
+ (void)addResourceEventWithFlowType:(GAResourceFlowType)flowType currency:(NSString *)currency amount:(NSNumber *)amount itemType:(NSString *)itemType itemId:(NSString *)itemId customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields;

+ (void)addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:(NSString *)progression01 progression02:(NSString *)progression02 progression03:(NSString *)progression03;
+ (void)addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:(NSString *)progression01 progression02:(NSString *)progression02 progression03:(NSString *)progression03 customFields:(NSDictionary *)customFields;
+ (void)addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:(NSString *)progression01 progression02:(NSString *)progression02 progression03:(NSString *)progression03 customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields;
+ (void)addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:(NSString *)progression01 progression02:(NSString *)progression02 progression03:(NSString *)progression03 score:(NSInteger)score;
+ (void)addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:(NSString *)progression01 progression02:(NSString *)progression02 progression03:(NSString *)progression03 score:(NSInteger)score customFields:(NSDictionary *)customFields;
+ (void)addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:(NSString *)progression01 progression02:(NSString *)progression02 progression03:(NSString *)progression03 score:(NSInteger)score customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields;

+ (void)addDesignEventWithEventId:(NSString *)eventId;
+ (void)addDesignEventWithEventId:(NSString *)eventId customFields:(NSDictionary *)customFields;
+ (void)addDesignEventWithEventId:(NSString *)eventId customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields;
+ (void)addDesignEventWithEventId:(NSString *)eventId value:(NSNumber *)value;
+ (void)addDesignEventWithEventId:(NSString *)eventId value:(NSNumber *)value customFields:(NSDictionary *)customFields;
+ (void)addDesignEventWithEventId:(NSString *)eventId value:(NSNumber *)value customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields;

+ (void)addErrorEventWithSeverity:(GAErrorSeverity)severity message:(NSString *)message;
+ (void)addErrorEventWithSeverity:(GAErrorSeverity)severity message:(NSString *)message customFields:(NSDictionary *)customFields;
+ (void)addErrorEventWithSeverity:(GAErrorSeverity)severity message:(NSString *)message customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields;

+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement duration:(NSInteger)duration;
+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement duration:(NSInteger)duration customFields:(NSDictionary *)customFields;
+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement duration:(NSInteger)duration customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields;
+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement noAdReason:(GAAdError)noAdReason;
+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement noAdReason:(GAAdError)noAdReason customFields:(NSDictionary *)customFields;
+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement noAdReason:(GAAdError)noAdReason customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields;
+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement;
+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement customFields:(NSDictionary *)customFields;
+ (void)addAdEventWithAction:(GAAdAction)action adType:(GAAdType)adType adSdkName:(NSString *)adSdkName adPlacement:(NSString *)adPlacement customFields:(NSDictionary *)customFields mergeFields:(BOOL)mergeFields;

+ (void)setEnabledInfoLog:(BOOL)flag;
+ (void)setEnabledVerboseLog:(BOOL)flag;
+ (void)setEnabledManualSessionHandling:(BOOL)flag;
+ (void)setEnabledEventSubmission:(BOOL)flag;
+ (void)setCustomDimension01:(NSString *)dimension;
+ (void)setCustomDimension02:(NSString *)dimension;
+ (void)setCustomDimension03:(NSString *)dimension;
+ (void)setGlobalCustomEventFields:(NSDictionary *)customFields;
+ (void)startSession;
+ (void)endSession;
+ (NSString *)getRemoteConfigsValueAsString:(NSString *)key;
+ (NSString *)getRemoteConfigsValueAsString:(NSString *)key defaultValue:(NSString *)defaultValue;
+ (BOOL)isRemoteConfigsReady;
+ (NSString *)getRemoteConfigsContentAsString;
+ (NSString *)getABTestingId;
+ (NSString *)getABTestingVariantId;
@end
