//
//  CBlackButton.m
//  gpen
//
//  Created by Ilya Khokhlov on 10.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CBlackButton.h"

@implementation CBlackButton

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
    
    [self setBackgroundImage:[[UIImage imageNamed:@"button-black"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 40, 0, 40)] forState:UIControlStateNormal];
}

@end
