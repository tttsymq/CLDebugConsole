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
