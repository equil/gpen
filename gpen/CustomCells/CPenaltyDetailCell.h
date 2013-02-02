//
//  CPenaltyDetailCell.h
//  gpen
//
//  Created by Ilya Khokhlov on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWithCustomDisclosureIndicatorCell.h"

@interface CPenaltyDetailCell : CWithCustomDisclosureIndicatorCell

@property (nonatomic, strong) IBOutlet UILabel *labelTitle;
@property (nonatomic, strong) IBOutlet UILabel *labelSubtitle;

@end
