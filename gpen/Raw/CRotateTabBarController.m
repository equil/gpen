//
//  CRotateTabBarController.m
//  gpen
//
//  Created by fredformout on 02.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CRotateTabBarController.h"

@interface CRotateTabBarController ()

@end

@implementation CRotateTabBarController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *selImages = [NSArray arrayWithObjects:@"pen-tab-active.png", @"pro-tab-active.png", @"info-tab-active.png", nil];
    NSArray *noselImages = [NSArray arrayWithObjects:@"pen-tab-no.png", @"pro-tab-no.png", @"info-tab-no.png", nil];
    
    NSArray *array = self.tabBar.items;
    
    for (int i = 0; i < [array count]; i++) {
        UITabBarItem *item = [array objectAtIndex:i];
        
        UIImage *selectedImage = [UIImage imageNamed:[selImages objectAtIndex:i]];
        UIImage *noselectedImage = [UIImage imageNamed:[noselImages objectAtIndex:i]];
        
        [item setFinishedSelectedImage:selectedImage withFinishedUnselectedImage:noselectedImage];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLocalNotification) name:@"localNotification" object:nil];
}

- (void)handleLocalNotification
{
    self.selectedIndex = 0;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"localNotification" object:nil];
}

@end
