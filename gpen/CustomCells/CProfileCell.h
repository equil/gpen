//
//  CProfileCell.h
//  gpen
//
//  Created by fredformout on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"

@interface CProfileCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *profileImage;
@property (nonatomic, strong) IBOutlet UILabel *profileName;
@property (nonatomic, strong) IBOutlet UILabel *badgeLabel;
@property (nonatomic, strong) IBOutlet UIView *badgeView;

- (void) configureCellWithProfile: (Profile *) profile;

@end
