//
//  CPenaltyCell.h
//  gpen
//
//  Created by Ilya Khokhlov on 01.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Penalty.h"
#import "CWithCustomDisclosureIndicatorCell.h"

@interface CPenaltyCell : CWithCustomDisclosureIndicatorCell

@property (nonatomic, strong) IBOutlet UIImageView *penaltyImage;
@property (nonatomic, strong) IBOutlet UILabel *penaltyDate;
@property (nonatomic, strong) IBOutlet UILabel *penaltyPrice;

- (void) configureCellWithPenalty: (Penalty *) penalty;

@end
