//
//  AppDelegate.m
//  OriginateRemoteCollection-Example
//
//  Created by Philip Kluz on 9/30/15.
//  Copyright © 2015 originate.com. All rights reserved.
//

#import "AppDelegate.h"
#import "MyViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    MyViewController *controller = [[MyViewController alloc] init];
    controller.view.backgroundColor = [UIColor whiteColor];
    
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
