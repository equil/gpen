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
#import "CDao+Penalty.h"

@implementation AppDelegate

@synthesize dataAccessManager = _dataAccessManager;
@synthesize dispatcher = _dispatcher;
@synthesize updater = _updater;
@synthesize lastSignProfile = _lastSignProfile;
@synthesize updated = _updated;
@synthesize deviceToken = _deviceToken;
@synthesize stateHolder = _stateHolder;
@synthesize timer = _timer;

- (void)customizeTabBar
{
    
    UIImage *tabBarBackground;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        tabBarBackground = [UIImage imageNamed:@"tab-bar-back-ipad.png"];
    }
    else
    {
        tabBarBackground = [UIImage imageNamed:@"tab-bar-back.png"];
    }

    [[UITabBar appearance] setBackgroundImage:tabBarBackground];
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"select-tab.png"]];
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont fontWithName:@"Helvetica" size:12.0], UITextAttributeFont, [UIColor darkGrayColor], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset, nil]
                                             forState:UIControlStateNormal];
}

- (void)customizeNavigationBar
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation-bar-back-ipad.png"]                 forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"navigation-bar-back.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"PTSans-Bold" size:18.0], UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, [UIColor colorWithRed:24.0/255.0 green:80.0/255.0 blue:146.0/255.0 alpha:1.0], UITextAttributeTextShadowColor, [NSValue valueWithUIOffset:UIOffsetMake(0, 1)], UITextAttributeTextShadowOffset, nil]];
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
    
    [self startTimer];
    
    [self customizeInterface];
    
    [self.window setRootViewController:[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"SplashViewController"]];
    
    self.deviceToken = @"";
    [self updateDeviceToken];
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    self.deviceToken = [self convertTokenToDeviceID:deviceToken];
	NSLog(@"My token is: %@", deviceToken);
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    self.deviceToken = @"";
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    /*
    {
        "aps" : { "alert" : "Вы получили штраф! Ура!" },
        "l" : "63qq123456",
        "p" : 3
    }
    */
    
    NSString *license = [userInfo objectForKey:@"l"];
    unsigned long penaltyCount = [[userInfo objectForKey:@"p"] unsignedLongValue];
    NSLog(@"push notification: license - %@, count - %lu", license, penaltyCount);
    
    if (license)
    {
        [self.updater setNewPenaltiesCountForLicense:license count:penaltyCount];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushNotification" object:nil];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"localNotification" object:nil];
    }
    else
    {
        UIAlertView *alarm = [[UIAlertView alloc] initWithTitle:@"ГАИ-63" message:notification.alertBody delegate:self cancelButtonTitle:@"Отмена" otherButtonTitles:@"Посмотреть", nil];
        [alarm show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"localNotification" object:nil];
    }
}

- (void)updateDeviceToken {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert];
}

- (NSString *)convertTokenToDeviceID:(NSData *)token {
    NSMutableString *dID = [NSMutableString string];
    unsigned char *ptr = (unsigned char *)[token bytes];
    
    for (NSInteger i=0; i<32; ++i) {
        [dID appendString:[NSString stringWithFormat:@"%02x", ptr[i]]];
    }
    
    return dID;
}

- (void)initializeApplication {
    _dataAccessManager = [[CDataAccessManager alloc] init];
    [_dataAccessManager.persistentStoreCoordinator class];
    
    _stateHolder = [[CStateHolder alloc] init];
    
    [self actualizeMainProfile];
    
    _updated = NO;
    
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
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    //
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    //
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //
}

- (void)startTimer
{
    UIBackgroundTaskIdentifier bgTask = 0;
    UIApplication *app = [UIApplication sharedApplication];
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
    }];
    
    NSDateComponents *dc = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    
    NSDateComponents *timerDc = [[NSDateComponents alloc] init];
    [timerDc setYear:[dc year]];
    [timerDc setMonth:[dc month]];
    [timerDc setDay:[dc day] + 1];
    [timerDc setHour:12];
    [timerDc setMinute:0];
    
    double interval = [[[NSCalendar currentCalendar] dateFromComponents:timerDc] timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval target:self
                                            selector:@selector(startMainTimer) userInfo:nil repeats:NO];
}

- (void)startMainTimer
{
    [_timer invalidate];
    
    [NSTimer scheduledTimerWithTimeInterval:(60 * 60 * 24) target:self
                                   selector:@selector(timerAction) userInfo:nil repeats:YES];
}

- (void)timerAction
{
//    NSLog(@"timer %@", [NSDate date]);
    
    CDao *dao = [CDao daoWithContext:_dataAccessManager.managedObjectContext];
    NSArray *overduePenalties = [dao allPenaltiesOverdueAfterDate:[NSDate date]];
    
//    NSLog(@"overdue penalties count: %d", [overduePenalties count]);
    
    for (Penalty *p in overduePenalties)
    {
        UILocalNotification *alarm = [[UILocalNotification alloc] init];
        if (alarm)
        {
            alarm.fireDate = [[NSDate date] dateByAddingTimeInterval:5.0];
            alarm.timeZone = [NSTimeZone defaultTimeZone];
            alarm.repeatInterval = 0;
            
            NSString *profileStr = [self nameOfProfile:[[p.profiles allObjects] objectAtIndex:0]];
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"dd.MM.yyyy HH:mm"];
            
            alarm.alertBody = [NSString stringWithFormat:@"Уважаемый(-ая) %@! Срок оплаты вашего штрафа от %@ на сумму %@ р. истекает через три дня!", profileStr, [df stringFromDate:p.date], [p.price stringValue]];
                        
            alarm.alertAction = @"Посмотреть";
            
            [_updater updateNotifiedForPenalty:p alert:alarm];
        }
    }
}

- (NSString *)nameOfProfile:(Profile *)profile
{
    return [NSString stringWithFormat:@"%@ %@", profile.lastname, profile.name];
}

- (void)showAlert:(UILocalNotification *)alert
{
    [[UIApplication sharedApplication] scheduleLocalNotification:alert];
}

@end
