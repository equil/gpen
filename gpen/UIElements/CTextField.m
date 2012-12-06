//
//  CTextField.m
//  gpen
//
//  Created by Ilya Khokhlov on 06.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CTextField.h"

@implementation CTextField

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
    
    self.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.leftView = paddingView;
    self.leftViewMode = UITextFieldViewModeAlways;
    self.rightView = paddingView;
    self.rightViewMode = UITextFieldViewModeAlways;
    
    self.background = [[UIImage imageNamed:@"text_field"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 40, 0, 40)];
}

@end
