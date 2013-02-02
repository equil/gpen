//
//  CWithCustomDisclosureIndicatorCell.m
//  gpen
//
//  Created by fredformout on 02.02.13.
//  Copyright (c) 2013 XP.Guild. All rights reserved.
//

#import "CWithCustomDisclosureIndicatorCell.h"

@implementation CWithCustomDisclosureIndicatorCell

- (void)awakeFromNib
{
    if (self.accessoryType == UITableViewCellAccessoryDisclosureIndicator)
    {
        UIButton *accessoryButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 6, 10)];
        [accessoryButton setUserInteractionEnabled:NO];
        [accessoryButton setBackgroundColor:[UIColor clearColor]];
        [accessoryButton setImage:[UIImage imageNamed:@"disclosure.png"] forState:UIControlStateNormal];
        [self setAccessoryView:accessoryButton];
    }
}

@end
