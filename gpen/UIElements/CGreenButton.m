//
//  CGreenButton.m
//  gpen
//
//  Created by Ilya Khokhlov on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CGreenButton.h"

@implementation CGreenButton

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
    
    self.titleLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    [self setBackgroundImage:[UIImage imageNamed:@"login-button"] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageNamed:@"login-button-disabled"] forState:UIControlStateDisabled];
}

@end
