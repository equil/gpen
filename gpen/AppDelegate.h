//
//  AppDelegate.h
//  gpen
//
//  Created by fredformout on 24.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDataAccessManager.h"
#import "CCentralDispatcher.h"
#import "CUpdater.h"
#import "Profile.h"
#import "CStateHolder.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, readonly) CDataAccessManager *dataAccessManager;
@property (nonatomic, readonly) CCentralDispatcher *dispatcher;
@property (nonatomic, readonly) CUpdater *updater;
@property (nonatomic, strong) Profile *lastSignProfile;
@property (nonatomic, assign) BOOL updated;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, readonly) CStateHolder *stateHolder;
@property (nonatomic, assign) int daysForOverdue;
@property (nonatomic, assign) int lastDaysForOverdue;
@property (nonatomic, strong) NSTimer *timer;

- (void)initializeApplication;
- (void)actualizeMainProfile;
- (void)showAlert:(UILocalNotification *)alert;
- (void)timerAction;
- (void)startTimer;

@end
