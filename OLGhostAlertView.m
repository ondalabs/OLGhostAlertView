//
//  OLGhostAlertView.m
//
//  Originally created by Radu Dutzan.
//  (c) 2012 Onda.
//

#import <QuartzCore/QuartzCore.h>
#import "OLGhostAlertView.h"

#define HORIZONTAL_PADDING 18.0
#define VERTICAL_PADDING 14.0
#define TITLE_FONT_SIZE 17
#define MESSAGE_FONT_SIZE 15

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
#define NSTextAlignmentCenter UITextAlignmentCenter
#define NSLineBreakByWordWrapping UILineBreakModeWordWrap
#endif

@interface OLGhostAlertView ()

@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *message;
@property (strong, nonatomic) UITapGestureRecognizer *dismissTap;
@property NSTimeInterval timeout;
@property UIInterfaceOrientation interfaceOrientation;
@property CGFloat bottomMargin;
@property BOOL isShowingKeyboard;
@property CGFloat keyboardHeight;

@end

@implementation OLGhostAlertView

@synthesize title = _title;
@synthesize message = _message;
@synthesize dismissTap = _dismissTap;
@synthesize timeout = _timeout;
@synthesize interfaceOrientation = _interfaceOrientation;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 5.0f;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOpacity = 0.7f;
        self.layer.shadowRadius = 5.0f;
        self.layer.shadowOffset = CGSizeMake(0, 2);
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:.45];
        self.alpha = 0;
        
        _title = [[UILabel alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING, VERTICAL_PADDING, 0, 0)];
        _title.backgroundColor = [UIColor clearColor];
        _title.textColor = [UIColor whiteColor];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont boldSystemFontOfSize:TITLE_FONT_SIZE];
        _title.numberOfLines = 0;
        _title.lineBreakMode = NSLineBreakByWordWrapping;
        
        [self addSubview:_title];
        
        _message = [[UILabel alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING, 0, 0, 0)];
        _message.backgroundColor = [UIColor clearColor];
        _message.textColor = [UIColor whiteColor];
        _message.textAlignment = NSTextAlignmentCenter;
        _message.font = [UIFont systemFontOfSize:MESSAGE_FONT_SIZE];
        _message.numberOfLines = 0;
        _message.lineBreakMode = NSLineBreakByWordWrapping;
        
        _position = OLGhostAlertViewPositionBottom;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate:)
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
    // title cannot be nil. message can be nil.
    if (!title) {
        NSLog(@"OLGhostAlertView: title cannot be nil. Your app will now crash.");
        return self;
    }
    
    _interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    CGFloat maxWidth;
    CGFloat totalLabelWidth;
    CGFloat totalHeight;
    
    CGRect screenRect = [self getScreenBoundsForCurrentOrientation];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (UIDeviceOrientationIsPortrait(_interfaceOrientation)) {
            maxWidth = 280 - (HORIZONTAL_PADDING * 2);
        } else {
            maxWidth = 420 - (HORIZONTAL_PADDING * 2);
        }
    } else {
        maxWidth = 520 - (HORIZONTAL_PADDING * 2);
    }
    
    CGSize constrainedSize;
    constrainedSize.width = maxWidth;
    constrainedSize.height = MAXFLOAT;
    
    CGSize titleSize = [title sizeWithFont:[UIFont boldSystemFontOfSize:TITLE_FONT_SIZE] constrainedToSize:constrainedSize];
    CGSize messageSize = CGSizeZero;
    
    if (message) {
        messageSize = [message sizeWithFont:[UIFont systemFontOfSize:MESSAGE_FONT_SIZE] constrainedToSize:constrainedSize];
        
        totalHeight = titleSize.height + messageSize.height + floorf(VERTICAL_PADDING * 2.5);
    } else {
        totalHeight = titleSize.height + floorf(VERTICAL_PADDING * 2);
    }
    
    if (titleSize.width == maxWidth || messageSize.width == maxWidth) {
        totalLabelWidth = maxWidth;
    } else if (messageSize.width > titleSize.width) {
        totalLabelWidth = messageSize.width;
    } else {
        totalLabelWidth = titleSize.width;
    }
    
    CGFloat totalWidth = totalLabelWidth + (HORIZONTAL_PADDING * 2);
    
    CGFloat xPosition = floorf((screenRect.size.width / 2) - (totalWidth / 2));
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        _bottomMargin = 25;
    } else {
        _bottomMargin = 50;
    }
    
    self = [self initWithFrame:CGRectMake(xPosition, screenRect.size.height - totalHeight - _bottomMargin, totalWidth, totalHeight)];
    
    if (self) {
        _title.text = title;
        _title.frame = CGRectMake(_title.frame.origin.x, _title.frame.origin.y, totalLabelWidth, titleSize.height);
        
        if (message) {
            _message.text = message;
            _message.frame = CGRectMake(_message.frame.origin.x, titleSize.height + floorf(VERTICAL_PADDING * 1.5), totalLabelWidth, messageSize.height);
            
            [self addSubview:_message];
        }
        
        _timeout = timeout;
        
        if (dismissible) {
            _dismissTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
            
            [self addGestureRecognizer:_dismissTap];
        }
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
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIView *parentView;
    
    if (window.rootViewController.presentedViewController) {
        parentView = window.rootViewController.presentedViewController.view;
    } else {
        parentView = window.rootViewController.view;
    }
    
    for (UIView *subView in [parentView subviews]) {
        if ([subView isKindOfClass:[OLGhostAlertView class]]) {
            OLGhostAlertView *otherOLGAV = (OLGhostAlertView *)subView;
            [otherOLGAV hide];
        }
    }
    
    [parentView addSubview:self];
    
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
        [self removeFromSuperview];
        
        if (self.completionBlock) {
            self.completionBlock();
        }
    }];
}

#pragma mark - Handle changes to viewport

- (void)didRotate:(NSNotification *)notification
{
    self.interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    [self didChangeScreenBounds];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    CGSize keyboardSize = [[keyboardInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    self.isShowingKeyboard = YES;
    self.keyboardHeight = keyboardSize.height;
    
    [self didChangeScreenBounds];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    self.isShowingKeyboard = NO;
    
    [self didChangeScreenBounds];
}

- (void)didChangeScreenBounds
{
    CGRect screenRect = [self getScreenBoundsForCurrentOrientation];
    
    self.frame = CGRectMake(floorf((screenRect.size.width / 2) - (self.frame.size.width / 2)), self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    
    OLGhostAlertViewPosition storedPosition = self.position;
    _position = 8;
    self.position = storedPosition;
    
    if (self.isShowingKeyboard && self.position == OLGhostAlertViewPositionBottom) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y - self.keyboardHeight, self.frame.size.width, self.frame.size.height);
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    }];
}

#pragma mark - Orientation helper methods

- (CGRect)getScreenBoundsForCurrentOrientation
{
    return [self getScreenBoundsForOrientation:self.interfaceOrientation];
}

- (CGRect)getScreenBoundsForOrientation:(UIInterfaceOrientation)orientation
{
    UIScreen *screen = [UIScreen mainScreen];
    CGRect screenRect = screen.bounds; // implicitly in Portrait orientation.
    
    if (UIDeviceOrientationIsLandscape(orientation)) {
        CGRect temp = CGRectMake(0, 0, screenRect.size.height, screenRect.size.width);
        screenRect = temp;
    }
    
    return screenRect;
}

#pragma mark - Position setter

- (void)setPosition:(OLGhostAlertViewPosition)position
{
    if (_position == position) return;
    
    _position = position;
    
    CGRect screenRect = [self getScreenBoundsForCurrentOrientation];
    
    CGFloat yPosition;
    
    switch (position) {
        case OLGhostAlertViewPositionBottom:
            yPosition = screenRect.size.height - self.frame.size.height - self.bottomMargin;
            break;
            
        case OLGhostAlertViewPositionCenter:
            yPosition = ceilf((screenRect.size.height / 2) - (self.frame.size.height / 2));
            break;
            
        case OLGhostAlertViewPositionTop:
            yPosition = self.bottomMargin;
            break;
    }
    
    self.frame = CGRectMake(self.frame.origin.x, yPosition, self.frame.size.width, self.frame.size.height);
}

#pragma mark - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeGestureRecognizer:self.dismissTap];
}

@end
