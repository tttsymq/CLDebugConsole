# iOS Floating Debug Console - Design Specification

## Overview

A modular floating debug console for iOS applications, built with Objective-C. It provides a floating icon that can be dragged and snapped to screen edges, expanding into a toolbar with multiple debug plugins. The first plugin implements a full-featured logging system with storage, filtering, search, and export capabilities.

## Requirements Summary

1. **Storage**: Memory cache + periodic file persistence
2. **Floating Icon**: Auto-snap to nearest edge (left/right), Y-coordinate preserved
3. **Toolbar Layout**: Left side (minimize, fullscreen); Right side (save, copy, delete)
4. **Display Mode**: Toggle between simple/detailed log formats
5. **Export Format**: Support txt and JSON
6. **Filtering**: Keyword search + log level filtering (Info/Warning/Error)
7. **Scrolling**: Auto-scroll to bottom + "back to top" button
8. **Appearance**: Semi-transparent black background + colored text
9. **Color Scheme**: Info=white, Warning=yellow, Error=red
10. **File Rotation**: Daily log files named YYYY-MM-DD.log

## Architecture Design

### Three-Layer Modular Plugin Architecture

```
┌─────────────────────────────────────┐
│     UI Layer (FloatingToolbar)      │
│  - Floating icon + toolbar + panels │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│   Plugin Management Layer           │
│  - Register/manage debug plugins    │
│  - Log, screenshot, perf plugins    │
└─────────────────────────────────────┘
                 ↓
┌─────────────────────────────────────┐
│   Core Services Layer               │
│  - Log storage, file, config mgmt   │
└─────────────────────────────────────┘
```

## Core Components

### CLDebugConsole (Main Controller)

```objc
@interface CLDebugConsole : NSObject

+ (instancetype)sharedConsole;

// Lifecycle
- (void)start;      // Start debug console, show floating icon
- (void)stop;       // Stop and hide all UI

// Plugin management
- (void)registerPlugin:(id<CLDebugPluginProtocol>)plugin;
- (void)unregisterPlugin:(NSString *)pluginName;
- (NSArray *)registeredPlugins;

// Convenience
- (void)show;       // Show toolbar
- (void)hide;       // Hide toolbar

@end
```

**Responsibilities:**
- Manage floating icon display, dragging, edge snapping
- Manage toolbar expand/collapse animations
- Coordinate plugin registration and dispatch
- Handle window hierarchy (UIWindow)

### CLDebugPluginProtocol (Plugin Protocol)

```objc
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

### CLLogPlugin (Log Plugin)

```objc
@interface CLLogPlugin : NSObject <CLDebugPluginProtocol>

// Logging
- (void)logWithLevel:(CLLogLevel)level
            function:(const char *)function
                line:(NSUInteger)line
              format:(NSString *)format, ...;

// Query and filter
- (NSArray *)allLogs;
- (NSArray *)logsWithKeyword:(NSString *)keyword;
- (NSArray *)logsWithLevel:(CLLogLevel)level;

// Export
- (void)exportAsText:(void(^)(NSString *filePath))completion;
- (void)exportAsJSON:(void(^)(NSString *filePath))completion;

// Management
- (void)clearLogs;

@end

typedef NS_ENUM(NSInteger, CLLogLevel) {
    CLLogLevelInfo = 0,
    CLLogLevelWarning,
    CLLogLevelError
};
```

**Convenience Macros:**

```objc
#define CLLogInfo(frmt, ...)    [[CLLogPlugin shared] logWithLevel:CLLogLevelInfo ...]
#define CLLogWarning(frmt, ...) [[CLLogPlugin shared] logWithLevel:CLLogLevelWarning ...]
#define CLLogError(frmt, ...)   [[CLLogPlugin shared] logWithLevel:CLLogLevelError ...]
```

### CLLogStorage (Log Storage Service)

```objc
@interface CLLogStorage : NSObject

// Write
- (void)addLog:(CLLogEntry *)log;

// Read
- (NSArray *)allLogs;
- (NSArray *)logsWithFilter:(CLLogFilter *)filter;
- (NSArray *)logsWithDate:(NSDate *)date;
- (NSArray *)logsWithDateRange:(NSDate *)startDate endDate:(NSDate *)endDate;

// Persistence
- (void)saveToDisk;
- (void)loadFromDisk;
- (void)clearAll;

// Configuration
@property (nonatomic, copy) NSString *logDirectory;
@property (nonatomic) NSUInteger maxMemoryCacheCount;  // Default: 1000
@property (nonatomic) NSTimeInterval autoSaveInterval; // Default: 10 seconds
@property (nonatomic) BOOL enableDailyRotation;        // Default: YES

// File management
- (NSArray<NSString *> *)availableLogFiles;
- (NSString *)currentLogFile;

@end
```

**Storage Strategy:**
- Memory cache: Latest 1000 logs (configurable)
- File storage: Auto-save every 10 seconds or every 50 logs
- File structure: `Documents/CLDebugLogs/YYYY-MM-DD.log`
- Daily rotation: Automatically switch to new file at midnight
- Cleanup: Auto-delete logs older than 7 days when disk space is low

## Data Flow Design

### Log Recording Flow

```
App code calls CLLogInfo(@"message")
         ↓
CLLogPlugin creates CLLogEntry (timestamp, level, function, line, content)
         ↓
CLLogStorage writes to memory cache
         ↓
Check if auto-save needed (every 10s or 50 logs)
         ↓
Async write to file (non-blocking main thread)
         ↓
Notify UI layer to refresh (if log panel is visible)
```

### Log Query Flow

```
User types keyword in search box
         ↓
CLLogPlugin builds CLLogFilter (keyword, level, date range)
         ↓
CLLogStorage executes filtered query
         ↓
Return results to UI layer
         ↓
UITableView refreshes display
```

### Log Export Flow

```
User taps "Save" button
         ↓
Show export format selection (txt/JSON)
         ↓
CLLogPlugin calls CLLogStorage export method
         ↓
Async generate file (background thread)
         ↓
Export complete, show share sheet (UIActivityViewController)
         ↓
User can share via AirDrop, email, WeChat, save to Files, etc.
```

## UI Interaction Design

### Floating Icon States

```
Initial: Displayed at right edge, vertically centered
         ↓
Dragging: Follows finger, opacity reduced to 0.7
         ↓
Drag end: Auto-snap to nearest left/right edge, Y-coordinate preserved
         ↓
Tap icon: Expand toolbar (slides out from icon position)
```

### Toolbar Layout

```
Expanded toolbar (horizontal):
┌─────────────────────────────────────────┐
│ [Min] [Full]  [Log] [Shot] [Perf]       │
│  Left controls    Plugin icons          │
└─────────────────────────────────────────┘

Each plugin icon tap slides up corresponding panel from bottom
```

### Log Panel Layout

```
┌─────────────────────────────────────────┐
│ [Min] [Full]          [Save][Copy][Del] │  ← Top toolbar
├─────────────────────────────────────────┤
│ 🔍 Search box        [Info▼] [Level]    │  ← Search & filter
├─────────────────────────────────────────┤
│                                         │
│  10:23:45 [Info] viewDidLoad             │  ← Detail mode
│  10:23:46 [Warning] low memory           │
│  10:23:47 [Error] network failed         │
│                                         │
│  or                                       │
│                                         │
│  viewDidLoad                             │  ← Simple mode
│  low memory                              │
│  network failed                          │
│                                         │
├─────────────────────────────────────────┤
│            [Back to top]                │  ← Scroll control
└─────────────────────────────────────────┘
```

### Animations

- **Toolbar expand/collapse**: Spring animation (0.3s)
- **Panel slide in/out**: Slide from bottom (0.25s)
- **Icon dragging**: Real-time follow, no animation
- **Edge snap**: Slight bounce effect (0.2s)

## Error Handling

### Error Types

```objc
typedef NS_ENUM(NSInteger, CLDebugError) {
    CLDebugErrorNone = 0,
    CLDebugErrorFileWriteFailed,
    CLDebugErrorFileReadFailed,
    CLDebugErrorExportFailed,
    CLDebugErrorDiskFull,
    CLDebugErrorInvalidFilter
};
```

### Handling Strategy

- **Log write failure**: Log error to system log (os_log), don't interrupt app
- **Disk full**: Auto-delete logs older than 7 days to free space
- **Export failure**: Show error alert, provide retry option
- **Memory cache overflow**: Auto-evict oldest logs, keep latest in memory

### Edge Cases

| Scenario | Handling |
|----------|----------|
| App crash | Logs already async-written to file, pre-crash logs not lost |
| Large log volume (>10000) | Paginated loading, show 100 logs at a time |
| Rapid continuous logging | Throttle UI refresh to max 10 times/second |
| Screen rotation | Auto-adjust icon position and toolbar layout |
| Multi-window (iPad) | Floating icon only appears in main window |
| Background mode | Stop UI refresh, continue logging to file |

## File Organization

```
CLDebugConsole/
├── Core/
│   ├── CLDebugConsole.h/m
│   ├── CLDebugPluginProtocol.h
│   └── CLDebugMacros.h
│
├── Plugins/
│   └── Log/
│       ├── CLLogPlugin.h/m
│       ├── CLLogStorage.h/m
│       ├── CLLogEntry.h/m
│       ├── CLLogFilter.h/m
│       └── CLLogPanelView.h/m
│
├── UI/
│   ├── CLFloatingIconView.h/m
│   ├── CLToolbarView.h/m
│   └── CLDebugWindow.h/m
│
├── Utils/
│   ├── CLDebugFileManager.h/m
│   └── CLDebugDateFormatter.h/m
│
└── Resources/
    └── CLDebugConsole.bundle
        ├── CLConsole_icon.png
        ├── CLConsole_clear.png
        ├── CLConsole_save.png
        ├── CLConsole_defaltSize.png
        ├── CLConsole_zuidahua.png
        └── CLConsole_zuixiaohua.png
```

## Testing Strategy

### Unit Tests

- `testLogStorage_ShouldSaveToDailyFile`: Verify logs written to correct date file
- `testLogStorage_ShouldRotateOnDateChange`: Verify auto-switch on date change
- `testLogFilter_ShouldMatchKeyword`: Verify keyword filtering
- `testLogPlugin_ShouldSupportMultipleLevels`: Verify log levels

### Integration Tests

- Floating icon drag and snap logic
- Toolbar expand/collapse animations
- Log panel scroll and auto-refresh
- Export functionality completeness

### Performance Tests

- Memory usage: Continuous 10000 logs, memory growth <5MB
- File write: Async write, main thread block <10ms
- UI refresh: Frame rate >30fps during fast scroll

## CocoaPods Integration

### Podspec Configuration

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
  s.source       = { :git => 'https://github.com/yourusername/CLDebugConsole.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '9.0'
  s.requires_arc = true
  
  # Core subspec (always included)
  s.default_subspecs = 'Core', 'LogPlugin'
  
  # Core module
  s.subspec 'Core' do |core|
    core.source_files = 'CLDebugConsole/Core/**/*.{h,m}'
    core.public_header_files = 'CLDebugConsole/Core/**/*.h'
    core.resource_bundles = {
      'CLDebugConsole' => ['CLDebugConsole/Resources/**/*']
    }
    core.frameworks = 'UIKit', 'Foundation'
  end
  
  # Log plugin (optional)
  s.subspec 'LogPlugin' do |log|
    log.source_files = 'CLDebugConsole/Plugins/Log/**/*.{h,m}'
    log.public_header_files = 'CLDebugConsole/Plugins/Log/**/*.h'
    log.dependency 'CLDebugConsole/Core'
  end
  
  # Future plugins can be added as subspecs
  # s.subspec 'ScreenshotPlugin' do |ss|
  #   ss.source_files = 'CLDebugConsole/Plugins/Screenshot/**/*.{h,m}'
  #   ss.dependency 'CLDebugConsole/Core'
  # end
end
```

### Usage via CocoaPods

```ruby
# Podfile
pod 'CLDebugConsole'                    # Include core + log plugin (default)
pod 'CLDebugConsole', :subspecs => ['Core']  # Only core, no plugins
# pod 'CLDebugConsole/LogPlugin'       # Explicitly include log plugin
```

### Integration Example

```objc
// AppDelegate.m
#import <CLDebugConsole/CLDebugConsole.h>
#import <CLDebugConsole/CLLogPlugin.h>

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Start debug console
    [[CLDebugConsole sharedConsole] start];
    
    // Register log plugin
    CLLogPlugin *logPlugin = [CLLogPlugin shared];
    [[CLDebugConsole sharedConsole] registerPlugin:logPlugin];
    
    return YES;
}

// Anywhere in your app
#import <CLDebugConsole/CLDebugMacros.h>

- (void)someMethod {
    CLLogInfo(@"User logged in: %@", username);
    CLLogWarning(@"Low memory: %lu MB", freeMemory);
    CLLogError(@"Network request failed: %@", error);
}
```

## Key Design Decisions

✅ **Modular plugin architecture**: Easy to extend new features  
✅ **Daily log file rotation**: YYYY-MM-DD.log naming  
✅ **Dual storage (memory + file)**: High performance + persistence  
✅ **Semi-transparent black theme**: Colored text for log levels  
✅ **Floating toolbar mode**: Support multi-plugin expansion  
✅ **CocoaPods support**: Modular subspecs for flexible integration  

## Implementation Priority

1. **Phase 1 (Core)**: CLDebugConsole, floating icon, basic toolbar
2. **Phase 2 (Logging)**: CLLogPlugin, CLLogStorage, log panel UI
3. **Phase 3 (Features)**: Search, filter, export, display modes
4. **Phase 4 (Polish)**: Animations, edge cases, performance optimization
5. **Phase 5 (Testing)**: Unit tests, integration tests, performance tests

## Future Extensions

The plugin architecture supports adding:
- **Screenshot plugin**: Capture and annotate screenshots
- **Network monitor plugin**: Inspect HTTP requests/responses
- **Performance plugin**: Monitor FPS, memory, CPU usage
- **Database inspector plugin**: Browse and edit CoreData/SQLite data
- **User defaults plugin**: View and edit NSUserDefaults
- **Crash reporter plugin**: Display crash logs and stack traces
