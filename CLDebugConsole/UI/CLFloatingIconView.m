// CLDebugConsole/UI/CLFloatingIconView.m

#import "CLFloatingIconView.h"
#import "CLDebugWindow.h"

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
