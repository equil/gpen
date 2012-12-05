//
//  CPenaltyDetailBoldWithImageCell.m
//  gpen
//
//  Created by Ilya Khokhlov on 05.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CPenaltyDetailBoldWithImageCell.h"

@implementation CPenaltyDetailBoldWithImageCell
@synthesize statusImageView = _statusImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.labelSubtitle.font = [UIFont fontWithName:@"PTSans-Bold" size:16.0];
}

@end
