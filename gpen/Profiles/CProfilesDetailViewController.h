//
//  CProfilesDetailViewController.h
//  gpen
//
//  Created by fredformout on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CRotateTableViewController.h"
#import "Profile.h"

@interface CProfilesDetailViewController : CRotateTableViewController

@property (nonatomic, strong) Profile *profile;

- (IBAction)editAction;
- (IBAction)cancelAction;

@end
