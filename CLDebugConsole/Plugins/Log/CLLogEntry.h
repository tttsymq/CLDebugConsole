// CLDebugConsole/Plugins/Log/CLLogEntry.h

#import <Foundation/Foundation.h>
#import "CLLogLevel.h"

@interface CLLogEntry : NSObject <NSCoding>

@property (nonatomic, assign) CLLogLevel level;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *functionName;
@property (nonatomic, assign) NSUInteger lineNumber;
@property (nonatomic, strong) NSDate *timestamp;

+ (instancetype)entryWithLevel:(CLLogLevel)level
                      function:(const char *)function
                          line:(NSUInteger)line
                       message:(NSString *)message;

- (NSString *)formattedString;
- (NSString *)simpleString;
- (NSDictionary *)toDictionary;

@end
