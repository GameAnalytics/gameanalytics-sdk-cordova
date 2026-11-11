#import <Cordova/Cordova.h>

@implementation CDVPluginResult {
    NSNumber *_status;
    id _message;
}
- (instancetype)initWithStatus:(CDVCommandStatus)s message:(id)m {
    if ((self = [super init])) { _status = @(s); _message = m; }
    return self;
}
- (NSNumber *)status { return _status; }
- (id)message { return _message; }
+ (CDVPluginResult *)resultWithStatus:(CDVCommandStatus)s { return [[self alloc] initWithStatus:s message:nil]; }
+ (CDVPluginResult *)resultWithStatus:(CDVCommandStatus)s messageAsString:(NSString *)m { return [[self alloc] initWithStatus:s message:m]; }
+ (CDVPluginResult *)resultWithStatus:(CDVCommandStatus)s messageAsBool:(BOOL)m { return [[self alloc] initWithStatus:s message:@(m)]; }
+ (CDVPluginResult *)resultWithStatus:(CDVCommandStatus)s messageAsInt:(int)m { return [[self alloc] initWithStatus:s message:@(m)]; }
@end

@implementation CDVInvokedUrlCommand
- (instancetype)initWithArguments:(NSArray *)arguments callbackId:(NSString *)callbackId className:(NSString *)className methodName:(NSString *)methodName {
    if ((self = [super init])) { _arguments = arguments; _callbackId = callbackId; _className = className; _methodName = methodName; }
    return self;
}
@end

@implementation CDVPlugin
@end
