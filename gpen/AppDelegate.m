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
@synthesize daysForOverdue = _daysForOverdue;
@synthesize lastDaysForOverdue = _lastDaysForOverdue;
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
                                                       [UIFont fontWithName:@"Helvetica" size:9.0], UITextAttributeFont, nil]
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
    
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys: [UIFont fontWithName:@"PTSans-Bold" size:18.0], UITextAttributeFont, [UIColor whiteColor], UITextAttributeTextColor, nil]];
}

- (void)customizeInterface
{
    [self customizeTabBar];
    [self customizeNavigationBar];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _daysForOverdue = 3;
    
    _dispatcher = [[CCentralDispatcher alloc] init];
    _updater = [[CUpdater alloc] init];
    
    [self startTimer];
    
    [self customizeInterface];
    
    [self.window setRootViewController:[self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"SplashViewController"]];
    
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
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
    NSLog(@"timer %@", [NSDate date]);
    
    int interval = _daysForOverdue * 24 * 60 * 60;
    
    NSDate *now = [NSDate date];
    
    NSDateComponents *dc = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:now];
    
    NSDateComponents *timerDc = [[NSDateComponents alloc] init];
    [timerDc setYear:[dc year]];
    [timerDc setMonth:[dc month]];
    [timerDc setDay:[dc day] + interval + 1];
    [timerDc setHour:0];
    [timerDc setMinute:0];
    
    NSDate *after = [[NSCalendar currentCalendar] dateFromComponents:timerDc];
    
    CDao *dao = [CDao daoWithContext:_dataAccessManager.managedObjectContext];
    NSArray *overduePenalties = [dao allPenaltiesOverdueAfterDate:after];
    
    NSLog(@"overdue penalties count: %d", [overduePenalties count]);
    
    for (Penalty *p in overduePenalties)
    {
        UILocalNotification *alarm = [[UILocalNotification alloc] init];
        if (alarm)
        {
            alarm.fireDate = [[NSDate date] dateByAddingTimeInterval:3.0];
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
