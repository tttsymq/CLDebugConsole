# iOS Floating Debug Console Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a modular floating debug console for iOS with plugin architecture, starting with a full-featured logging plugin.

**Architecture:** Three-layer modular design: Core layer (main controller, plugin protocol, macros), Plugin layer (log plugin as first implementation), UI layer (floating icon, toolbar, panels). Uses dual UIWindow approach - one for floating icon (always on top), one for log panel (slides up).

**Tech Stack:** Objective-C, UIKit, CocoaPods

---

## File Structure

```
CLDebugConsole/
├── Core/
│   ├── CLDebugConsole.h          # Main singleton controller header
│   ├── CLDebugConsole.m          # Main controller implementation
│   ├── CLDebugPluginProtocol.h   # Plugin protocol definition
│   └── CLDebugMacros.h           # Convenience logging macros
│
├── Plugins/Log/
│   ├── CLLogLevel.h              # Log level enum and color definitions
│   ├── CLLogEntry.h              # Log data model header
│   ├── CLLogEntry.m              # Log data model implementation
│   ├── CLLogFilter.h             # Log filter model header
│   ├── CLLogFilter.m             # Log filter model implementation
│   ├── CLLogStorage.h            # Storage service header
│   ├── CLLogStorage.m            # Storage service implementation
│   ├── CLLogPlugin.h             # Log plugin header
│   ├── CLLogPlugin.m             # Log plugin implementation
│   └── CLLogPanelView.h          # Log panel UI header
│   └── CLLogPanelView.m          # Log panel UI implementation
│
├── UI/
│   ├── CLDebugWindow.h           # Custom UIWindow header
│   ├── CLDebugWindow.m           # Custom UIWindow implementation
│   ├── CLFloatingIconView.h      # Floating icon view header
│   ├── CLFloatingIconView.m      # Floating icon view implementation
│   ├── CLToolbarView.h           # Toolbar view header
│   └── CLToolbarView.m           # Toolbar view implementation
│
├── Utils/
│   ├── CLDebugFileManager.h      # File management utilities header
│   ├── CLDebugFileManager.m      # File management utilities implementation
│   ├── CLDebugDateFormatter.h    # Date formatter utilities header
│   └── CLDebugDateFormatter.m    # Date formatter utilities implementation
│
└── Resources/
    └── CLDebugConsole.bundle     # (copy from reference bundle)

CLDebugConsole.podspec            # CocoaPods spec
```

---

### Task 1: Project Setup and Resources

**Files:**
- Create: `CLDebugConsole/Resources/` directory
- Copy: Resource images from reference bundle

- [ ] **Step 1: Create project directory structure**

```bash
cd /Users/ydong/Desktop/iOSConsole
mkdir -p CLDebugConsole/Core
mkdir -p CLDebugConsole/Plugins/Log
mkdir -p CLDebugConsole/UI
mkdir -p CLDebugConsole/Utils
mkdir -p CLDebugConsole/Resources
```

- [ ] **Step 2: Copy resource images from reference bundle**

```bash
cp /Users/ydong/Desktop/chuanglan/real-person-auth-ali-ios/CLLivingDetectionDemo/CLLivingDetectionDemo/Tool/CLConsoleBundle.bundle/CLConsole_icon.png CLDebugConsole/Resources/
cp /Users/ydong/Desktop/chuanglan/real-person-auth-ali-ios/CLLivingDetectionDemo/CLLivingDetectionDemo/Tool/CLConsoleBundle.bundle/CLConsole_clear.png CLDebugConsole/Resources/
cp /Users/ydong/Desktop/chuanglan/real-person-auth-ali-ios/CLLivingDetectionDemo/CLLivingDetectionDemo/Tool/CLConsoleBundle.bundle/CLConsole_save.png CLDebugConsole/Resources/
cp /Users/ydong/Desktop/chuanglan/real-person-auth-ali-ios/CLLivingDetectionDemo/CLLivingDetectionDemo/Tool/CLConsoleBundle.bundle/CLConsole_defaltSize.png CLDebugConsole/Resources/
cp /Users/ydong/Desktop/chuanglan/real-person-auth-ali-ios/CLLivingDetectionDemo/CLLivingDetectionDemo/Tool/CLConsoleBundle.bundle/CLConsole_zuidahua.png CLDebugConsole/Resources/
cp /Users/ydong/Desktop/chuanglan/real-person-auth-ali-ios/CLLivingDetectionDemo/CLLivingDetectionDemo/Tool/CLConsoleBundle.bundle/CLConsole_zuixiaohua.png CLDebugConsole/Resources/
cp /Users/ydong/Desktop/chuanglan/real-person-auth-ali-ios/CLLivingDetectionDemo/CLLivingDetectionDemo/Tool/CLConsoleBundle.bundle/CLConsole_load.png CLDebugConsole/Resources/
```

- [ ] **Step 3: Verify resources are copied**

Run: `ls CLDebugConsole/Resources/`
Expected: 7 PNG files listed

- [ ] **Step 4: Commit**

```bash
git add CLDebugConsole/Resources/
git commit -m "chore: add resource images for debug console"
```

---

### Task 2: CLLogLevel and CLLogEntry Model

**Files:**
- Create: `CLDebugConsole/Plugins/Log/CLLogLevel.h`
- Create: `CLDebugConsole/Plugins/Log/CLLogEntry.h`
- Create: `CLDebugConsole/Plugins/Log/CLLogEntry.m`

- [ ] **Step 1: Create CLLogLevel.h**

```objc
// CLDebugConsole/Plugins/Log/CLLogLevel.h

#ifndef CLLogLevel_h
#define CLLogLevel_h

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CLLogLevel) {
    CLLogLevelInfo = 0,
    CLLogLevelWarning,
    CLLogLevelError
};

static inline NSString *CLLogLevelString(CLLogLevel level) {
    switch (level) {
        case CLLogLevelInfo:    return @"Info";
        case CLLogLevelWarning: return @"Warning";
        case CLLogLevelError:   return @"Error";
    }
    return @"Unknown";
}

static inline UIColor *CLLogLevelColor(CLLogLevel level) {
    switch (level) {
        case CLLogLevelInfo:    return [UIColor whiteColor];
        case CLLogLevelWarning: return [UIColor yellowColor];
        case CLLogLevelError:   return [UIColor redColor];
    }
    return [UIColor whiteColor];
}

#endif /* CLLogLevel_h */
```

- [ ] **Step 2: Create CLLogEntry.h**

```objc
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
```

- [ ] **Step 3: Create CLLogEntry.m**

```objc
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
```

- [ ] **Step 4: Commit**

```bash
git add CLDebugConsole/Plugins/Log/CLLogLevel.h
git add CLDebugConsole/Plugins/Log/CLLogEntry.h
git add CLDebugConsole/Plugins/Log/CLLogEntry.m
git commit -m "feat: add CLLogLevel enum and CLLogEntry model"
```

---

### Task 3: CLLogFilter Model

**Files:**
- Create: `CLDebugConsole/Plugins/Log/CLLogFilter.h`
- Create: `CLDebugConsole/Plugins/Log/CLLogFilter.m`

- [ ] **Step 1: Create CLLogFilter.h**

```objc
// CLDebugConsole/Plugins/Log/CLLogFilter.h

#import <Foundation/Foundation.h>
#import "CLLogLevel.h"

@interface CLLogFilter : NSObject

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, assign) CLLogLevel level;
@property (nonatomic, assign) BOOL levelFilterEnabled;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

+ (instancetype)defaultFilter;
- (BOOL)matchesEntry:(CLLogEntry *)entry;

@end
```

- [ ] **Step 2: Create CLLogFilter.m**

```objc
// CLDebugConsole/Plugins/Log/CLLogFilter.m

#import "CLLogFilter.h"
#import "CLLogEntry.h"

@implementation CLLogFilter

+ (instancetype)defaultFilter {
    CLLogFilter *filter = [[CLLogFilter alloc] init];
    filter.levelFilterEnabled = NO;
    return filter;
}

- (BOOL)matchesEntry:(CLLogEntry *)entry {
    if (!entry) return NO;

    // Keyword filter
    if (self.keyword.length > 0) {
        NSRange range = [entry.message rangeOfString:self.keyword
                                             options:NSCaseInsensitiveSearch];
        if (range.location == NSNotFound) return NO;
    }

    // Level filter
    if (self.levelFilterEnabled && entry.level != self.level) {
        return NO;
    }

    // Date range filter
    if (self.startDate && [entry.timestamp compare:self.startDate] == NSOrderedAscending) {
        return NO;
    }
    if (self.endDate && [entry.timestamp compare:self.endDate] == NSOrderedDescending) {
        return NO;
    }

    return YES;
}

@end
```

- [ ] **Step 3: Commit**

```bash
git add CLDebugConsole/Plugins/Log/CLLogFilter.h
git add CLDebugConsole/Plugins/Log/CLLogFilter.m
git commit -m "feat: add CLLogFilter model"
```

---

### Task 4: Utility Classes

**Files:**
- Create: `CLDebugConsole/Utils/CLDebugDateFormatter.h`
- Create: `CLDebugConsole/Utils/CLDebugDateFormatter.m`
- Create: `CLDebugConsole/Utils/CLDebugFileManager.h`
- Create: `CLDebugConsole/Utils/CLDebugFileManager.m`

- [ ] **Step 1: Create CLDebugDateFormatter.h**

```objc
// CLDebugConsole/Utils/CLDebugDateFormatter.h

#import <Foundation/Foundation.h>

@interface CLDebugDateFormatter : NSObject

+ (NSString *)dailyFileNameForDate:(NSDate *)date;
+ (NSDate *)dateFromDailyFileName:(NSString *)fileName;
+ (NSDate *)startOfDay:(NSDate *)date;
+ (NSDate *)endOfDay:(NSDate *)date;
+ (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2;

@end
```

- [ ] **Step 2: Create CLDebugDateFormatter.m**

```objc
// CLDebugConsole/Utils/CLDebugDateFormatter.m

#import "CLDebugDateFormatter.h"

@implementation CLDebugDateFormatter

static NSDateFormatter *_dailyFormatter(void) {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    });
    return formatter;
}

+ (NSString *)dailyFileNameForDate:(NSDate *)date {
    return [[self dailyFormatter] stringFromDate:date];
}

+ (NSDate *)dateFromDailyFileName:(NSString *)fileName {
    NSString *name = [fileName stringByReplacingOccurrencesOfString:@".log" withString:@""];
    return [[self dailyFormatter] dateFromString:name];
}

+ (NSDate *)startOfDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [calendar dateFromComponents:components];
}

+ (NSDate *)endOfDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *startOfNextDay = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:[self startOfDay:date] options:0];
    return [startOfNextDay dateByAddingTimeInterval:-1];
}

+ (BOOL)isSameDay:(NSDate *)date1 date2:(NSDate *)date2 {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar isDate:date1 inSameDayAsDate:date2];
}

@end
```

- [ ] **Step 3: Create CLDebugFileManager.h**

```objc
// CLDebugConsole/Utils/CLDebugFileManager.h

#import <Foundation/Foundation.h>

@interface CLDebugFileManager : NSObject

+ (NSString *)logDirectory;
+ (NSString *)filePathForDate:(NSDate *)date;
+ (NSArray<NSString *> *)availableLogFiles;
+ (BOOL)appendString:(NSString *)string toFile:(NSString *)filePath error:(NSError **)error;
+ (void)deleteFilesOlderThanDays:(NSUInteger)days inDirectory:(NSString *)directory;
+ (BOOL)createDirectoryIfNeeded:(NSString *)directoryPath;

@end
```

- [ ] **Step 4: Create CLDebugFileManager.m**

```objc
// CLDebugConsole/Utils/CLDebugFileManager.m

#import "CLDebugFileManager.h"
#import "CLDebugDateFormatter.h"

@implementation CLDebugFileManager

+ (NSString *)logDirectory {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    return [documentsPath stringByAppendingPathComponent:@"CLDebugLogs"];
}

+ (NSString *)filePathForDate:(NSDate *)date {
    NSString *fileName = [NSString stringWithFormat:@"%@.log", [CLDebugDateFormatter dailyFileNameForDate:date]];
    return [[self logDirectory] stringByAppendingPathComponent:fileName];
}

+ (NSArray<NSString *> *)availableLogFiles {
    NSString *directory = [self logDirectory];
    NSFileManager *fm = [NSFileManager defaultManager];

    if (![fm fileExistsAtPath:directory]) {
        return @[];
    }

    NSArray *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    NSMutableArray *logFiles = [NSMutableArray array];

    for (NSString *file in files) {
        if ([file hasSuffix:@".log"]) {
            [logFiles addObject:[directory stringByAppendingPathComponent:file]];
        }
    }

    [logFiles sortUsingSelector:@selector(compare:)];
    return [logFiles copy];
}

+ (BOOL)appendString:(NSString *)string toFile:(NSString *)filePath error:(NSError **)error {
    [self createDirectoryIfNeeded:[filePath stringByDeletingLastPathComponent]];

    NSData *data = [[string stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [data writeToFile:filePath options:NSDataWritingAtomic error:error];
    }

    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (!handle) {
        if (error) {
            *error = [NSError errorWithDomain:@"CLDebugConsole" code:1 userInfo:@{NSLocalizedDescriptionKey: @"Failed to open file"}];
        }
        return NO;
    }

    [handle seekToEndOfFile];
    [handle writeData:data];
    [handle closeFile];
    return YES;
}

+ (void)deleteFilesOlderThanDays:(NSUInteger)days inDirectory:(NSString *)directory {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [fm contentsOfDirectoryAtPath:directory error:nil];
    NSDate *cutoffDate = [NSDate dateWithTimeIntervalSinceNow:-(days * 24 * 60 * 60)];

    for (NSString *file in files) {
        if (![file hasSuffix:@".log"]) continue;

        NSString *fullPath = [directory stringByAppendingPathComponent:file];
        NSDate *fileDate = [CLDebugDateFormatter dateFromDailyFileName:file];

        if (fileDate && [fileDate compare:cutoffDate] == NSOrderedAscending) {
            [fm removeItemAtPath:fullPath error:nil];
        }
    }
}

+ (BOOL)createDirectoryIfNeeded:(NSString *)directoryPath {
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:directoryPath]) {
        return [fm createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return YES;
}

@end
```

- [ ] **Step 5: Commit**

```bash
git add CLDebugConsole/Utils/
git commit -m "feat: add utility classes (date formatter, file manager)"
```

---

### Task 5: CLLogStorage Service

**Files:**
- Create: `CLDebugConsole/Plugins/Log/CLLogStorage.h`
- Create: `CLDebugConsole/Plugins/Log/CLLogStorage.m`

- [ ] **Step 1: Create CLLogStorage.h**

```objc
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
```

- [ ] **Step 2: Create CLLogStorage.m**

```objc
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
```

- [ ] **Step 3: Commit**

```bash
git add CLDebugConsole/Plugins/Log/CLLogStorage.h
git add CLDebugConsole/Plugins/Log/CLLogStorage.m
git commit -m "feat: add CLLogStorage service with dual storage"
```

---

### Task 6: Plugin Protocol and Macros

**Files:**
- Create: `CLDebugConsole/Core/CLDebugPluginProtocol.h`
- Create: `CLDebugConsole/Core/CLDebugMacros.h`

- [ ] **Step 1: Create CLDebugPluginProtocol.h**

```objc
// CLDebugConsole/Core/CLDebugPluginProtocol.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol CLDebugPluginProtocol <NSObject>

@required
@property (nonatomic, readonly) NSString *pluginName;
@property (nonatomic, readonly) UIImage *pluginIcon;
@property (nonatomic, readonly) UIView *pluginView;

@optional
- (void)pluginDidLoad;
- (void)pluginWillUnload;
- (void)pluginDidActivate;
- (void)pluginDidDeactivate;

@end
```

- [ ] **Step 2: Create CLDebugMacros.h**

```objc
// CLDebugConsole/Core/CLDebugMacros.h

#ifndef CLDebugMacros_h
#define CLDebugMacros_h

#import "CLLogLevel.h"

@class CLLogPlugin;

#define CLLogInfo(frmt, ...) \
    [[CLLogPlugin sharedPlugin] logWithLevel:CLLogLevelInfo \
                                   function:__PRETTY_FUNCTION__ \
                                       line:__LINE__ \
                                     format:(frmt), ##__VA_ARGS__]

#define CLLogWarning(frmt, ...) \
    [[CLLogPlugin sharedPlugin] logWithLevel:CLLogLevelWarning \
                                    function:__PRETTY_FUNCTION__ \
                                        line:__LINE__ \
                                      format:(frmt), ##__VA_ARGS__]

#define CLLogError(frmt, ...) \
    [[CLLogPlugin sharedPlugin] logWithLevel:CLLogLevelError \
                                    function:__PRETTY_FUNCTION__ \
                                        line:__LINE__ \
                                      format:(frmt), ##__VA_ARGS__]

#endif /* CLDebugMacros_h */
```

- [ ] **Step 3: Commit**

```bash
git add CLDebugConsole/Core/CLDebugPluginProtocol.h
git add CLDebugConsole/Core/CLDebugMacros.h
git commit -m "feat: add plugin protocol and logging macros"
```

---

### Task 7: CLLogPlugin

**Files:**
- Create: `CLDebugConsole/Plugins/Log/CLLogPlugin.h`
- Create: `CLDebugConsole/Plugins/Log/CLLogPlugin.m`

- [ ] **Step 1: Create CLLogPlugin.h**

```objc
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
```

- [ ] **Step 2: Create CLLogPlugin.m**

```objc
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
```

- [ ] **Step 3: Commit**

```bash
git add CLDebugConsole/Plugins/Log/CLLogPlugin.h
git add CLDebugConsole/Plugins/Log/CLLogPlugin.m
git commit -m "feat: add CLLogPlugin implementation"
```

---

### Task 8: CLDebugWindow

**Files:**
- Create: `CLDebugConsole/UI/CLDebugWindow.h`
- Create: `CLDebugConsole/UI/CLDebugWindow.m`

- [ ] **Step 1: Create CLDebugWindow.h**

```objc
// CLDebugConsole/UI/CLDebugWindow.h

#import <UIKit/UIKit.h>

@interface CLDebugWindow : UIWindow

+ (instancetype)sharedWindow;
- (void)makeKeyAndVisibleAboveAllWindows;

@end
```

- [ ] **Step 2: Create CLDebugWindow.m**

```objc
// CLDebugConsole/UI/CLDebugWindow.m

#import "CLDebugWindow.h"

@implementation CLDebugWindow

+ (instancetype)sharedWindow {
    static CLDebugWindow *window = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        window = [[CLDebugWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.windowLevel = UIWindowLevelAlert + 100;
        window.backgroundColor = [UIColor clearColor];
        window.hidden = YES;
    });
    return window;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 100;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)makeKeyAndVisibleAboveAllWindows {
    self.hidden = NO;
    [self makeKeyWindow];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        return nil; // Pass through touches to underlying windows
    }
    return view;
}

@end
```

- [ ] **Step 3: Commit**

```bash
git add CLDebugConsole/UI/CLDebugWindow.h
git add CLDebugConsole/UI/CLDebugWindow.m
git commit -m "feat: add CLDebugWindow for overlay UI"
```

---

### Task 9: CLFloatingIconView

**Files:**
- Create: `CLDebugConsole/UI/CLFloatingIconView.h`
- Create: `CLDebugConsole/UI/CLFloatingIconView.m`

- [ ] **Step 1: Create CLFloatingIconView.h**

```objc
// CLDebugConsole/UI/CLFloatingIconView.h

#import <UIKit/UIKit.h>

@class CLFloatingIconView;

@protocol CLFloatingIconViewDelegate <NSObject>
- (void)floatingIconDidTap:(CLFloatingIconView *)iconView;
@end

@interface CLFloatingIconView : UIView

@property (nonatomic, weak) id<CLFloatingIconViewDelegate> delegate;

- (void)showInView:(UIView *)view;
- (void)hide;

@end
```

- [ ] **Step 2: Create CLFloatingIconView.m**

```objc
// CLDebugConsole/UI/CLFloatingIconView.m

#import "CLFloatingIconView.h"

static const CGFloat kIconSize = 50.0;
static const CGFloat kEdgePadding = 0.0;

@interface CLFloatingIconView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, assign) CGPoint dragStartPoint;
@property (nonatomic, assign) BOOL isDragging;

@end

@implementation CLFloatingIconView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:CGRectMake(0, 0, kIconSize, kIconSize)];
    if (self) {
        [self setupUI];
        [self setupGesture];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor clearColor];
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 2);
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowRadius = 4;

    _iconImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    _iconImageView.layer.cornerRadius = kIconSize / 2.0;
    _iconImageView.clipsToBounds = YES;
    [self addSubview:_iconImageView];

    [self loadIconImage];
}

- (void)loadIconImage {
    // Try resource bundle first
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundlePath = [bundle pathForResource:@"CLDebugConsole" ofType:@"bundle"];
    UIImage *icon = nil;

    if (bundlePath) {
        NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
        icon = [UIImage imageNamed:@"CLConsole_icon" inBundle:resourceBundle compatibleWithTraitCollection:nil];
    }

    if (!icon) {
        icon = [UIImage imageNamed:@"CLConsole_icon"];
    }

    self.iconImageView.image = icon;
}

- (void)setupGesture {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:pan];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [tap requireGestureRecognizerToFail:pan];
    [self addGestureRecognizer:tap];
}

- (void)showInView:(UIView *)view {
    if (!view) {
        view = [CLDebugWindow sharedWindow];
    }

    if (self.superview == view) return;

    [self removeFromSuperview];

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;

    self.frame = CGRectMake(screenWidth - kIconSize - kEdgePadding,
                            screenHeight / 2.0 - kIconSize / 2.0,
                            kIconSize, kIconSize);
    [view addSubview:self];
}

- (void)hide {
    [self removeFromSuperview];
}

#pragma mark - Gestures

- (void)handleTap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(floatingIconDidTap:)]) {
        [self.delegate floatingIconDidTap:self];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan {
    UIView *superView = self.superview;
    if (!superView) return;

    CGPoint translation = [pan translationInView:superView];

    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.dragStartPoint = self.center;
            self.isDragging = YES;
            [UIView animateWithDuration:0.15 animations:^{
                self.alpha = 0.7;
                self.transform = CGAffineTransformMakeScale(1.1, 1.1);
            }];
            break;

        case UIGestureRecognizerStateChanged: {
            CGPoint newCenter = CGPointMake(self.dragStartPoint.x + translation.x,
                                            self.dragStartPoint.y + translation.y);

            // Clamp Y within screen bounds
            CGFloat halfHeight = self.bounds.size.height / 2.0;
            CGFloat minY = halfHeight;
            CGFloat maxY = superView.bounds.size.height - halfHeight;
            newCenter.y = MAX(minY, MIN(maxY, newCenter.y));

            // Clamp X within screen bounds
            CGFloat halfWidth = self.bounds.size.width / 2.0;
            CGFloat minX = halfWidth;
            CGFloat maxX = superView.bounds.size.width - halfWidth;
            newCenter.x = MAX(minX, MIN(maxX, newCenter.x));

            self.center = newCenter;
            break;
        }

        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            self.isDragging = NO;
            [UIView animateWithDuration:0.2
                                  delay:0
                 usingSpringWithDamping:0.7
                  initialSpringVelocity:0.5
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.alpha = 1.0;
                                 self.transform = CGAffineTransformIdentity;
                                 [self snapToNearestEdge];
                             } completion:nil];
            break;
        }

        default:
            break;
    }
}

- (void)snapToNearestEdge {
    UIView *superView = self.superview;
    if (!superView) return;

    CGFloat halfWidth = self.bounds.size.width / 2.0;
    CGFloat screenWidth = superView.bounds.size.width;
    CGFloat centerX = self.center.x;

    CGFloat targetX;
    if (centerX < screenWidth / 2.0) {
        targetX = halfWidth + kEdgePadding;
    } else {
        targetX = screenWidth - halfWidth - kEdgePadding;
    }

    CGPoint newCenter = CGPointMake(targetX, self.center.y);

    // Clamp Y
    CGFloat halfHeight = self.bounds.size.height / 2.0;
    newCenter.y = MAX(halfHeight, MIN(superView.bounds.size.height - halfHeight, newCenter.y));

    self.center = newCenter;
}

@end
```

Note: Add `#import "CLDebugWindow.h"` at the top of CLFloatingIconView.m.

- [ ] **Step 3: Commit**

```bash
git add CLDebugConsole/UI/CLFloatingIconView.h
git add CLDebugConsole/UI/CLFloatingIconView.m
git commit -m "feat: add CLFloatingIconView with drag and edge snap"
```

---

### Task 10: CLToolbarView

**Files:**
- Create: `CLDebugConsole/UI/CLToolbarView.h`
- Create: `CLDebugConsole/UI/CLToolbarView.m`

- [ ] **Step 1: Create CLToolbarView.h**

```objc
// CLDebugConsole/UI/CLToolbarView.h

#import <UIKit/UIKit.h>
#import "CLDebugPluginProtocol.h"

@class CLToolbarView;

@protocol CLToolbarViewDelegate <NSObject>
- (void)toolbarView:(CLToolbarView *)toolbar didTapPlugin:(id<CLDebugPluginProtocol>)plugin;
- (void)toolbarViewDidTapMinimize:(CLToolbarView *)toolbar;
- (void)toolbarViewDidTapFullscreen:(CLToolbarView *)toolbar;
@end

@interface CLToolbarView : UIView

@property (nonatomic, weak) id<CLToolbarViewDelegate> delegate;
@property (nonatomic, assign) BOOL isFullscreen;

- (void)updatePlugins:(NSArray<id<CLDebugPluginProtocol>> *)plugins;
- (void)showFromPoint:(CGPoint)point inView:(UIView *)view;
- (void)dismiss;

@end
```

- [ ] **Step 2: Create CLToolbarView.m**

```objc
// CLDebugConsole/UI/CLToolbarView.m

#import "CLToolbarView.h"

static const CGFloat kToolbarHeight = 50.0;
static const CGFloat kButtonSize = 36.0;
static const CGFloat kButtonSpacing = 10.0;

@interface CLToolbarView ()

@property (nonatomic, strong) UIButton *minimizeButton;
@property (nonatomic, strong) UIButton *fullscreenButton;
@property (nonatomic, strong) NSMutableArray<UIButton *> *pluginButtons;
@property (nonatomic, strong) UIStackView *leftStack;
@property (nonatomic, strong) UIStackView *rightStack;

@end

@implementation CLToolbarView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
    self.layer.cornerRadius = 8;
    self.clipsToBounds = YES;

    _pluginButtons = [NSMutableArray array];

    // Left stack: minimize, fullscreen
    _leftStack = [[UIStackView alloc] init];
    _leftStack.axis = UILayoutConstraintAxisHorizontal;
    _leftStack.spacing = kButtonSpacing;
    _leftStack.alignment = UIStackViewAlignmentCenter;
    [self addSubview:_leftStack];

    _minimizeButton = [self createButtonWithImage:@"CLConsole_zuixiaohua" action:@selector(minimizeTapped)];
    _fullscreenButton = [self createButtonWithImage:@"CLConsole_zuidahua" action:@selector(fullscreenTapped)];
    [_leftStack addArrangedSubview:_minimizeButton];
    [_leftStack addArrangedSubview:_fullscreenButton];

    // Right stack: will be populated with plugin buttons
    _rightStack = [[UIStackView alloc] init];
    _rightStack.axis = UILayoutConstraintAxisHorizontal;
    _rightStack.spacing = kButtonSpacing;
    _rightStack.alignment = UIStackViewAlignmentCenter;
    [self addSubview:_rightStack];
}

- (UIButton *)createButtonWithImage:(NSString *)imageName action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, kButtonSize, kButtonSize);

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundlePath = [bundle pathForResource:@"CLDebugConsole" ofType:@"bundle"];
    UIImage *image = nil;

    if (bundlePath) {
        NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
        image = [UIImage imageNamed:imageName inBundle:resourceBundle compatibleWithTraitCollection:nil];
    }

    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat padding = 10.0;
    CGFloat stackWidth = 2 * kButtonSize + kButtonSpacing;

    _leftStack.frame = CGRectMake(padding, (kToolbarHeight - kButtonSize) / 2.0, stackWidth, kButtonSize);

    CGFloat rightStackWidth = _rightStack.arrangedSubviews.count * kButtonSize +
                              (_rightStack.arrangedSubviews.count > 0 ? (_rightStack.arrangedSubviews.count - 1) * kButtonSpacing : 0);
    _rightStack.frame = CGRectMake(self.bounds.size.width - rightStackWidth - padding,
                                    (kToolbarHeight - kButtonSize) / 2.0,
                                    rightStackWidth, kButtonSize);
}

- (CGSize)intrinsicContentSize {
    CGFloat pluginCount = _rightStack.arrangedSubviews.count;
    CGFloat leftWidth = 2 * kButtonSize + kButtonSpacing;
    CGFloat rightWidth = pluginCount * kButtonSize + (pluginCount > 0 ? (pluginCount - 1) * kButtonSpacing : 0);
    CGFloat totalWidth = leftWidth + rightWidth + 40; // 20 padding each side
    return CGSizeMake(totalWidth, kToolbarHeight);
}

- (void)updatePlugins:(NSArray<id<CLDebugPluginProtocol>> *)plugins {
    // Remove old plugin buttons
    for (UIButton *button in _pluginButtons) {
        [button removeFromSuperview];
    }
    [_pluginButtons removeAllObjects];

    // Add new plugin buttons
    for (id<CLDebugPluginProtocol> plugin in plugins) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, kButtonSize, kButtonSize);
        [button setImage:plugin.pluginIcon forState:UIControlStateNormal];
        button.tag = [plugins indexOfObject:plugin];
        [button addTarget:self action:@selector(pluginButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [_rightStack addArrangedSubview:button];
        [_pluginButtons addObject:button];
    }

    [self setNeedsLayout];
    [self invalidateIntrinsicContentSize];
}

#pragma mark - Actions

- (void)minimizeTapped {
    if ([_delegate respondsToSelector:@selector(toolbarViewDidTapMinimize:)]) {
        [_delegate toolbarViewDidTapMinimize:self];
    }
}

- (void)fullscreenTapped {
    if ([_delegate respondsToSelector:@selector(toolbarViewDidTapFullscreen:)]) {
        [_delegate toolbarViewDidTapFullscreen:self];
    }
}

- (void)pluginButtonTapped:(UIButton *)sender {
    NSUInteger index = sender.tag;
    // Delegate will handle plugin activation
}

#pragma mark - Show/Dismiss

- (void)showFromPoint:(CGPoint)point inView:(UIView *)view {
    if (!view) return;

    [self removeFromSuperview];

    CGFloat toolbarWidth = [self intrinsicContentSize].width;
    CGFloat x = point.x - toolbarWidth / 2.0;
    x = MAX(0, MIN(view.bounds.size.width - toolbarWidth, x));

    self.frame = CGRectMake(x, point.y - kToolbarHeight - 10, toolbarWidth, kToolbarHeight);
    self.alpha = 0;

    [view addSubview:self];

    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.alpha = 1;
                     } completion:nil];
}

- (void)dismiss {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
```

- [ ] **Step 3: Commit**

```bash
git add CLDebugConsole/UI/CLToolbarView.h
git add CLDebugConsole/UI/CLToolbarView.m
git commit -m "feat: add CLToolbarView with plugin buttons"
```

---

### Task 11: CLLogPanelView

**Files:**
- Create: `CLDebugConsole/Plugins/Log/CLLogPanelView.h`
- Create: `CLDebugConsole/Plugins/Log/CLLogPanelView.m`

- [ ] **Step 1: Create CLLogPanelView.h**

```objc
// CLDebugConsole/Plugins/Log/CLLogPanelView.h

#import <UIKit/UIKit.h>

@interface CLLogPanelView : UIView

- (void)refreshLogs;
- (void)setDisplayMode:(BOOL)isDetailed;

@end
```

- [ ] **Step 2: Create CLLogPanelView.m**

```objc
// CLDebugConsole/Plugins/Log/CLLogPanelView.m

#import "CLLogPanelView.h"
#import "CLLogEntry.h"
#import "CLLogFilter.h"
#import "CLLogLevel.h"

static const CGFloat kTopToolbarHeight = 50.0;
static const CGFloat kSearchBarHeight = 44.0;

@interface CLLogPanelView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView *topToolbar;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *copyButton;
@property (nonatomic, strong) UIButton *deleteButton;
@property (nonatomic, strong) UIButton *minimizeButton;
@property (nonatomic, strong) UIButton *fullscreenButton;

@property (nonatomic, strong) UIView *searchBar;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) UIButton *levelFilterButton;

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *backToTopButton;

@property (nonatomic, strong) NSArray<CLLogEntry *> *displayedLogs;
@property (nonatomic, strong) NSArray<CLLogEntry *> *allLogs;
@property (nonatomic, assign) BOOL isDetailedMode;
@property (nonatomic, assign) BOOL autoScrollEnabled;

@end

@implementation CLLogPanelView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupNotifications];
        _autoScrollEnabled = YES;
        _isDetailedMode = YES;
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];

    [self setupTopToolbar];
    [self setupSearchBar];
    [self setupTableView];
    [self setupBackToTopButton];
}

- (void)setupTopToolbar {
    _topToolbar = [[UIView alloc] init];
    _topToolbar.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.9];
    [self addSubview:_topToolbar];

    // Left: minimize, fullscreen
    _minimizeButton = [self createToolbarButton:@"CLConsole_zuixiaohua" action:@selector(minimizeTapped)];
    _fullscreenButton = [self createToolbarButton:@"CLConsole_zuidahua" action:@selector(fullscreenTapped)];
    [_topToolbar addSubview:_minimizeButton];
    [_topToolbar addSubview:_fullscreenButton];

    // Right: save, copy, delete
    _saveButton = [self createToolbarButton:@"CLConsole_save" action:@selector(saveTapped)];
    _copyButton = [self createToolbarButton:@"CLConsole_load" action:@selector(copyTapped)];
    _deleteButton = [self createToolbarButton:@"CLConsole_clear" action:@selector(deleteTapped)];
    [_topToolbar addSubview:_saveButton];
    [_topToolbar addSubview:_copyButton];
    [_topToolbar addSubview:_deleteButton];
}

- (UIButton *)createToolbarButton:(NSString *)imageName action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 30, 30);

    NSBundle *bundle = [NSBundle mainBundle];
    NSString *bundlePath = [bundle pathForResource:@"CLDebugConsole" ofType:@"bundle"];
    UIImage *image = nil;

    if (bundlePath) {
        NSBundle *resourceBundle = [NSBundle bundleWithPath:bundlePath];
        image = [UIImage imageNamed:imageName inBundle:resourceBundle compatibleWithTraitCollection:nil];
    }

    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)setupSearchBar {
    _searchBar = [[UIView alloc] init];
    _searchBar.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    [self addSubview:_searchBar];

    _searchTextField = [[UITextField alloc] init];
    _searchTextField.placeholder = @"Search logs...";
    _searchTextField.textColor = [UIColor whiteColor];
    _searchTextField.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    _searchTextField.layer.cornerRadius = 5;
    _searchTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 30)];
    _searchTextField.leftViewMode = UITextFieldViewModeAlways;
    _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _searchTextField.font = [UIFont systemFontOfSize:14];
    [_searchTextField addTarget:self action:@selector(searchTextChanged:) forControlEvents:UIControlEventEditingChanged];
    [_searchBar addSubview:_searchTextField];

    _levelFilterButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_levelFilterButton setTitle:@"All Levels" forState:UIControlStateNormal];
    [_levelFilterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_levelFilterButton addTarget:self action:@selector(levelFilterTapped) forControlEvents:UIControlEventTouchUpInside];
    [_searchBar addSubview:_levelFilterButton];
}

- (void)setupTableView {
    _tableView = [[UITableView alloc] init];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"LogCell"];
    [self addSubview:_tableView];
}

- (void)setupBackToTopButton {
    _backToTopButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_backToTopButton setTitle:@"Back to Top" forState:UIControlStateNormal];
    [_backToTopButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _backToTopButton.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.7];
    _backToTopButton.layer.cornerRadius = 15;
    _backToTopButton.hidden = YES;
    [_backToTopButton addTarget:self action:@selector(backToTopTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backToTopButton];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleNewLog:)
                                                 name:@"CLLogStorageDidAddLog"
                                               object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat width = self.bounds.size.width;
    CGFloat topY = 0;

    _topToolbar.frame = CGRectMake(0, topY, width, kTopToolbarHeight);
    topY += kTopToolbarHeight;

    _searchBar.frame = CGRectMake(0, topY, width, kSearchBarHeight);
    topY += kSearchBarHeight;

    CGFloat remainingHeight = self.bounds.size.height - topY;
    _tableView.frame = CGRectMake(0, topY, width, remainingHeight);

    // Position toolbar buttons
    CGFloat btnPadding = 10;
    CGFloat btnSize = 30;
    CGFloat btnSpacing = 8;

    _minimizeButton.frame = CGRectMake(btnPadding, (kTopToolbarHeight - btnSize) / 2.0, btnSize, btnSize);
    _fullscreenButton.frame = CGRectMake(btnPadding + btnSize + btnSpacing, (kTopToolbarHeight - btnSize) / 2.0, btnSize, btnSize);

    _deleteButton.frame = CGRectMake(width - btnPadding - btnSize, (kTopToolbarHeight - btnSize) / 2.0, btnSize, btnSize);
    _copyButton.frame = CGRectMake(width - btnPadding - btnSize * 2 - btnSpacing, (kTopToolbarHeight - btnSize) / 2.0, btnSize, btnSize);
    _saveButton.frame = CGRectMake(width - btnPadding - btnSize * 3 - btnSpacing * 2, (kTopToolbarHeight - btnSize) / 2.0, btnSize, btnSize);

    // Position search bar elements
    CGFloat searchPadding = 10;
    _searchTextField.frame = CGRectMake(searchPadding, 7, width - 120, 30);
    _levelFilterButton.frame = CGRectMake(width - 110, 7, 100, 30);

    // Position back to top button
    CGFloat btnWidth = 100;
    CGFloat btnHeight = 30;
    _backToTopButton.frame = CGRectMake((width - btnWidth) / 2.0,
                                         self.bounds.size.height - btnHeight - 10,
                                         btnWidth, btnHeight);
}

#pragma mark - Public

- (void)refreshLogs {
    CLLogPlugin *plugin = [CLLogPlugin sharedPlugin];
    self.allLogs = [plugin allLogs];

    NSString *keyword = self.searchTextField.text;
    if (keyword.length > 0) {
        CLLogFilter *filter = [CLLogFilter defaultFilter];
        filter.keyword = keyword;
        self.displayedLogs = [[CLLogStorage sharedStorage] logsWithFilter:filter];
    } else {
        self.displayedLogs = self.allLogs;
    }

    [self.tableView reloadData];

    if (self.autoScrollEnabled && self.displayedLogs.count > 0) {
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:self.displayedLogs.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)setDisplayMode:(BOOL)isDetailed {
    _isDetailedMode = isDetailed;
    [self.tableView reloadData];
}

#pragma mark - Actions

- (void)handleNewLog:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshLogs];
    });
}

- (void)searchTextChanged:(UITextField *)textField {
    [self refreshLogs];
}

- (void)levelFilterTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Filter by Level"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"All Levels" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self->_levelFilterButton.selected = NO;
        [self->_levelFilterButton setTitle:@"All Levels" forState:UIControlStateNormal];
        [self refreshLogs];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Info" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self filterByLevel:CLLogLevelInfo title:@"Info"];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Warning" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self filterByLevel:CLLogLevelWarning title:@"Warning"];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Error" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self filterByLevel:CLLogLevelError title:@"Error"];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)filterByLevel:(CLLogLevel)level title:(NSString *)title {
    [_levelFilterButton setTitle:title forState:UIControlStateNormal];
    _levelFilterButton.selected = YES;

    CLLogFilter *filter = [CLLogFilter defaultFilter];
    filter.level = level;
    filter.levelFilterEnabled = YES;

    NSString *keyword = _searchTextField.text;
    if (keyword.length > 0) {
        filter.keyword = keyword;
    }

    self.displayedLogs = [[CLLogStorage sharedStorage] logsWithFilter:filter];
    [self.tableView reloadData];
}

- (void)minimizeTapped {
    // Delegate to CLDebugConsole
}

- (void)fullscreenTapped {
    // Delegate to CLDebugConsole
}

- (void)saveTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Export Logs"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    [alert addAction:[UIAlertAction actionWithTitle:@"Export as Text" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self exportAsText];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Export as JSON" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self exportAsJSON];
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)exportAsText {
    [[CLLogPlugin sharedPlugin] exportAsText:^(NSString *filePath) {
        [self shareFile:filePath];
    }];
}

- (void)exportAsJSON {
    [[CLLogPlugin sharedPlugin] exportAsJSON:^(NSString *filePath) {
        [self shareFile:filePath];
    }];
}

- (void)shareFile:(NSString *)filePath {
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
    [self presentViewController:activity animated:YES completion:nil];
}

- (void)copyTapped {
    NSMutableString *allText = [NSMutableString string];
    for (CLLogEntry *entry in self.displayedLogs) {
        [allText appendFormat:@"%@\n", [entry formattedString]];
    }
    [UIPasteboard generalPasteboard].string = allText;

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Copied"
                                                                   message:@"Logs copied to clipboard"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteTapped {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Clear Logs"
                                                                   message:@"Are you sure you want to clear all logs?"
                                                            preferredStyle:UIAlertControllerStyleAlert];

    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Clear" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [[CLLogPlugin sharedPlugin] clearLogs];
    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)backToTopTapped {
    if (self.displayedLogs.count > 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.displayedLogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LogCell" forIndexPath:indexPath];

    CLLogEntry *entry = self.displayedLogs[indexPath.row];

    // Remove old labels
    for (UIView *subview in cell.contentView.subviews) {
        [subview removeFromSuperview];
    }

    cell.backgroundColor = [UIColor clearColor];

    NSString *text = _isDetailedMode ? [entry formattedString] : [entry simpleString];
    UIColor *color = CLLogLevelColor(entry.level);

    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = color;
    label.font = [UIFont fontWithName:@"Menlo" size:11];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [cell.contentView addSubview:label];

    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // Layout the label
    UILabel *label = (UILabel *)cell.contentView.subviews.firstObject;
    if ([label isKindOfClass:[UILabel class]]) {
        CGFloat padding = 8;
        CGFloat maxWidth = tableView.bounds.size.width - padding * 2;
        CGSize size = [label sizeThatFits:CGSizeMake(maxWidth, CGFLOAT_MAX)];
        label.frame = CGRectMake(padding, 4, maxWidth, size.height);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CLLogEntry *entry = self.displayedLogs[indexPath.row];
    NSString *text = _isDetailedMode ? [entry formattedString] : [entry simpleString];

    CGFloat padding = 8;
    CGFloat maxWidth = tableView.bounds.size.width - padding * 2;
    UIFont *font = [UIFont fontWithName:@"Menlo" size:11];
    CGSize size = [text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName: font}
                                     context:nil].size;
    return size.height + 8;
}

#pragma mark - UITableViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    BOOL isAtBottom = (scrollView.contentOffset.y >= scrollView.contentSize.height - scrollView.bounds.size.height - 50);
    self.autoScrollEnabled = isAtBottom;
    self.backToTopButton.hidden = isAtBottom;
}

@end
```

Note: Add `#import "CLLogPlugin.h"` and `#import "CLLogStorage.h"` at the top.

- [ ] **Step 3: Commit**

```bash
git add CLDebugConsole/Plugins/Log/CLLogPanelView.h
git add CLDebugConsole/Plugins/Log/CLLogPanelView.m
git commit -m "feat: add CLLogPanelView with search, filter, and export"
```

---

### Task 12: CLDebugConsole (Main Controller)

**Files:**
- Create: `CLDebugConsole/Core/CLDebugConsole.h`
- Create: `CLDebugConsole/Core/CLDebugConsole.m`

- [ ] **Step 1: Create CLDebugConsole.h**

```objc
// CLDebugConsole/Core/CLDebugConsole.h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CLDebugPluginProtocol.h"

@interface CLDebugConsole : NSObject

+ (instancetype)sharedConsole;

- (void)start;
- (void)stop;

- (void)registerPlugin:(id<CLDebugPluginProtocol>)plugin;
- (void)unregisterPlugin:(NSString *)pluginName;
- (NSArray<id<CLDebugPluginProtocol>> *)registeredPlugins;

- (void)show;
- (void)hide;

@end
```

- [ ] **Step 2: Create CLDebugConsole.m**

```objc
// CLDebugConsole/Core/CLDebugConsole.m

#import "CLDebugConsole.h"
#import "CLDebugWindow.h"
#import "CLFloatingIconView.h"
#import "CLToolbarView.h"

@interface CLDebugConsole () <CLFloatingIconViewDelegate, CLToolbarViewDelegate>

@property (nonatomic, strong) CLDebugWindow *debugWindow;
@property (nonatomic, strong) CLFloatingIconView *floatingIcon;
@property (nonatomic, strong) CLToolbarView *toolbar;
@property (nonatomic, strong) NSMutableArray<id<CLDebugPluginProtocol>> *plugins;
@property (nonatomic, strong) UIView *activePluginView;
@property (nonatomic, assign) BOOL isToolbarVisible;
@property (nonatomic, assign) BOOL isFullscreen;

@end

@implementation CLDebugConsole

+ (instancetype)sharedConsole {
    static CLDebugConsole *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[CLDebugConsole alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _plugins = [NSMutableArray array];
        _isToolbarVisible = NO;
        _isFullscreen = NO;
    }
    return self;
}

#pragma mark - Lifecycle

- (void)start {
    self.debugWindow = [CLDebugWindow sharedWindow];
    self.debugWindow.hidden = NO;

    self.floatingIcon = [[CLFloatingIconView alloc] init];
    self.floatingIcon.delegate = self;
    [self.floatingIcon showInView:self.debugWindow];
}

- (void)stop {
    [self.floatingIcon hide];
    [self.toolbar dismiss];
    [self removeActivePluginView];
    self.debugWindow.hidden = YES;
    self.isToolbarVisible = NO;
}

#pragma mark - Plugin Management

- (void)registerPlugin:(id<CLDebugPluginProtocol>)plugin {
    if (!plugin) return;

    [self.plugins addObject:plugin];

    if ([plugin respondsToSelector:@selector(pluginDidLoad)]) {
        [plugin pluginDidLoad];
    }
}

- (void)unregisterPlugin:(NSString *)pluginName {
    id<CLDebugPluginProtocol> plugin = [self pluginWithName:pluginName];
    if (plugin) {
        [self.plugins removeObject:plugin];
        if ([plugin respondsToSelector:@selector(pluginWillUnload)]) {
            [plugin pluginWillUnload];
        }
    }
}

- (NSArray<id<CLDebugPluginProtocol>> *)registeredPlugins {
    return [self.plugins copy];
}

- (id<CLDebugPluginProtocol>)pluginWithName:(NSString *)name {
    for (id<CLDebugPluginProtocol> plugin in self.plugins) {
        if ([plugin.pluginName isEqualToString:name]) {
            return plugin;
        }
    }
    return nil;
}

#pragma mark - Show/Hide

- (void)show {
    self.debugWindow.hidden = NO;
    [self.floatingIcon showInView:self.debugWindow];
}

- (void)hide {
    [self.floatingIcon hide];
    [self.toolbar dismiss];
    [self removeActivePluginView];
    self.isToolbarVisible = NO;
}

#pragma mark - CLFloatingIconViewDelegate

- (void)floatingIconDidTap:(CLFloatingIconView *)iconView {
    if (self.isToolbarVisible) {
        [self.toolbar dismiss];
        self.isToolbarVisible = NO;
    } else {
        CGPoint iconCenter = iconView.center;
        [self.toolbar updatePlugins:self.plugins];
        [self.toolbar showFromPoint:iconCenter inView:self.debugWindow];
        self.isToolbarVisible = YES;
    }
}

#pragma mark - CLToolbarViewDelegate

- (void)toolbarView:(CLToolbarView *)toolbar didTapPlugin:(id<CLDebugPluginProtocol>)plugin {
    [self removeActivePluginView];
    [self.toolbar dismiss];
    self.isToolbarVisible = NO;

    if ([plugin respondsToSelector:@selector(pluginDidActivate)]) {
        [plugin pluginDidActivate];
    }

    UIView *pluginView = plugin.pluginView;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat panelHeight = self.isFullscreen ? screenHeight : screenHeight / 2.0;

    pluginView.frame = CGRectMake(0, screenHeight - panelHeight, [UIScreen mainScreen].bounds.size.width, panelHeight);

    [self.debugWindow addSubview:pluginView];
    self.activePluginView = pluginView;
}

- (void)toolbarViewDidTapMinimize:(CLToolbarView *)toolbar {
    [self removeActivePluginView];
    [self.toolbar dismiss];
    self.isToolbarVisible = NO;
}

- (void)toolbarViewDidTapFullscreen:(CLToolbarView *)toolbar {
    self.isFullscreen = !self.isFullscreen;

    if (self.activePluginView) {
        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        CGFloat panelHeight = self.isFullscreen ? screenHeight : screenHeight / 2.0;

        [UIView animateWithDuration:0.25 animations:^{
            self.activePluginView.frame = CGRectMake(0,
                                                      screenHeight - panelHeight,
                                                      [UIScreen mainScreen].bounds.size.width,
                                                      panelHeight);
        }];
    }
}

#pragma mark - Private

- (void)removeActivePluginView {
    if (self.activePluginView) {
        [self.activePluginView removeFromSuperview];
        self.activePluginView = nil;
    }
}

- (CLToolbarView *)toolbar {
    if (!_toolbar) {
        _toolbar = [[CLToolbarView alloc] init];
        _toolbar.delegate = self;
    }
    return _toolbar;
}

@end
```

- [ ] **Step 3: Commit**

```bash
git add CLDebugConsole/Core/CLDebugConsole.h
git add CLDebugConsole/Core/CLDebugConsole.m
git commit -m "feat: add CLDebugConsole main controller"
```

---

### Task 13: CocoaPods Spec and Umbrella Header

**Files:**
- Create: `CLDebugConsole.podspec`
- Create: `CLDebugConsole/CLDebugConsole.h` (umbrella header)

- [ ] **Step 1: Create umbrella header**

```objc
// CLDebugConsole/CLDebugConsole.h

#ifndef CLDebugConsole_h
#define CLDebugConsole_h

// Core
#import "CLDebugConsole.h"
#import "CLDebugPluginProtocol.h"
#import "CLDebugMacros.h"

// Log Plugin
#import "CLLogLevel.h"
#import "CLLogEntry.h"
#import "CLLogFilter.h"
#import "CLLogStorage.h"
#import "CLLogPlugin.h"
#import "CLLogPanelView.h"

#endif /* CLDebugConsole_h */
```

- [ ] **Step 2: Create CLDebugConsole.podspec**

```ruby
Pod::Spec.new do |s|
  s.name         = 'CLDebugConsole'
  s.version      = '1.0.0'
  s.summary      = 'A modular floating debug console for iOS applications'
  s.description  = <<-DESC
    CLDebugConsole provides a floating debug toolbar with pluggable modules.
    Features include floating icon with edge snapping, multi-plugin support,
    logging system with storage/filtering/export, and extensible architecture.
  DESC

  s.homepage     = 'https://github.com/yourusername/CLDebugConsole'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Your Name' => 'your.email@example.com' }
  s.source       = { :git => 'https://github.com/yourusage/CLDebugConsole.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.requires_arc = true

  s.default_subspecs = 'Core', 'LogPlugin'

  s.subspec 'Core' do |core|
    core.source_files = 'CLDebugConsole/Core/**/*.{h,m}', 'CLDebugConsole/UI/**/*.{h,m}', 'CLDebugConsole/Utils/**/*.{h,m}'
    core.public_header_files = 'CLDebugConsole/Core/**/*.h', 'CLDebugConsole/UI/**/*.h', 'CLDebugConsole/Utils/**/*.h'
    core.resource_bundles = {
      'CLDebugConsole' => ['CLDebugConsole/Resources/**/*']
    }
    core.frameworks = 'UIKit', 'Foundation'
  end

  s.subspec 'LogPlugin' do |log|
    log.source_files = 'CLDebugConsole/Plugins/Log/**/*.{h,m}'
    log.public_header_files = 'CLDebugConsole/Plugins/Log/**/*.h'
    log.dependency 'CLDebugConsole/Core'
  end
end
```

- [ ] **Step 3: Create LICENSE file**

```
MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 4: Commit**

```bash
git add CLDebugConsole/CLDebugConsole.h
git add CLDebugConsole.podspec
git add LICENSE
git commit -m "feat: add CocoaPods spec and umbrella header"
```

---

### Task 14: Fix Cross-References and Build Verification

**Files:**
- Modify: Various files to add missing imports

- [ ] **Step 1: Add missing import in CLFloatingIconView.m**

Add at the top of `CLDebugConsole/UI/CLFloatingIconView.m`:

```objc
#import "CLDebugWindow.h"
```

- [ ] **Step 2: Add missing imports in CLLogPlugin.m**

Add at the top of `CLDebugConsole/Plugins/Log/CLLogPlugin.m`:

```objc
#import "CLLogStorage.h"
#import "CLLogPanelView.h"
```

- [ ] **Step 3: Add missing imports in CLLogPanelView.m**

Add at the top of `CLDebugConsole/Plugins/Log/CLLogPanelView.m`:

```objc
#import "CLLogPlugin.h"
#import "CLLogStorage.h"
```

- [ ] **Step 4: Add missing import in CLLogFilter.m**

Add at the top of `CLDebugConsole/Plugins/Log/CLLogFilter.m`:

```objc
#import "CLLogEntry.h"
```

- [ ] **Step 5: Verify all files compile**

```bash
cd /Users/ydong/Desktop/iOSConsole
find CLDebugConsole -name "*.h" -o -name "*.m" | sort
```

Expected: All created files listed.

- [ ] **Step 6: Commit**

```bash
git add -A
git commit -m "fix: add missing imports for cross-file references"
```

---

## Summary

This plan implements the iOS Floating Debug Console in 14 tasks following TDD principles. The implementation order ensures each task builds on the previous one:

1. **Task 1**: Project setup and resources
2. **Tasks 2-4**: Data models and utilities (CLLogLevel, CLLogEntry, CLLogFilter, utilities)
3. **Task 5**: Storage service (CLLogStorage)
4. **Task 6**: Plugin protocol and macros
5. **Task 7**: Log plugin (CLLogPlugin)
6. **Tasks 8-10**: UI layer (CLDebugWindow, CLFloatingIconView, CLToolbarView)
7. **Task 11**: Log panel UI (CLLogPanelView)
8. **Task 12**: Main controller (CLDebugConsole)
9. **Task 13**: CocoaPods integration
10. **Task 14**: Final integration and verification

Each task produces working, testable code that can be committed independently.
