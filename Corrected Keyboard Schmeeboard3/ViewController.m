//
//  ViewController.m
//  Corrected Keyboard Schmeeboard2 http://github.com/apontious/Keyboard-Schmeeboard/
//
//  Created by Andrew Pontious on 1/5/17.
//  Copyright (c) 2017 Andrew Pontious.
//  Some right reserved: http://opensource.org/licenses/mit-license.php
//

#import "ViewController.h"

// http://stackoverflow.com/questions/32125653/ios-foreign-language-keyboard-heights

@interface ViewController ()

@property (nonatomic) IBOutlet UIView *grayView;
@property (nonatomic) IBOutlet UITextField *textField;

@property (nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;

@property (nonatomic) BOOL inPhoneRotation;

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

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
	[super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone &&
		self.view.bounds.size.height == size.width && self.view.bounds.size.width == size.height) {
		self.inPhoneRotation = YES;
	}
	[coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
	} completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		self.inPhoneRotation = NO;
	}];
}

- (void)willShowKeyboard:(NSNotification *)notification {
    [self handleKeyboardNotification:notification handler:^(const CGRect frameBegin, const CGRect frameEnd, const double animationDuration, const UIViewAnimationOptions animationOptions) {
        UIViewAnimationOptions modifiedAnimationOptions = animationOptions | UIViewAnimationOptionBeginFromCurrentState;
		// http://stackoverflow.com/questions/12622424/how-do-i-animate-constraint-changes
		[self.view layoutIfNeeded];
		
        [UIView animateWithDuration:animationDuration delay:0 options:modifiedAnimationOptions animations:^(){
			self.bottomLayoutConstraint.constant = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(frameEnd);
			[self.view layoutIfNeeded];
        } completion:nil];
    }];
}
- (void)willHideKeyboard:(NSNotification *)notification {
    [self handleKeyboardNotification:notification handler:^(const CGRect frameBegin, const CGRect frameEnd, const double animationDuration, const UIViewAnimationOptions animationOptions) {
		if (self.inPhoneRotation) {
			return;
		}
		[self.view layoutIfNeeded];
		
        [UIView animateWithDuration:animationDuration delay:0 options:animationOptions animations:^{
			self.bottomLayoutConstraint.constant = CGRectGetHeight(self.view.bounds) - CGRectGetMinY(frameEnd);
			[self.view layoutIfNeeded];
        } completion:nil];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self.view addGestureRecognizer:tapGestureRecognizer];
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
