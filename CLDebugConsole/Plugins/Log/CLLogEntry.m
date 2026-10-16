// CLDebugConsole/Plugins/Log/CLLogEntry.m

#import "CLLogEntry.h"

@implementation CLLogEntry

+ (instancetype)entryWithLevel:(CLLogLevel)level
                      function:(const char *)function
                          line:(NSUInteger)line
                       message:(NSString *)message {
    CLLogEntry *entry = [[CLLogEntry alloc] init];
    entry.level = level;
    entry.functionName = [NSString stringWithCString:function encoding:NSUTF8StringEncoding];
    entry.lineNumber = line;
    entry.message = message;
    entry.timestamp = [NSDate date];
    return entry;
}

- (NSString *)formattedString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *timeStr = [formatter stringFromDate:self.timestamp];
    return [NSString stringWithFormat:@"%@ [%@] %@:%lu %@",
            timeStr,
            CLLogLevelString(self.level),
            self.functionName,
            (unsigned long)self.lineNumber,
            self.message];
}

- (NSString *)simpleString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm:ss"];
    NSString *timeStr = [formatter stringFromDate:self.timestamp];
    return [NSString stringWithFormat:@"%@ %@", timeStr, self.message];
}

- (NSDictionary *)toDictionary {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    return @{
        @"level": CLLogLevelString(self.level),
        @"message": self.message ?: @"",
        @"function": self.functionName ?: @"",
        @"line": @(self.lineNumber),
        @"timestamp": [formatter stringFromDate:self.timestamp] ?: @""
    };
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeInteger:self.level forKey:@"level"];
    [coder encodeObject:self.message forKey:@"message"];
    [coder encodeObject:self.functionName forKey:@"functionName"];
    [coder encodeInteger:self.lineNumber forKey:@"lineNumber"];
    [coder encodeObject:self.timestamp forKey:@"timestamp"];
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        _level = [coder decodeIntegerForKey:@"level"];
        _message = [coder decodeObjectForKey:@"message"];
        _functionName = [coder decodeObjectForKey:@"functionName"];
        _lineNumber = [coder decodeIntegerForKey:@"lineNumber"];
        _timestamp = [coder decodeObjectForKey:@"timestamp"];
    }
    return self;
}

@end
