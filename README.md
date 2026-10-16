# CLDebugConsole

一个模块化的iOS悬浮调试控制台，支持插件扩展。

## 功能特性

- **悬浮图标**：可拖拽、自动吸附到屏幕边缘
- **工具栏**：展开显示各功能插件图标
- **日志插件**：完整的日志记录系统
  - 支持 Info/Warning/Error 三个级别
  - 彩色文字区分日志级别（白/黄/红）
  - 内存缓存 + 文件持久化
  - 按天分割日志文件（YYYY-MM-DD.log）
  - 关键词搜索 + 日志级别过滤
  - 支持简洁/详细两种显示模式
  - 导出为 txt 或 JSON 格式
- **插件架构**：可扩展截图、网络监控、性能监控等功能

## 集成方式

### CocoaPods

```ruby
pod 'CLDebugConsole'
```

### 手动集成

将 `CLDebugConsole` 目录拖入项目，并在 Build Settings 中设置：
- 搜索路径包含 `CLDebugConsole` 目录
- 添加资源 bundle

## 使用方法

### 初始化

```objc
// AppDelegate.m
#import <CLDebugConsole/CLDebugConsole.h>

- (BOOL)application:(UIApplication *)application 
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 启动调试控制台
    [[CLDebugConsole sharedConsole] start];
    
    // 注册日志插件
    [[CLDebugConsole sharedConsole] registerPlugin:[CLLogPlugin sharedPlugin]];
    
    return YES;
}
```

### 打印日志

```objc
#import <CLDebugConsole/CLDebugMacros.h>

- (void)someMethod {
    CLLogInfo(@"User logged in: %@", username);
    CLLogWarning(@"Low memory: %lu MB", freeMemory);
    CLLogError(@"Network request failed: %@", error);
}
```

### 查询日志

```objc
// 获取所有日志
NSArray *allLogs = [[CLLogPlugin sharedPlugin] allLogs];

// 按关键词搜索
NSArray *filtered = [[CLLogPlugin sharedPlugin] logsWithKeyword:@"error"];

// 按级别过滤
NSArray *errors = [[CLLogPlugin sharedPlugin] logsWithLevel:CLLogLevelError];
```

### 导出日志

```objc
// 导出为文本
[[CLLogPlugin sharedPlugin] exportAsText:^(NSString *filePath) {
    NSLog(@"Exported to: %@", filePath);
}];

// 导出为JSON
[[CLLogPlugin sharedPlugin] exportAsJSON:^(NSString *filePath) {
    NSLog(@"Exported to: %@", filePath);
}];
```

### 自定义插件

```objc
@interface MyPlugin : NSObject <CLDebugPluginProtocol>
@end

@implementation MyPlugin

- (NSString *)pluginName { return @"MyPlugin"; }
- (UIImage *)pluginIcon { return [UIImage imageNamed:@"my_icon"]; }
- (UIView *)pluginView { return myCustomView; }
- (void)pluginDidActivate { /* 激活时调用 */ }

@end

// 注册插件
[[CLDebugConsole sharedConsole] registerPlugin:[[MyPlugin alloc] init]];
```

## 架构

```
CLDebugConsole/
├── Core/          # 主控制器、插件协议、宏定义
├── Plugins/Log/   # 日志插件实现
├── UI/            # 悬浮图标、工具栏、窗口
├── Utils/         # 工具类（日期、文件管理）
└── Resources/     # 图标资源
```

## License

MIT
