//
//  rbrooksAppDelegate.m
//  MultiTimer
//
//  Created by Ryan Brooks on 3/22/14.
//  Copyright (c) 2014 rbrooks. All rights reserved.
//

#import "rbrooksAppDelegate.h"
#import "MultiTimerTableViewController.h"

@implementation rbrooksAppDelegate
{
    UINavigationController *navigationController;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    navigationController = [[UINavigationController alloc] initWithRootViewController:[[MultiTimerTableViewController alloc] init]];
    navigationController.delegate = self;
    
    self.window.rootViewController = navigationController;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) navigationController:(UINavigationController *)navCont willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    if([viewController conformsToProtocol:@protocol(NavigationBarAppearance)]) {
        UIViewController<NavigationBarAppearance> *vc = (UIViewController<NavigationBarAppearance> *)viewController;
        
        
        if([vc prefersTransparentNavigationBar]) {
            [navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
            [navigationController.navigationBar setTintColor:[UIColor blackColor]];
            
            [navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                     forBarMetrics:UIBarMetricsDefault];
            navigationController.navigationBar.shadowImage = [UIImage new];
            
        }
        else {
            [navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
            navigationController.navigationBar.shadowImage = nil;
            [navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
            //[navigationController.navigationBar setTintColor:kTapletColor];
        }
        UIFont *unboldFont = [UIFont systemFontOfSize:20];
        [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [vc preferredTitleColor],NSFontAttributeName:unboldFont}];
        
        
        if([[vc preferredTitleColor] isEqual:[UIColor whiteColor]])
            navigationController.navigationBar.barStyle = UIBarStyleBlack;
        else
            navigationController.navigationBar.barStyle = UIBarStyleDefault;
        
        
    }
    else {
        [navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        navigationController.navigationBar.shadowImage = nil;
        [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]}];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        navigationController.navigationBar.barStyle = UIBarStyleDefault;
    }
    
}


@end

