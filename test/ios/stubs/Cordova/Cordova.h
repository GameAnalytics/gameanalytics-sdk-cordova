// Test stub of the Cordova iOS classes the bridge uses. The bridge is also
// compiled against the real cordova-ios headers by syntax-check.sh.
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CDVCommandStatus) {
    CDVCommandStatus_NO_RESULT = 0,
    CDVCommandStatus_OK,
    CDVCommandStatus_CLASS_NOT_FOUND_EXCEPTION,
    CDVCommandStatus_ILLEGAL_ACCESS_EXCEPTION,
    CDVCommandStatus_INSTANTIATION_EXCEPTION,
    CDVCommandStatus_MALFORMED_URL_EXCEPTION,
    CDVCommandStatus_IO_EXCEPTION,
    CDVCommandStatus_INVALID_ACTION,
    CDVCommandStatus_JSON_EXCEPTION,
    CDVCommandStatus_ERROR
};

@interface CDVPluginResult : NSObject
@property (nonatomic, strong, readonly) NSNumber *status;
@property (nonatomic, strong, readonly) id message;
+ (CDVPluginResult *)resultWithStatus:(CDVCommandStatus)statusOrdinal;
+ (CDVPluginResult *)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsString:(NSString *)theMessage;
+ (CDVPluginResult *)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsBool:(BOOL)theMessage;
+ (CDVPluginResult *)resultWithStatus:(CDVCommandStatus)statusOrdinal messageAsInt:(int)theMessage;
@end

@interface CDVInvokedUrlCommand : NSObject
@property (nonatomic, readonly, strong) NSArray *arguments;
@property (nonatomic, readonly, strong) NSString *callbackId;
@property (nonatomic, readonly, strong) NSString *className;
@property (nonatomic, readonly, strong) NSString *methodName;
- (instancetype)initWithArguments:(NSArray *)arguments
                       callbackId:(NSString *)callbackId
                        className:(NSString *)className
                       methodName:(NSString *)methodName;
@end

@protocol CDVCommandDelegate <NSObject>
- (void)sendPluginResult:(CDVPluginResult *)result callbackId:(NSString *)callbackId;
@end

@interface CDVPlugin : NSObject
@property (nonatomic, weak) id<CDVCommandDelegate> commandDelegate;
@end
