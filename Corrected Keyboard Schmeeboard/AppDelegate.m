//
//  AppDelegate.m
//  Corrected Keyboard Schmeeboard http://github.com/apontious/Keyboard-Schmeeboard/
//
//  Created by Andrew Pontious on 12/9/12.
//  Copyright (c) 2012-2013 Andrew Pontious.
//  Some right reserved: http://opensource.org/licenses/mit-license.php
//

#import "AppDelegate.h"

#import "ViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
