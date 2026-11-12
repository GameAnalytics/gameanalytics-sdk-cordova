#import "GameAnalyticsCordova.h"
#import <GameAnalytics/GameAnalyticsWrapper.h>

#define VERSION @"5.0.0"

@implementation GameAnalyticsCordova

- (void)configureAvailableCustomDimensions01:(CDVInvokedUrlCommand*)command
{
    NSMutableArray* array = [command.arguments objectAtIndex:0];
    NSMutableArray *dimensions = [[NSMutableArray alloc] init];
    if([array isKindOfClass:[NSArray class]])
    {
        for (id tempObject in array)
        {
            NSString* s = [tempObject isKindOfClass:[NSString class]] ? tempObject : @"";
            [dimensions addObject:s];
        }
    }
    [GameAnalytics configureAvailableCustomDimensions01:dimensions];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)configureAvailableCustomDimensions02:(CDVInvokedUrlCommand*)command
{
    NSMutableArray* array = [command.arguments objectAtIndex:0];
    NSMutableArray *dimensions = [[NSMutableArray alloc] init];
    if([array isKindOfClass:[NSArray class]])
    {
        for (id tempObject in array)
        {
            NSString* s = [tempObject isKindOfClass:[NSString class]] ? tempObject : @"";
            [dimensions addObject:s];
        }
    }
    [GameAnalytics configureAvailableCustomDimensions02:dimensions];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)configureAvailableCustomDimensions03:(CDVInvokedUrlCommand*)command
{
    NSMutableArray* array = [command.arguments objectAtIndex:0];
    NSMutableArray *dimensions = [[NSMutableArray alloc] init];
    if([array isKindOfClass:[NSArray class]])
    {
        for (id tempObject in array)
        {
            NSString* s = [tempObject isKindOfClass:[NSString class]] ? tempObject : @"";
            [dimensions addObject:s];
        }
    }
    [GameAnalytics configureAvailableCustomDimensions03:dimensions];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)configureAvailableResourceCurrencies:(CDVInvokedUrlCommand*)command
{
    NSMutableArray* array = [command.arguments objectAtIndex:0];
    NSMutableArray *currencies = [[NSMutableArray alloc] init];
    if([array isKindOfClass:[NSArray class]])
    {

        for (id tempObject in array)
        {
            NSString* s = [tempObject isKindOfClass:[NSString class]] ? tempObject : @"";
            [currencies addObject:s];
        }
    }
    [GameAnalytics configureAvailableResourceCurrencies:currencies];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)configureAvailableResourceItemTypes:(CDVInvokedUrlCommand*)command
{
    NSMutableArray* array = [command.arguments objectAtIndex:0];
    NSMutableArray *itemTypes = [[NSMutableArray alloc] init];
    if([array isKindOfClass:[NSArray class]])
    {

        for (id tempObject in array)
        {
            NSString* s = [tempObject isKindOfClass:[NSString class]] ? tempObject : @"";
            [itemTypes addObject:s];
        }
    }
    [GameAnalytics configureAvailableResourceItemTypes:itemTypes];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)configureBuild:(CDVInvokedUrlCommand*)command
{
    NSString* build = [command.arguments objectAtIndex:0];
    if(![build isKindOfClass:[NSString class]])
    {
        build = @"";
    }
    [GameAnalytics configureBuild:build];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)configureAutoDetectAppVersion:(CDVInvokedUrlCommand*)command
{
    BOOL flag = NO;
    if([command.arguments objectAtIndex:0] && [[command.arguments objectAtIndex:0] isKindOfClass:[NSNumber class]] && ([[command.arguments objectAtIndex:0] isEqual:[NSNumber numberWithBool:YES]] || [[command.arguments objectAtIndex:0] isEqual:[NSNumber numberWithBool:NO]]))
    {
        flag = [[command.arguments objectAtIndex:0] boolValue];
    }
    [GameAnalytics configureAutoDetectAppVersion:flag];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)configureUserId:(CDVInvokedUrlCommand*)command
{
    NSString* uId = [command.arguments objectAtIndex:0];
    if(![uId isKindOfClass:[NSString class]])
    {
        uId = @"";
    }
    [GameAnalytics configureUserId:uId];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)initialize:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary* args = [command.arguments objectAtIndex:0];

    NSString* gameKey = @"";
    NSString* secretKey = @"";
    NSString* sdkVersion = [NSString stringWithFormat:@"cordova %@", VERSION];

    if([args isKindOfClass:[NSDictionary class]])
    {
        gameKey = args[@"gameKey"] && [args[@"gameKey"] isKindOfClass:[NSString class]] ? args[@"gameKey"] : @"";
        secretKey = args[@"secretKey"] && [args[@"secretKey"] isKindOfClass:[NSString class]] ? args[@"secretKey"] : @"";
        sdkVersion = args[@"sdkVersion"] && [args[@"sdkVersion"] isKindOfClass:[NSString class]] ? args[@"sdkVersion"] : [NSString stringWithFormat:@"cordova %@", VERSION];
    }

    [GameAnalytics configureSdkVersion:sdkVersion];
    [GameAnalytics initializeWithGameKey:gameKey gameSecret:secretKey];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)addBusinessEvent:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary* args = [command.arguments objectAtIndex:0];

    NSString* currency = @"";
    NSInteger amount = 0;
    NSString* itemType = @"";
    NSString* itemId = @"";
    NSString* cartType = @"";
    NSString* receipt = @"";
    BOOL autoFetchReceipt = NO;
    NSString* fieldsString = nil;
    BOOL mergeFields = NO;

    if([args isKindOfClass:[NSDictionary class]])
    {
        currency = args[@"currency"] && [args[@"currency"] isKindOfClass:[NSString class]] ? args[@"currency"] : @"";
        amount = args[@"amount"] && [args[@"amount"] isKindOfClass:[NSNumber class]] ? [[args valueForKey:@"amount"] intValue] : 0;
        itemType = args[@"itemType"] && [args[@"itemType"] isKindOfClass:[NSString class]] ? args[@"itemType"] : @"";
        itemId = args[@"itemId"] && [args[@"itemId"] isKindOfClass:[NSString class]] ? args[@"itemId"] : @"";
        cartType = args[@"cartType"] && [args[@"cartType"] isKindOfClass:[NSString class]] ? args[@"cartType"] : @"";
        receipt = args[@"receipt"] && [args[@"receipt"] isKindOfClass:[NSString class]] ? args[@"receipt"] : @"";
        autoFetchReceipt = args[@"autoFetchReceipt"] && [args[@"autoFetchReceipt"] isKindOfClass:[NSNumber class]] && [args[@"autoFetchReceipt"] isEqual:[NSNumber numberWithBool:YES]] ? [[args valueForKey:@"autoFetchReceipt"] boolValue] : NO;
        fieldsString = args[@"customFields"] && [args[@"customFields"] isKindOfClass:[NSString class]] ? args[@"customFields"] : @"";
        mergeFields = args[@"mergeFields"] && [args[@"mergeFields"] isKindOfClass:[NSNumber class]] && [args[@"mergeFields"] isEqual:[NSNumber numberWithBool:YES]] ? [[args valueForKey:@"mergeFields"] boolValue] : NO;
    }

    NSDictionary *fields_dict = nil;
    if (fieldsString) {
        id fields = [NSJSONSerialization JSONObjectWithData:[fieldsString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        fields_dict = [fields isKindOfClass:[NSDictionary class]] ? fields : nil;
    }

    if(autoFetchReceipt)
    {
        [GameAnalytics addBusinessEventWithCurrency:currency amount:amount itemType:itemType itemId:itemId cartType:cartType autoFetchReceipt:autoFetchReceipt customFields:fields_dict mergeFields:mergeFields];
    }
    else
    {
        [GameAnalytics addBusinessEventWithCurrency:currency amount:amount itemType:itemType itemId:itemId cartType:cartType receipt:receipt customFields:fields_dict mergeFields:mergeFields];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)addResourceEvent:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary* args = [command.arguments objectAtIndex:0];

    int flowType = 0;
    NSString* currency = @"";
    double amount = 0;
    NSString* itemType = @"";
    NSString* itemId = @"";
    NSString* fieldsString = nil;
    BOOL mergeFields = NO;

    if([args isKindOfClass:[NSDictionary class]])
    {
        flowType = args[@"flowType"] && ([args[@"flowType"] isKindOfClass:[NSNumber class]] || [args[@"flowType"] isKindOfClass:[NSString class]]) ? [[args valueForKey:@"flowType"] intValue] : 0;
        currency = args[@"currency"] && [args[@"currency"] isKindOfClass:[NSString class]] ? args[@"currency"] : @"";
        amount = args[@"amount"] && [args[@"amount"] isKindOfClass:[NSNumber class]] ? [[args valueForKey:@"amount"] doubleValue] : 0;
        itemType = args[@"itemType"] && [args[@"itemType"] isKindOfClass:[NSString class]] ? args[@"itemType"] : @"";
        itemId = args[@"itemId"] && [args[@"itemId"] isKindOfClass:[NSString class]] ? args[@"itemId"] : @"";
        fieldsString = args[@"customFields"] && [args[@"customFields"] isKindOfClass:[NSString class]] ? args[@"customFields"] : @"";
        mergeFields = args[@"mergeFields"] && [args[@"mergeFields"] isKindOfClass:[NSNumber class]] && [args[@"mergeFields"] isEqual:[NSNumber numberWithBool:YES]] ? [[args valueForKey:@"mergeFields"] boolValue] : NO;
    }

    NSDictionary *fields_dict = nil;
    if (fieldsString) {
        id fields = [NSJSONSerialization JSONObjectWithData:[fieldsString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        fields_dict = [fields isKindOfClass:[NSDictionary class]] ? fields : nil;
    }

    [GameAnalytics addResourceEventWithFlowType:(GAResourceFlowType)flowType currency:currency amount:@(amount) itemType:itemType itemId:itemId customFields:fields_dict mergeFields:mergeFields];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)addProgressionEvent:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary* args = [command.arguments objectAtIndex:0];

    int progressionStatus = 0;
    NSString* progression01 = @"";
    NSString* progression02 = @"";
    NSString* progression03 = @"";
    int score = 0;
    BOOL sendScore = NO;
    NSString* fieldsString = nil;
    BOOL mergeFields = NO;

    if([args isKindOfClass:[NSDictionary class]])
    {
        progressionStatus = args[@"progressionStatus"] && [args[@"progressionStatus"] isKindOfClass:[NSNumber class]] ? [[args valueForKey:@"progressionStatus"] intValue] : 0;
        progression01 = args[@"progression01"] && [args[@"progression01"] isKindOfClass:[NSString class]] ? args[@"progression01"] : @"";
        progression02 = args[@"progression02"] && [args[@"progression02"] isKindOfClass:[NSString class]] ? args[@"progression02"] : @"";
        progression03 = args[@"progression03"] && [args[@"progression03"] isKindOfClass:[NSString class]] ? args[@"progression03"] : @"";
        score = args[@"score"] && [args[@"score"] isKindOfClass:[NSNumber class]] ? [[args valueForKey:@"score"] intValue] : 0;
        sendScore = args[@"score"] && [args[@"score"] isKindOfClass:[NSNumber class]] ? YES : NO;
        fieldsString = args[@"customFields"] && [args[@"customFields"] isKindOfClass:[NSString class]] ? args[@"customFields"] : @"";
        mergeFields = args[@"mergeFields"] && [args[@"mergeFields"] isKindOfClass:[NSNumber class]] && [args[@"mergeFields"] isEqual:[NSNumber numberWithBool:YES]] ? [[args valueForKey:@"mergeFields"] boolValue] : NO;
    }

    NSDictionary *fields_dict = nil;
    if (fieldsString) {
        id fields = [NSJSONSerialization JSONObjectWithData:[fieldsString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        fields_dict = [fields isKindOfClass:[NSDictionary class]] ? fields : nil;
    }

    if(sendScore)
    {
        [GameAnalytics addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:progression01 progression02:progression02 progression03:progression03 score:score customFields:fields_dict mergeFields:mergeFields];
    }
    else
    {
        [GameAnalytics addProgressionEventWithProgressionStatus:(GAProgressionStatus)progressionStatus progression01:progression01 progression02:progression02 progression03:progression03 customFields:fields_dict mergeFields:mergeFields];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)addDesignEvent:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary* args = [command.arguments objectAtIndex:0];

    NSString* eventId = @"";
    double value = 0;
    BOOL sendValue = NO;
    NSString* fieldsString = nil;
    BOOL mergeFields = NO;

    if([args isKindOfClass:[NSDictionary class]])
    {
        eventId = args[@"eventId"] && [args[@"eventId"] isKindOfClass:[NSString class]] ? args[@"eventId"] : @"";
        value = args[@"value"] && [args[@"value"] isKindOfClass:[NSNumber class]] ? [[args valueForKey:@"value"] doubleValue] : 0;
        sendValue = args[@"value"] && [args[@"value"] isKindOfClass:[NSNumber class]] ? YES : NO;
        fieldsString = args[@"customFields"] && [args[@"customFields"] isKindOfClass:[NSString class]] ? args[@"customFields"] : @"";
        mergeFields = args[@"mergeFields"] && [args[@"mergeFields"] isKindOfClass:[NSNumber class]] && [args[@"mergeFields"] isEqual:[NSNumber numberWithBool:YES]] ? [[args valueForKey:@"mergeFields"] boolValue] : NO;
    }

    NSDictionary *fields_dict = nil;
    if (fieldsString) {
        id fields = [NSJSONSerialization JSONObjectWithData:[fieldsString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        fields_dict = [fields isKindOfClass:[NSDictionary class]] ? fields : nil;
    }

    if(sendValue)
    {
        [GameAnalytics addDesignEventWithEventId:eventId value:@(value) customFields:fields_dict mergeFields:mergeFields];
    }
    else
    {
        [GameAnalytics addDesignEventWithEventId:eventId customFields:fields_dict mergeFields:mergeFields];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)addErrorEvent:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary* args = [command.arguments objectAtIndex:0];

    int severity = 0;
    NSString* message = @"";
    NSString* fieldsString = nil;
    BOOL mergeFields = NO;

    if([args isKindOfClass:[NSDictionary class]])
    {
        severity = args[@"severity"] && [args[@"severity"] isKindOfClass:[NSNumber class]] ? [[args valueForKey:@"severity"] intValue] : 0;
        message = args[@"message"] && [args[@"message"] isKindOfClass:[NSString class]] ? args[@"message"] : @"";
        fieldsString = args[@"customFields"] && [args[@"customFields"] isKindOfClass:[NSString class]] ? args[@"customFields"] : @"";
        mergeFields = args[@"mergeFields"] && [args[@"mergeFields"] isKindOfClass:[NSNumber class]] && [args[@"mergeFields"] isEqual:[NSNumber numberWithBool:YES]] ? [[args valueForKey:@"mergeFields"] boolValue] : NO;
    }

    NSDictionary *fields_dict = nil;
    if (fieldsString) {
        id fields = [NSJSONSerialization JSONObjectWithData:[fieldsString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        fields_dict = [fields isKindOfClass:[NSDictionary class]] ? fields : nil;
    }

    [GameAnalytics addErrorEventWithSeverity:(GAErrorSeverity)severity message:message customFields:fields_dict mergeFields:mergeFields];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)addAdEvent:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary* args = [command.arguments objectAtIndex:0];

    int adAction = 0;
    int adType = 0;
    NSString* adSdkName = @"";
    NSString* adPlacement = @"";
    NSInteger duration = 0;
    BOOL sendDuration = NO;
    int noAdReason = 0;
    NSString* fieldsString = nil;
    BOOL mergeFields = NO;

    if([args isKindOfClass:[NSDictionary class]])
    {
        adAction = args[@"adAction"] && [args[@"adAction"] isKindOfClass:[NSNumber class]] ? [[args valueForKey:@"adAction"] intValue] : 0;
        adType = args[@"adType"] && [args[@"adType"] isKindOfClass:[NSNumber class]] ? [[args valueForKey:@"adType"] intValue] : 0;
        adSdkName = args[@"adSdkName"] && [args[@"adSdkName"] isKindOfClass:[NSString class]] ? args[@"adSdkName"] : @"";
        adPlacement = args[@"adPlacement"] && [args[@"adPlacement"] isKindOfClass:[NSString class]] ? args[@"adPlacement"] : @"";
        duration = args[@"duration"] && [args[@"duration"] isKindOfClass:[NSNumber class]] ? [[args valueForKey:@"duration"] intValue] : 0;
        sendDuration = args[@"duration"] && [args[@"duration"] isKindOfClass:[NSNumber class]] ? YES : NO;
        noAdReason = args[@"noAdReason"] && [args[@"noAdReason"] isKindOfClass:[NSNumber class]] ? [[args valueForKey:@"noAdReason"] intValue] : 0;
        fieldsString = args[@"customFields"] && [args[@"customFields"] isKindOfClass:[NSString class]] ? args[@"customFields"] : @"";
        mergeFields = args[@"mergeFields"] && [args[@"mergeFields"] isKindOfClass:[NSNumber class]] && [args[@"mergeFields"] isEqual:[NSNumber numberWithBool:YES]] ? [[args valueForKey:@"mergeFields"] boolValue] : NO;
    }

    NSDictionary *fields_dict = nil;
    if (fieldsString) {
        id fields = [NSJSONSerialization JSONObjectWithData:[fieldsString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        fields_dict = [fields isKindOfClass:[NSDictionary class]] ? fields : nil;
    }

    if(sendDuration)
    {
        [GameAnalytics addAdEventWithAction:(GAAdAction)adAction adType:(GAAdType)adType adSdkName:adSdkName adPlacement:adPlacement duration:duration customFields:fields_dict mergeFields:mergeFields];
    }
    else
    {
        [GameAnalytics addAdEventWithAction:(GAAdAction)adAction adType:(GAAdType)adType adSdkName:adSdkName adPlacement:adPlacement noAdReason:(GAAdError)noAdReason customFields:fields_dict mergeFields:mergeFields];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setEnabledInfoLog:(CDVInvokedUrlCommand*)command
{
    BOOL flag = NO;
    if([command.arguments objectAtIndex:0] && [[command.arguments objectAtIndex:0] isKindOfClass:[NSNumber class]] && ([[command.arguments objectAtIndex:0] isEqual:[NSNumber numberWithBool:YES]] || [[command.arguments objectAtIndex:0] isEqual:[NSNumber numberWithBool:NO]]))
    {
        flag = [[command.arguments objectAtIndex:0] boolValue];
    }
    [GameAnalytics setEnabledInfoLog:flag];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setEnabledVerboseLog:(CDVInvokedUrlCommand*)command
{
    BOOL flag = NO;
    if([command.arguments objectAtIndex:0] && [[command.arguments objectAtIndex:0] isKindOfClass:[NSNumber class]] && ([[command.arguments objectAtIndex:0] isEqual:[NSNumber numberWithBool:YES]] || [[command.arguments objectAtIndex:0] isEqual:[NSNumber numberWithBool:NO]]))
    {
        flag = [[command.arguments objectAtIndex:0] boolValue];
    }
    [GameAnalytics setEnabledVerboseLog:flag];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setEnabledManualSessionHandling:(CDVInvokedUrlCommand*)command
{
    BOOL flag = NO;
    if([command.arguments objectAtIndex:0] && [[command.arguments objectAtIndex:0] isKindOfClass:[NSNumber class]] && ([[command.arguments objectAtIndex:0] isEqual:[NSNumber numberWithBool:YES]] || [[command.arguments objectAtIndex:0] isEqual:[NSNumber numberWithBool:NO]]))
    {
        flag = [[command.arguments objectAtIndex:0] boolValue];
    }
    [GameAnalytics setEnabledManualSessionHandling:flag];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setEnabledEventSubmission:(CDVInvokedUrlCommand*)command
{
    BOOL flag = YES;
    if([command.arguments objectAtIndex:0] && [[command.arguments objectAtIndex:0] isKindOfClass:[NSNumber class]] && ([[command.arguments objectAtIndex:0] isEqual:[NSNumber numberWithBool:YES]] || [[command.arguments objectAtIndex:0] isEqual:[NSNumber numberWithBool:NO]]))
    {
        flag = [[command.arguments objectAtIndex:0] boolValue];
    }
    [GameAnalytics setEnabledEventSubmission:flag];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setCustomDimension01:(CDVInvokedUrlCommand*)command
{
    NSString* dimension = [command.arguments objectAtIndex:0];
    if(![dimension isKindOfClass:[NSString class]])
    {
        dimension = @"";
    }
    [GameAnalytics setCustomDimension01:dimension];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setCustomDimension02:(CDVInvokedUrlCommand*)command
{
    NSString* dimension = [command.arguments objectAtIndex:0];
    if(![dimension isKindOfClass:[NSString class]])
    {
        dimension = @"";
    }
    [GameAnalytics setCustomDimension02:dimension];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setCustomDimension03:(CDVInvokedUrlCommand*)command
{
    NSString* dimension = [command.arguments objectAtIndex:0];
    if(![dimension isKindOfClass:[NSString class]])
    {
        dimension = @"";
    }
    [GameAnalytics setCustomDimension03:dimension];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)setGlobalCustomEventFields:(CDVInvokedUrlCommand*)command
{
    NSString* fieldsString = [command.arguments objectAtIndex:0];
    if(![fieldsString isKindOfClass:[NSString class]])
    {
        fieldsString = @"";
    }

    NSDictionary *fields_dict = nil;
    if (fieldsString) {
        id fields = [NSJSONSerialization JSONObjectWithData:[fieldsString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        fields_dict = [fields isKindOfClass:[NSDictionary class]] ? fields : nil;
    }

    [GameAnalytics setGlobalCustomEventFields:fields_dict];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)startSession:(CDVInvokedUrlCommand*)command
{
    [GameAnalytics startSession];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)endSession:(CDVInvokedUrlCommand*)command
{
    [GameAnalytics endSession];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getRemoteConfigsValueAsString:(CDVInvokedUrlCommand*)command
{
    NSMutableDictionary* args = [command.arguments objectAtIndex:0];
    NSString* key = @"";
    NSString* defaultValue = nil;

    if([args isKindOfClass:[NSDictionary class]])
    {
        key = args[@"key"] && [args[@"key"] isKindOfClass:[NSString class]] ? args[@"key"] : @"";
        defaultValue = args[@"defaultValue"] && [args[@"defaultValue"] isKindOfClass:[NSString class]] ? args[@"defaultValue"] : @"";
    }

    NSString* result = nil;
    if(defaultValue)
    {
        result = [GameAnalytics getRemoteConfigsValueAsString:key defaultValue:defaultValue];
    }
    else
    {
        result = [GameAnalytics getRemoteConfigsValueAsString:key];
    }
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)isRemoteConfigsReady:(CDVInvokedUrlCommand*)command
{
    BOOL result = [GameAnalytics isRemoteConfigsReady];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getRemoteConfigsContentAsString:(CDVInvokedUrlCommand*)command
{
    NSString* result = [GameAnalytics getRemoteConfigsContentAsString];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getABTestingId:(CDVInvokedUrlCommand*)command
{
    NSString* result = [GameAnalytics getABTestingId];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)getABTestingVariantId:(CDVInvokedUrlCommand*)command
{
    NSString* result = [GameAnalytics getABTestingVariantId];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
