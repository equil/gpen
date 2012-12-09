//
//  CProfileCell.m
//  gpen
//
//  Created by fredformout on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CProfileCell.h"
#import "AppDelegate.h"

@implementation CProfileCell
@synthesize profileImage = _profileImage;
@synthesize profileName = _profileName;

- (void) configureCellWithProfile:(Profile *)profile
{
    self.profileName.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    
    if (profile.profileName)
    {
        self.profileName.text = profile.profileName;
    }
    else
    {
        self.profileName.text = [NSString stringWithFormat:@"%@ %@", [profile.name capitalizedString], [profile.lastname capitalizedString]];
    };
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([profile isEqual:delegate.lastSignProfile])
    {
        self.profileImage.image = [UIImage imageNamed:@"profile-blue"];
    }
    else
    {
        self.profileImage.image = [UIImage imageNamed:@"profile-gray"];
    }
}

@end
