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

    CGFloat pluginCount = _rightStack.arrangedSubviews.count;
    CGFloat rightStackWidth = pluginCount * kButtonSize + (pluginCount > 0 ? (pluginCount - 1) * kButtonSpacing : 0);
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

    // Remove old arranged subviews
    for (UIView *subview in _rightStack.arrangedSubviews) {
        [_rightStack removeArrangedSubview:subview];
        [subview removeFromSuperview];
    }

    // Add new plugin buttons
    for (NSUInteger i = 0; i < plugins.count; i++) {
        id<CLDebugPluginProtocol> plugin = plugins[i];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, kButtonSize, kButtonSize);
        [button setImage:plugin.pluginIcon forState:UIControlStateNormal];
        button.tag = i;
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
    // The delegate will handle this through the stored plugins array
    // For now we store the index in the button tag
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
