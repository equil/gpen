//
//  CProfilesDetailViewController.h
//  gpen
//
//  Created by fredformout on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CRotateViewController.h"
#import "Profile.h"

@interface CProfilesDetailViewController : CRotateViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) Profile *profile;

@end
