//
//  OLGhostAlertView.m
//
//  Originally created by Radu Dutzan.
//  (c) 2012-2013 Onda.
//

#import <QuartzCore/QuartzCore.h>
#import "OLGhostAlertView.h"

#define HORIZONTAL_PADDING 18.0
#define VERTICAL_PADDING 14.0
#define TITLE_FONT_SIZE 17
#define MESSAGE_FONT_SIZE 14

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
#define NSTextAlignmentCenter UITextAlignmentCenter
#define NSLineBreakByWordWrapping UILineBreakModeWordWrap
#endif

#pragma mark - OLGhostAlertWindow

/*
 OLGhostAlertWindow is a class that inherits from the UIWindow class. It is responsible for displaying an OLGhostAlertView above the application keyWindow. It has methods to show/hide alert above the application main window, which allows to be independent of the system keyboard.
 */

@interface OLGhostAlertWindow : UIWindow

@property (nonatomic, weak) UIWindow *previousKeyWindow;

- (id)initWithRootViewController:(UIViewController *)rootViewController;
- (void)show;
- (void)hide;

@end

@implementation OLGhostAlertWindow

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        self.windowLevel = UIWindowLevelAlert-1.0;
        self.hidden = YES;
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.rootViewController = rootViewController;
    }
    return self;
}

- (void)show
{
    self.previousKeyWindow = [[UIApplication sharedApplication] keyWindow];
    [self makeKeyWindow];
    self.userInteractionEnabled = YES;
    
    if (self.hidden) {
        self.alpha = 0.0;
        self.hidden = NO;
    }
    self.alpha = 1.0;
}

- (void)hide
{
    [[self previousKeyWindow] makeKeyWindow];
    [self setPreviousKeyWindow:nil];
    self.userInteractionEnabled = YES;
    
    self.alpha = 0.0;
    self.hidden = YES;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    // if touch point lies at least inside one of the self.viewController.view.subviews, it will receive a touch
    for (UIView *hitView in self.rootViewController.view.subviews) {
        CGPoint hitPoint = [hitView convertPoint:point fromView:self];
        if ([hitView pointInside:hitPoint withEvent:event]) {
            return hitView;
        }
    }
    return [self.previousKeyWindow hitTest:point withEvent:event];
}

@end

#pragma mark - OLGhostAlertView

@interface OLGhostAlertView ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UITapGestureRecognizer *dismissTap;
@property UIInterfaceOrientation interfaceOrientation;
@property CGFloat bottomMargin;
@property (nonatomic, readwrite) BOOL visible;
@property (nonatomic, strong) OLGhostAlertWindow *alertWindow;
@property (nonatomic, readonly) UIViewController *viewController;

@end

@implementation OLGhostAlertView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIViewController *viewController = [UIViewController new];
        self.alertWindow = [[OLGhostAlertWindow alloc] initWithRootViewController:viewController];
        viewController.view.backgroundColor = [UIColor clearColor];
        
        self.layer.cornerRadius = 5.0f;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.45];
        self.alpha = 0;
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            self.layer.shadowColor = [UIColor blackColor].CGColor;
            self.layer.shadowOpacity = 0.7f;
            self.layer.shadowRadius = 5.0f;
            self.layer.shadowOffset = CGSizeMake(0, 2);
        } else {
            self.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.1].CGColor;
            self.layer.shadowOffset = CGSizeMake(0, 0);
            self.layer.shadowOpacity = 1.0;
            self.layer.shadowRadius = 30.0;
            
            UIMotionEffectGroup *motionEffects = [UIMotionEffectGroup new];
            
            UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
            horizontalMotionEffect.minimumRelativeValue = @-21;
            horizontalMotionEffect.maximumRelativeValue = @21;
            
            UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
            verticalMotionEffect.minimumRelativeValue = @-25;
            verticalMotionEffect.maximumRelativeValue = @25;
            
            motionEffects.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
            
            [self addMotionEffect:motionEffects];
        }
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING, VERTICAL_PADDING, 0, 0)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:TITLE_FONT_SIZE];
        _titleLabel.numberOfLines = 0;
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        
        [self addSubview:_titleLabel];
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING, 0, 0, 0)];
        _messageLabel.backgroundColor = [UIColor clearColor];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:MESSAGE_FONT_SIZE];
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
        
        [self addSubview:_messageLabel];
        
        self.style = OLGhostAlertViewStyleDefault;
        _position = OLGhostAlertViewPositionBottom;
        
        _interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            _bottomMargin = 25;
        else
            _bottomMargin = 50;
        
        _dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didChangeOrientation:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message timeout:(NSTimeInterval)timeout dismissible:(BOOL)dismissible
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.title = title;
        self.message = message;
        self.timeout = timeout;
        self.dismissible = dismissible;
    }
    return self;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message
{
    self = [self initWithTitle:title message:message timeout:6 dismissible:YES];
    return self;
}

- (id)initWithTitle:(NSString *)title
{
    self = [self initWithTitle:title message:nil timeout:4 dismissible:YES];
    return self;
}

#pragma mark - Show and hide

- (void)show
{
    if (!self.title && !self.message)
        NSLog(@"OLGhostAlertView: Your alert doesn't have any content.");
    
    if (self.isVisible) return;
    
    UIView *view = self.viewController.view;
    
    [self.alertWindow show];
    
    for (UIView *subview in [view subviews]) {
        if ([subview isKindOfClass:[OLGhostAlertView class]]) {
            OLGhostAlertView *otherOLGAV = (OLGhostAlertView *)subview;
            [otherOLGAV hide];
        }
    }
    
    [view addSubview:self];
    
    self.visible = YES;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:self.timeout];
    }];
}

- (void)showInView:(UIView *)view
{
    [self show];
}

- (void)hide
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished){
        self.visible = NO;
        
        [self.alertWindow hide];
        [self removeFromSuperview];
        
        if (self.completionBlock) self.completionBlock();
    }];
}

#pragma mark - View layout

- (void)layoutSubviews
{
    CGFloat maxWidth = 0;
    CGFloat totalLabelWidth = 0;
    CGFloat totalHeight = 0;
    
    CGRect screenRect = self.superview.bounds;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (UIDeviceOrientationIsPortrait(self.interfaceOrientation))
            maxWidth = 280 - (HORIZONTAL_PADDING * 2);
        else
            maxWidth = 420 - (HORIZONTAL_PADDING * 2);
    } else {
        maxWidth = 520 - (HORIZONTAL_PADDING * 2);
    }
    
    CGSize constrainedSize = CGSizeZero;
    constrainedSize.width = maxWidth;
    constrainedSize.height = MAXFLOAT;
    
    CGSize titleSize = [self.title sizeWithFont:[UIFont boldSystemFontOfSize:TITLE_FONT_SIZE] constrainedToSize:constrainedSize];
    CGSize messageSize = CGSizeZero;
    
    if (self.message) {
        messageSize = [self.message sizeWithFont:[UIFont systemFontOfSize:MESSAGE_FONT_SIZE] constrainedToSize:constrainedSize];
        
        totalHeight = titleSize.height + messageSize.height + floorf(VERTICAL_PADDING * 2.5);
        
    } else {
        totalHeight = titleSize.height + floorf(VERTICAL_PADDING * 2);
    }
    
    if (titleSize.width == maxWidth || messageSize.width == maxWidth)
        totalLabelWidth = maxWidth;
    
    else if (messageSize.width > titleSize.width)
        totalLabelWidth = messageSize.width;
    
    else
        totalLabelWidth = titleSize.width;
    
    CGFloat totalWidth = totalLabelWidth + (HORIZONTAL_PADDING * 2);
    
    CGFloat xPosition = floorf((screenRect.size.width / 2) - (totalWidth / 2));
    
    CGFloat yPosition = 0;
    
    switch (self.position) {
        case OLGhostAlertViewPositionBottom:
        default:
            yPosition = screenRect.size.height - ceilf(totalHeight) - self.bottomMargin;
            break;
            
        case OLGhostAlertViewPositionCenter:
            yPosition = ceilf((screenRect.size.height / 2) - (totalHeight / 2));
            break;
            
        case OLGhostAlertViewPositionTop:
            yPosition = self.bottomMargin;
            break;
    }
    
    self.frame = CGRectMake(xPosition, yPosition, ceilf(totalWidth), ceilf(totalHeight));
    
    self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, ceilf(self.titleLabel.frame.origin.y), ceilf(totalLabelWidth), ceilf(titleSize.height));
    
    if (self.messageLabel) 
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, ceilf(titleSize.height) + floorf(VERTICAL_PADDING * 1.5), ceilf(totalLabelWidth), ceilf(messageSize.height));
}

#pragma mark - Orientation handling

- (void)didChangeOrientation:(NSNotification *)notification
{
    self.interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    [self setNeedsLayout];
}

#pragma mark - Setters

- (void)setTitle:(NSString *)title
{
    _title = title;
    
    self.titleLabel.text = title;
    
    [self setNeedsLayout];
}

- (void)setMessage:(NSString *)message
{
    _message = message;
    
    self.messageLabel.text = message;
    
    [self setNeedsLayout];
}

- (void)setDismissible:(BOOL)dismissible
{
    _dismissible = dismissible;
    
    if (dismissible)
        [self addGestureRecognizer:self.dismissTap];
    else
        if (self.gestureRecognizers) [self removeGestureRecognizer:self.dismissTap];
}

- (void)setStyle:(OLGhostAlertViewStyle)style
{
    OLGhostAlertViewStyle defaultStyle = OLGhostAlertViewStyleDark;
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
        defaultStyle = OLGhostAlertViewStyleLight;
    
    if (style == OLGhostAlertViewStyleDefault) style = defaultStyle;
    
    _style = style;
    
    UIColor *backgroundColor = nil;
    UIColor *textColor = nil;
    
    if (style == OLGhostAlertViewStyleLight) {
        backgroundColor = [UIColor colorWithWhite:1 alpha:0.95];
        textColor = [UIColor blackColor];
    } else {
        backgroundColor = [UIColor colorWithWhite:0 alpha:.45];
        textColor = [UIColor whiteColor];
    }
    
    self.backgroundColor = backgroundColor;
    self.titleLabel.textColor = textColor;
    self.messageLabel.textColor = textColor;
}

#pragma mark - Helpers

- (UIViewController *)viewController
{
    return self.alertWindow.rootViewController;
}

#pragma mark - Cleanup

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeGestureRecognizer:self.dismissTap];
}

@end
