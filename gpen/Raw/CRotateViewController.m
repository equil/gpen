//
//  CRotateViewController.m
//  gpen
//
//  Created by fredformout on 02.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CRotateViewController.h"

@interface CRotateViewController ()

@end

@implementation CRotateViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setNeedsLayout];
}

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

- (IBAction)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
