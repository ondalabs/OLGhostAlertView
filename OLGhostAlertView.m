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

@interface OLGhostAlertView ()

@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *message;
@property (strong, nonatomic) UITapGestureRecognizer *dismissTap;
@property NSTimeInterval timeout;
@property UIInterfaceOrientation interfaceOrientation;
@property BOOL isShowingKeyboard;

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
        _title.textAlignment = UITextAlignmentCenter;
        _title.font = [UIFont boldSystemFontOfSize:TITLE_FONT_SIZE];
        _title.numberOfLines = 0;
        _title.lineBreakMode = UILineBreakModeWordWrap;
        
        [self addSubview:_title];
        
        _message = [[UILabel alloc] initWithFrame:CGRectMake(HORIZONTAL_PADDING, 0, 0, 0)];
        _message.backgroundColor = [UIColor clearColor];
        _message.textColor = [UIColor whiteColor];
        _message.textAlignment = UITextAlignmentCenter;
        _message.font = [UIFont systemFontOfSize:MESSAGE_FONT_SIZE];
        _message.numberOfLines = 0;
        _message.lineBreakMode = UILineBreakModeWordWrap;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didRotate:)
                                                     name:@"UIApplicationDidChangeStatusBarOrientationNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide)
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
    
    CGRect screenRect = [self getScreenBoundsForCurrentOrientation];
    
    CGFloat maxWidth;
    CGFloat totalLabelWidth;
    CGFloat totalHeight;
    
    _interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        NSLog(@"iPhone");
        if (UIDeviceOrientationIsPortrait(_interfaceOrientation)) {
            NSLog(@"portrait");
            maxWidth = 280 - (HORIZONTAL_PADDING * 2);
        } else {
            NSLog(@"landscape");
            maxWidth = 420 - (HORIZONTAL_PADDING * 2);
        }
    } else {
        maxWidth = 520 - (HORIZONTAL_PADDING * 2);
    }
    
    CGSize constrainedSize;
    constrainedSize.width = maxWidth;
    constrainedSize.height = MAXFLOAT;
    
    CGSize titleSize = [title sizeWithFont:[UIFont boldSystemFontOfSize:TITLE_FONT_SIZE] constrainedToSize:constrainedSize];
    CGSize messageSize;
    
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
    
    self = [self initWithFrame:CGRectMake(xPosition, screenRect.size.height + 20, totalWidth, totalHeight)];
    
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
    CGRect fullscreenRect = [self getScreenBoundsForCurrentOrientation];
    
    id appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = [appDelegate window];
    
    if (window.rootViewController.presentedViewController) {
        [window.rootViewController.presentedViewController.view addSubview:self];
    } else {
        [window.rootViewController.view addSubview:self];
    }
    //    [[[[UIApplication sharedApplication] windows] lastObject] addSubview:self];
    
    CGFloat bottomMargin;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        bottomMargin = 25;
    } else {
        bottomMargin = 50;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
        self.frame = CGRectMake(self.frame.origin.x, fullscreenRect.size.height - self.frame.size.height - bottomMargin, self.frame.size.width, self.frame.size.height);
    } completion:^(BOOL finished){
        [NSTimer scheduledTimerWithTimeInterval:self.timeout target:self selector:@selector(hide) userInfo:nil repeats:NO];
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
}

#pragma mark - Handle changes to viewport

- (void)didRotate:(NSNotification *)notification
{
    self.interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
    
    [self didChangeScreenBounds];
}

- (void)keyboardWillShow
{
    self.isShowingKeyboard = YES;
    
    [self didChangeScreenBounds];
}

- (void)keyboardWillHide
{
    self.isShowingKeyboard = NO;
    
    [self didChangeScreenBounds];
}

- (void)didChangeScreenBounds
{
    CGRect screenRect = [self getScreenBoundsForCurrentOrientation];
    
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight;
    
    if (self.isShowingKeyboard) {
        int keyboardHeight;
        
        if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
            keyboardHeight = 352;
        } else {
            keyboardHeight = 264;
        }
        
        screenHeight = screenRect.size.height - keyboardHeight;
    } else {
        screenHeight = screenRect.size.height;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(floorf((screenWidth / 2) - (self.frame.size.width / 2)), screenHeight - self.frame.size.height - 50, self.frame.size.width, self.frame.size.height);
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
        CGRect temp;
        temp.size.width = screenRect.size.height;
        temp.size.height = screenRect.size.width;
        screenRect = temp;
    }
    
    return screenRect;
}

#pragma mark - dealloc

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self removeGestureRecognizer:self.dismissTap];
}

@end
