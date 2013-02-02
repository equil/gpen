//
//  CNavigationBarCustomer.m
//  gpen
//
//  Created by fredformout on 02.02.13.
//  Copyright (c) 2013 XP.Guild. All rights reserved.
//

#import "CNavigationBarCustomer.h"

@implementation CNavigationBarCustomer

+ (void)customizeNavTitle:(NSString *)str navItem:(UINavigationItem *)navItem
{
    UILabel *label;
    if (navItem.leftBarButtonItem == nil && navItem.rightBarButtonItem == nil) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    } else {
        label = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 120, 44)];
    }
    
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 1;
    label.font = [UIFont fontWithName:@"PTSans-Bold" size:18.0];
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    label.shadowColor = [UIColor colorWithRed:24.0/255.0 green:80.0/255.0 blue:146.0/255.0 alpha:1.0];
    label.shadowOffset = CGSizeMake(0.0, 1.0);
    label.textAlignment = UITextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    
    label.text = str;
    
    navItem.titleView = label;
}

@end
