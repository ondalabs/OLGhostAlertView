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

@interface OLGhostAlertView ()

@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *messageLabel;
@property (strong, nonatomic) UITapGestureRecognizer *dismissTap;
@property UIInterfaceOrientation interfaceOrientation;
@property CGFloat bottomMargin;
@property BOOL keyboardIsVisible;
@property CGFloat keyboardHeight;
@property (nonatomic, readwrite) BOOL visible;

@end

@implementation OLGhostAlertView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
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
    
    UIViewController *parentController = [[[UIApplication sharedApplication] delegate] window].rootViewController;

    while (parentController.presentedViewController)
        parentController = parentController.presentedViewController;
    
    UIView *parentView = parentController.view;
    
    [self showInView:parentView];
}

- (void)showInView:(UIView *)view
{
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

- (void)hide
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished){
        self.visible = NO;
        
        [self removeFromSuperview];
        
        if (self.completionBlock) self.completionBlock();
    }];
}

#pragma mark - View layout

- (CGSize)calculateLabelSizeForText:(NSString *)text usingFont:(UIFont *)font restrictedToSize:(CGSize)constrainedSize {
  
  UILabel *gettingSizeLabel = [[UILabel alloc] init];
  gettingSizeLabel.font = font;
  gettingSizeLabel.text = text;
  gettingSizeLabel.numberOfLines = 0;
  CGSize maximumLabelSize = CGSizeMake(310, 9999);
  
  return [gettingSizeLabel sizeThatFits:maximumLabelSize];
  
}


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
    
    CGSize titleSize = [self calculateLabelSizeForText:self.title
                                             usingFont:[UIFont boldSystemFontOfSize:TITLE_FONT_SIZE]
                                      restrictedToSize:constrainedSize];
                                         
    CGSize messageSize = CGSizeZero;
    
    if (self.message) {
       messageSize = [self calculateLabelSizeForText:self.message
                                           usingFont:[UIFont systemFontOfSize:MESSAGE_FONT_SIZE]
                                    restrictedToSize:constrainedSize];

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
    
    if (self.keyboardIsVisible && self.position == OLGhostAlertViewPositionBottom)
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.keyboardHeight, self.frame.size.width, self.frame.size.height);
    
    self.titleLabel.frame = CGRectMake(self.titleLabel.frame.origin.x, ceilf(self.titleLabel.frame.origin.y), ceilf(totalLabelWidth), ceilf(titleSize.height));
    
    if (self.messageLabel) 
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, ceilf(titleSize.height) + floorf(VERTICAL_PADDING * 1.5), ceilf(totalLabelWidth), ceilf(messageSize.height));
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    CGSize keyboardSize = [[keyboardInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    self.keyboardIsVisible = YES;
    self.keyboardHeight = keyboardSize.height;
    
    [self setNeedsLayout];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    self.keyboardIsVisible = NO;
    
    [self setNeedsLayout];
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
    
    UIColor *backgroundColor = [UIColor colorWithWhite:0 alpha:.45];
    UIColor *textColor = [UIColor whiteColor];
    
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

#pragma mark - Cleanup

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeGestureRecognizer:self.dismissTap];
}

@end
