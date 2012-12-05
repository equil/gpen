//
//  CPenaltyDetailMainCell.m
//  gpen
//
//  Created by Ilya Khokhlov on 05.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CPenaltyDetailMainCell.h"

@implementation CPenaltyDetailMainCell

@synthesize carPhoto = _carPhoto;
@synthesize nomerLabel = _nomerLabel;
@synthesize regionLabel = _regionLabel;
@synthesize flag = _flag;
@synthesize placeLabel = _placeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.nomerLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    self.regionLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:13.0];
    self.placeLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:13.0];
}

@end
