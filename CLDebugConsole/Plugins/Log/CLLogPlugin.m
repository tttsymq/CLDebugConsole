// CLDebugConsole/Plugins/Log/CLLogPlugin.m

#import "CLLogPlugin.h"
#import "CLLogStorage.h"
#import "CLLogPanelView.h"

@interface CLLogPlugin ()

@property (nonatomic, strong) CLLogStorage *storage;
@property (nonatomic, strong) CLLogPanelView *logPanel;

@end

@implementation CLLogPlugin

+ (instancetype)sharedPlugin {
    static CLLogPlugin *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CLLogPlugin alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _storage = [CLLogStorage sharedStorage];
        _logPanel = [[CLLogPanelView alloc] initWithFrame:CGRectZero];
    }
    return self;
}

#pragma mark - CLDebugPluginProtocol

- (NSString *)pluginName {
    return @"Log";
}

- (UIImage *)pluginIcon {
    NSBundle *bundle = [self resourceBundle];
    return [UIImage imageNamed:@"CLConsole_icon" inBundle:bundle compatibleWithTraitCollection:nil];
}

- (UIView *)pluginView {
    return self.logPanel;
}

- (void)pluginDidLoad {
    // Nothing to do
}

- (void)pluginWillUnload {
    // Nothing to do
}

- (void)pluginDidActivate {
    [self.logPanel refreshLogs];
}

- (void)pluginDidDeactivate {
    // Nothing to do
}

#pragma mark - Logging

- (void)logWithLevel:(CLLogLevel)level
            function:(const char *)function
                line:(NSUInteger)line
              format:(NSString *)format, ... {
    va_list args;
    if (format) {
        va_start(args, format);
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        va_end(args);

        CLLogEntry *entry = [CLLogEntry entryWithLevel:level
                                              function:function
                                                  line:line
                                               message:message];
        [self.storage addLog:entry];
    }
}

#pragma mark - Query

- (NSArray<CLLogEntry *> *)allLogs {
    return [self.storage allLogs];
}

- (NSArray<CLLogEntry *> *)logsWithKeyword:(NSString *)keyword {
    CLLogFilter *filter = [CLLogFilter defaultFilter];
    filter.keyword = keyword;
    return [self.storage logsWithFilter:filter];
}

- (NSArray<CLLogEntry *> *)logsWithLevel:(CLLogLevel)level {
    CLLogFilter *filter = [CLLogFilter defaultFilter];
    filter.level = level;
    filter.levelFilterEnabled = YES;
    return [self.storage logsWithFilter:filter];
}

- (NSArray<CLLogEntry *> *)logsWithFilter:(CLLogFilter *)filter {
    return [self.storage logsWithFilter:filter];
}

#pragma mark - Export

- (void)exportAsText:(void(^)(NSString *filePath))completion {
    [self.storage exportAsText:completion];
}

- (void)exportAsJSON:(void(^)(NSString *filePath))completion {
    [self.storage exportAsJSON:completion];
}

- (void)clearLogs {
    [self.storage clearAll];
    [self.logPanel refreshLogs];
}

#pragma mark - Resources

- (NSBundle *)resourceBundle {
    NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
    NSString *bundlePath = [mainBundle pathForResource:@"CLDebugConsole" ofType:@"bundle"];
    if (bundlePath) {
        return [NSBundle bundleWithPath:bundlePath];
    }
    // Fallback: look in documents for standalone resources
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:@"CLDebugConsole" ofType:@"bundle"];
    if (resourcePath) {
        return [NSBundle bundleWithPath:resourcePath];
    }
    return mainBundle;
}

@end
