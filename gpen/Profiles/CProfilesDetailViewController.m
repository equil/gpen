//
//  CProfilesDetailViewController.m
//  gpen
//
//  Created by fredformout on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CProfilesDetailViewController.h"
#import "AppDelegate.h"

@interface CProfilesDetailViewController ()

@end

@implementation CProfilesDetailViewController

@synthesize profile = _profile;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ %@", [_profile.name capitalizedString], [_profile.lastname capitalizedString]]];
}

- (IBAction)editAction
{
    
}

- (IBAction)cancelAction
{
    
}

@end
