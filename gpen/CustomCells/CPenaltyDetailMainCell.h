//
//  CPenaltyDetailMainCell.h
//  gpen
//
//  Created by Ilya Khokhlov on 05.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CPenaltyDetailMainCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIView *containerView;
@property (nonatomic, strong) IBOutlet UIImageView *carPhoto;
@property (nonatomic, strong) IBOutlet UILabel *nomerLabel;
@property (nonatomic, strong) IBOutlet UILabel *regionLabel;
@property (nonatomic, strong) IBOutlet UIImageView *flag;
@property (nonatomic, strong) IBOutlet UILabel *placeLabel;

@end
