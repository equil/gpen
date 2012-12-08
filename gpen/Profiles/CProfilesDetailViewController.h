//
//  CProfilesDetailViewController.h
//  gpen
//
//  Created by fredformout on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CRotateTableViewController.h"
#import "Profile.h"

@interface CProfilesDetailViewController : CRotateTableViewController <UIAlertViewDelegate>
{
    BOOL editingMode;
}

@property (nonatomic, strong) Profile *profile;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) NSMutableDictionary *backupInfo;

- (IBAction)editAction;
- (IBAction)makeMain;

@end
