// CLDebugConsole/Plugins/Log/CLLogStorage.m

#import "CLLogStorage.h"
#import "CLDebugFileManager.h"
#import "CLDebugDateFormatter.h"

@interface CLLogStorage ()

@property (nonatomic, strong) NSMutableArray<CLLogEntry *> *memoryCache;
@property (nonatomic, strong) NSMutableArray<CLLogEntry *> *pendingWrites;
@property (nonatomic, strong) NSDate *currentDate;
@property (nonatomic, strong) NSTimer *autoSaveTimer;
@property (nonatomic, strong) dispatch_queue_t ioQueue;

@end

@implementation CLLogStorage

+ (instancetype)sharedStorage {
    static CLLogStorage *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CLLogStorage alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _memoryCache = [NSMutableArray array];
        _pendingWrites = [NSMutableArray array];
        _maxMemoryCacheCount = 1000;
        _autoSaveInterval = 10.0;
        _enableDailyRotation = YES;
        _currentDate = [NSDate date];
        _ioQueue = dispatch_queue_create("com.cldebugconsole.logstorage", DISPATCH_QUEUE_SERIAL);
        _logDirectory = [CLDebugFileManager logDirectory];

        [self loadFromDisk];
        [self startAutoSaveTimer];
    }
    return self;
}

- (void)dealloc {
    [_autoSaveTimer invalidate];
}

#pragma mark - Auto Save Timer

- (void)startAutoSaveTimer {
    self.autoSaveTimer = [NSTimer scheduledTimerWithTimeInterval:self.autoSaveInterval
                                                         target:self
                                                       selector:@selector(autoSaveFired)
                                                       userInfo:nil
                                                        repeats:YES];
}

- (void)autoSaveFired {
    [self saveToDisk];
    [self checkDailyRotation];
}

- (void)checkDailyRotation {
    if (!self.enableDailyRotation) return;

    NSDate *now = [NSDate date];
    if (![CLDebugDateFormatter isSameDay:self.currentDate now]) {
        [self saveToDisk];
        self.currentDate = now;
    }
}

#pragma mark - Write

- (void)addLog:(CLLogEntry *)log {
    if (!log) return;

    @synchronized (self.memoryCache) {
        [self.memoryCache addObject:log];

        if (self.memoryCache.count > self.maxMemoryCacheCount) {
            NSRange range = NSMakeRange(0, self.memoryCache.count - self.maxMemoryCacheCount);
            [self.memoryCache removeObjectsInRange:range];
        }

        [self.pendingWrites addObject:log];

        if (self.pendingWrites.count >= 50) {
            [self saveToDisk];
        }
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"CLLogStorageDidAddLog" object:log];
}

#pragma mark - Read

- (NSArray<CLLogEntry *> *)allLogs {
    @synchronized (self.memoryCache) {
        return [self.memoryCache copy];
    }
}

- (NSArray<CLLogEntry *> *)logsWithFilter:(CLLogFilter *)filter {
    if (!filter) return [self allLogs];

    @synchronized (self.memoryCache) {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(CLLogEntry *entry, NSDictionary *bindings) {
            return [filter matchesEntry:entry];
        }];
        return [self.memoryCache filteredArrayUsingPredicate:predicate];
    }
}

- (NSArray<CLLogEntry *> *)logsWithDate:(NSDate *)date {
    CLLogFilter *filter = [CLLogFilter defaultFilter];
    filter.startDate = [CLDebugDateFormatter startOfDay:date];
    filter.endDate = [CLDebugDateFormatter endOfDay:date];
    return [self logsWithFilter:filter];
}

- (NSArray<CLLogEntry *> *)logsWithDateRange:(NSDate *)startDate endDate:(NSDate *)endDate {
    CLLogFilter *filter = [CLLogFilter defaultFilter];
    filter.startDate = startDate;
    filter.endDate = endDate;
    return [self logsWithFilter:filter];
}

#pragma mark - Persistence

- (void)saveToDisk {
    NSArray *toWrite;
    @synchronized (self.pendingWrites) {
        if (self.pendingWrites.count == 0) return;
        toWrite = [self.pendingWrites copy];
        [self.pendingWrites removeAllObjects];
    }

    NSString *filePath = [self currentLogFile];

    dispatch_async(self.ioQueue, ^{
        for (CLLogEntry *entry in toWrite) {
            NSError *error = nil;
            [CLDebugFileManager appendString:[entry formattedString] toFile:filePath error:&error];
            if (error) {
                NSLog(@"[CLDebugConsole] Failed to write log: %@", error);
            }
        }
    });
}

- (void)loadFromDisk {
    // Memory cache is the source of truth for current session
    // File loading is for export of historical data
}

- (void)clearAll {
    @synchronized (self.memoryCache) {
        [self.memoryCache removeAllObjects];
        [self.pendingWrites removeAllObjects];
    }

    dispatch_async(self.ioQueue, ^{
        NSArray *files = [CLDebugFileManager availableLogFiles];
        NSFileManager *fm = [NSFileManager defaultManager];
        for (NSString *file in files) {
            [fm removeItemAtPath:file error:nil];
        }
    });
}

#pragma mark - File Management

- (NSArray<NSString *> *)availableLogFiles {
    return [CLDebugFileManager availableLogFiles];
}

- (NSString *)currentLogFile {
    return [CLDebugFileManager filePathForDate:[NSDate date]];
}

#pragma mark - Export

- (void)exportAsText:(void(^)(NSString *filePath))completion {
    dispatch_async(self.ioQueue, ^{
        NSString *exportPath = [self.logDirectory stringByAppendingPathComponent:@"export.txt"];
        NSArray *logs = [self allLogs];
        NSMutableString *content = [NSMutableString string];

        for (CLLogEntry *entry in logs) {
            [content appendFormat:@"%@\n", [entry formattedString]];
        }

        [content writeToFile:exportPath atomically:YES encoding:NSUTF8StringEncoding error:nil];

        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(exportPath);
            });
        }
    });
}

- (void)exportAsJSON:(void(^)(NSString *filePath))completion {
    dispatch_async(self.ioQueue, ^{
        NSString *exportPath = [self.logDirectory stringByAppendingPathComponent:@"export.json"];
        NSArray *logs = [self allLogs];
        NSMutableArray *jsonArray = [NSMutableArray array];

        for (CLLogEntry *entry in logs) {
            [jsonArray addObject:[entry toDictionary]];
        }

        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
        [jsonData writeToFile:exportPath atomically:YES];

        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(exportPath);
            });
        }
    });
}

@end
