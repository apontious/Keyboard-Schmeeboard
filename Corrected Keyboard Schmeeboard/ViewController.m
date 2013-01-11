//
//  ViewController.m
//  Keyboard Schmeeboard http://github.com/apontious/Keyboard-Schmeeboard/
//
//  Created by Andrew Pontious on 12/9/12.
//  Copyright (c) 2012-2013 Andrew Pontious. All rights reserved.
//  Some right reserved: http://opensource.org/licenses/mit-license.php
//

#import "ViewController.h"

@interface ViewController ()

@property (strong) IBOutlet UIView *grayView;
@property (strong) IBOutlet UITextField *textField;

@property (strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation ViewController

// Convenience method to turn keyboard notification into usable parameters.
- (void)handleKeyboardNotification:(NSNotification *)notification handler:(void (^)(const CGRect frameBegin, const CGRect frameEnd, const double animationDuration, const UIViewAnimationOptions animationOptions))handler {
    if (handler != nil) {
        CGRect temp = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        const CGRect frameBegin = [self.view convertRect:temp fromView:nil];
        temp = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        const CGRect frameEnd = [self.view convertRect:temp fromView:nil];
        const double animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        const UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] unsignedIntegerValue];
        
        UIViewAnimationOptions animationOptions = 0;

        switch (animationCurve) {
            case UIViewAnimationCurveEaseInOut:
                animationOptions = UIViewAnimationOptionCurveEaseInOut;
                break;
            case UIViewAnimationCurveEaseIn:
                animationOptions = UIViewAnimationOptionCurveEaseIn;
                break;
            case UIViewAnimationCurveEaseOut:
                animationOptions = UIViewAnimationOptionCurveEaseOut;
                break;
            case UIViewAnimationCurveLinear:
                animationOptions = UIViewAnimationOptionCurveLinear;
                break;
            default:
                break;
        }
        

        handler(frameBegin, frameEnd, animationDuration, animationOptions);
    }
}

-(void)handleTap {
    [self.textField resignFirstResponder];
}

- (void)willShowKeyboard:(NSNotification *)notification {
    [self handleKeyboardNotification:notification handler:^(const CGRect frameBegin, const CGRect frameEnd, const double animationDuration, const UIViewAnimationOptions animationOptions) {
        UIViewAnimationOptions modifiedAnimationOptions = animationOptions | UIViewAnimationOptionBeginFromCurrentState;
                
        [UIView animateWithDuration:animationDuration delay:0 options:modifiedAnimationOptions animations:^(){
            CGRect frame = self.grayView.frame;
            frame.size.height = self.view.bounds.size.height - frameEnd.size.height;
            self.grayView.frame = frame;
        } completion:nil];
    }];
}
- (void)willHideKeyboard:(NSNotification *)notification {
    [self handleKeyboardNotification:notification handler:^(const CGRect frameBegin, const CGRect frameEnd, const double animationDuration, const UIViewAnimationOptions animationOptions) {
        [UIView animateWithDuration:animationDuration delay:0 options:animationOptions animations:^{
            CGRect frame = self.grayView.frame;
            frame.size.height = frame.size.height + frameEnd.size.height;;
            self.grayView.frame = frame;
        } completion:nil];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(willShowKeyboard:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(willHideKeyboard:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [center removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - iOS 5 Rotation Methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

#pragma mark - iOS 6 Rotation Methods

- (BOOL)shouldAutorotate {
    return YES;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
