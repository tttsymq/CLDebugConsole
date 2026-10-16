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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.debugWindow = [CLDebugWindow sharedWindow];
        self.debugWindow.hidden = NO;

        self.floatingIcon = [[CLFloatingIconView alloc] init];
        self.floatingIcon.delegate = self;
        [self.floatingIcon showInView:self.debugWindow];
    });
}

- (void)stop {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.floatingIcon hide];
        [self.toolbar dismiss];
        [self removeActivePluginView];
        self.debugWindow.hidden = YES;
        self.isToolbarVisible = NO;
    });
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
    dispatch_async(dispatch_get_main_queue(), ^{
        self.debugWindow.hidden = NO;
        [self.floatingIcon showInView:self.debugWindow];
    });
}

- (void)hide {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.floatingIcon hide];
        [self.toolbar dismiss];
        [self removeActivePluginView];
        self.isToolbarVisible = NO;
    });
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
