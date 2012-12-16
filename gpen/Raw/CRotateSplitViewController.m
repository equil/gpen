//
//  CRotateSplitViewController.m
//  gpen
//
//  Created by fredformout on 14.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CRotateSplitViewController.h"

@interface CRotateSplitViewController ()

@end

@implementation CRotateSplitViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    self.delegate = [self.viewControllers lastObject];
}

@end
