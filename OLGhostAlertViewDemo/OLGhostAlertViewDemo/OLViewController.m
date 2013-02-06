//
//  OLViewController.m
//  OLGhostAlertViewDemo
//
//  Created by Radu Dutzan on 2/5/13.
//  Copyright (c) 2013 Onda. All rights reserved.
//

#import "OLViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "OLGhostAlertView.h"

@interface OLViewController ()

@end

@implementation OLViewController

- (void)loadView
{
    self.view = [UIView new];
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    OLGhostAlertView *demo = [[OLGhostAlertView alloc] initWithTitle:@"Hi there." message:nil timeout:5.0 dismissible:NO];
    demo.position = OLGhostAlertViewPositionTop;
    demo.completionBlock = ^(void) {
        
        OLGhostAlertView *demo2 = [[OLGhostAlertView alloc] initWithTitle:@"This is a demo of OLGhostAlertView."];
        demo2.position = OLGhostAlertViewPositionCenter;
        demo2.completionBlock = ^(void) {
            
            OLGhostAlertView *demo3 = [[OLGhostAlertView alloc] initWithTitle:@"Check out the code." message:@"Try out different setups before implementing it in your app."];
            demo3.completionBlock = ^(void) {
                
                OLGhostAlertView *demo4 = [[OLGhostAlertView alloc] initWithTitle:@"Have fun!" message:@"You can tap this message to dismiss it." timeout:100.0 dismissible:YES];
                demo4.position = OLGhostAlertViewPositionCenter;
                [demo4 show];
                
            };
            [demo3 show];
            
        };
        [demo2 show];
        
    };
    [demo show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
