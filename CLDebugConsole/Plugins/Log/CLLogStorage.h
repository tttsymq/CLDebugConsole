// CLDebugConsole/Plugins/Log/CLLogStorage.h

#import <Foundation/Foundation.h>
#import "CLLogEntry.h"
#import "CLLogFilter.h"

@interface CLLogStorage : NSObject

@property (nonatomic, copy) NSString *logDirectory;
@property (nonatomic) NSUInteger maxMemoryCacheCount;
@property (nonatomic) NSTimeInterval autoSaveInterval;
@property (nonatomic) BOOL enableDailyRotation;

+ (instancetype)sharedStorage;

- (void)addLog:(CLLogEntry *)log;
- (NSArray<CLLogEntry *> *)allLogs;
- (NSArray<CLLogEntry *> *)logsWithFilter:(CLLogFilter *)filter;
- (NSArray<CLLogEntry *> *)logsWithDate:(NSDate *)date;
- (NSArray<CLLogEntry *> *)logsWithDateRange:(NSDate *)startDate endDate:(NSDate *)endDate;

- (void)saveToDisk;
- (void)loadFromDisk;
- (void)clearAll;

- (NSArray<NSString *> *)availableLogFiles;
- (NSString *)currentLogFile;

- (void)exportAsText:(void(^)(NSString *filePath))completion;
- (void)exportAsJSON:(void(^)(NSString *filePath))completion;

@end
