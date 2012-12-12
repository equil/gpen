//
//  AppDelegate.m
//  gpen
//
//  Created by fredformout on 24.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "AppDelegate.h"
#import "CUpdater.h"
#import "CDao.h"
#import "CDao+Profile.h"

@implementation AppDelegate

@synthesize dataAccessManager = _dataAccessManager;
@synthesize dispatcher = _dispatcher;
@synthesize updater = _updater;
@synthesize lastSignProfile = _lastSignProfile;

- (void)customizeTabBar {
    UIImage *tabBarBackground = [UIImage imageNamed:@"tab-bar-back.png"];
    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"select-tab.png"]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont fontWithName:@"Helvetica" size:9.0], UITextAttributeFont, nil]
                                             forState:UIControlStateNormal];
}

- (void)customizeNavigationBar {
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation-bar-back.png"]                 forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont fontWithName:@"PTSans-Bold" size:18.0], UITextAttributeFont, nil]];
    //[[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:87.0/255.0 green:161.0/255.0 blue:214.0/255.0 alpha:1.0]];
    
}

- (void)customizeInterface
{
    [self customizeTabBar];
    [self customizeNavigationBar];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _dispatcher = [[CCentralDispatcher alloc] init];
    _updater = [[CUpdater alloc] init];
    
    [self customizeInterface];
    
    [self.window setRootViewController:[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"SplashViewController"]];
    
    return YES;
}

- (void)initializeApplication {
    _dataAccessManager = [[CDataAccessManager alloc] init];
    [_dataAccessManager.persistentStoreCoordinator class];
    
    [self actualizeMainProfile];
    
    if (_lastSignProfile != nil)
    {
        [_updater updateLastSignForProfile:_lastSignProfile];
        [self.window setRootViewController:[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"MainTabBarController"]];
    }
    else
    {
        [self.window setRootViewController:[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"FirstLoginController"]];
    }
}

- (void)actualizeMainProfile
{
    CDao *dao = [CDao daoWithContext:_dataAccessManager.managedObjectContext];
    _lastSignProfile = [dao lastSignProfile];
    NSLog(@"%@", _lastSignProfile.name);
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

@end
