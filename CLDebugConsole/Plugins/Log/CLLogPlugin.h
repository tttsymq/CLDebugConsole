// CLDebugConsole/Plugins/Log/CLLogPlugin.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CLDebugPluginProtocol.h"
#import "CLLogLevel.h"
#import "CLLogEntry.h"
#import "CLLogFilter.h"

@interface CLLogPlugin : NSObject <CLDebugPluginProtocol>

+ (instancetype)sharedPlugin;

- (void)logWithLevel:(CLLogLevel)level
            function:(const char *)function
                line:(NSUInteger)line
              format:(NSString *)format, ... NS_FORMAT_FUNCTION(4,5);

- (NSArray<CLLogEntry *> *)allLogs;
- (NSArray<CLLogEntry *> *)logsWithKeyword:(NSString *)keyword;
- (NSArray<CLLogEntry *> *)logsWithLevel:(CLLogLevel)level;
- (NSArray<CLLogEntry *> *)logsWithFilter:(CLLogFilter *)filter;

- (void)exportAsText:(void(^)(NSString *filePath))completion;
- (void)exportAsJSON:(void(^)(NSString *filePath))completion;

- (void)clearLogs;

@end
