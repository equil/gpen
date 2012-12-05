//
//  CPenaltyDetailCell.m
//  gpen
//
//  Created by Ilya Khokhlov on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CPenaltyDetailCell.h"

@implementation CPenaltyDetailCell
@synthesize labelTitle = _labelTitle;
@synthesize labelSubtitle = _labelSubtitle;

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
    
    self.labelTitle.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    self.labelSubtitle.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
}

@end
