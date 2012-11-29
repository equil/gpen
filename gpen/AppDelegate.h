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

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, readonly) CDataAccessManager *dataAccessManager;
@property (nonatomic, readonly) CCentralDispatcher *dispatcher;
@property (nonatomic, readonly) CUpdater *updater;
@property (nonatomic, strong) Profile *lastSignProfile;

- (void)initializeApplication;

@end
