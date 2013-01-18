//
//  CProfileCell.m
//  gpen
//
//  Created by fredformout on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CProfileCell.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation CProfileCell
@synthesize profileImage = _profileImage;
@synthesize profileName = _profileName;
@synthesize badgeLabel = _badgeLabel;

//- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
//{
//    [super setHighlighted:highlighted animated:animated];
//    
//    if (highlighted == YES)
//    {
//        self.backgroundColor = [UIColor colorWithRed:185.0/255.0 green:185.0/255.0 blue:185.0/255.0 alpha:1.0];
//    }
//    else
//    {
//        self.backgroundColor = [UIColor whiteColor];
//    }
//}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.badgeLabel.backgroundColor = [UIColor colorWithRed:213.0/255.0 green:67.0/255.0 blue:44.0/255.0 alpha:1.0];
    [self.badgeLabel.layer setCornerRadius:8.0];
}

- (void) configureCellWithProfile:(Profile *)profile
{
    unsigned long newPenaltiesCount = [profile.newPenaltiesCount unsignedLongValue];
    if (newPenaltiesCount > 0)
    {
        self.badgeLabel.text = [NSString stringWithFormat:@" %lu ", newPenaltiesCount];
        self.badgeLabel.hidden = NO;
    }
    else
    {
        self.badgeLabel.hidden = YES;
    }
    self.badgeLabel.font = [UIFont fontWithName:@"PTSans-Bold" size:13.0];
    [self.badgeLabel sizeToFit];
    if (self.badgeLabel.frame.size.width < self.badgeLabel.frame.size.height)
    {
        self.badgeLabel.frame = CGRectMake(self.badgeLabel.frame.origin.x, self.badgeLabel.frame.origin.y, self.badgeLabel.frame.size.height, self.badgeLabel.frame.size.height);
    }
    
    self.profileName.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    
    if (profile.profileName && profile.profileName.length > 0)
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
