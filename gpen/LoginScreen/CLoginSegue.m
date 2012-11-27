//
//  CLoginSegue.m
//  gpen
//
//  Created by fredformout on 25.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CLoginSegue.h"
#import "CLoginViewController.h"

@implementation CLoginSegue

- (void)perform
{
    CLoginViewController *src = self.sourceViewController;
    
    [src.continueButton setTitle:@"" forState:UIControlStateNormal];
    [src.continueButton setUserInteractionEnabled:NO];
    [src.spinner startAnimating];
    
    [self performSelector:@selector(push) withObject:self afterDelay:3.0];
}

- (void)push
{
    CLoginViewController *src = self.sourceViewController;
    UITabBarController *dest = self.destinationViewController;
    [dest setModalPresentationStyle:UIModalPresentationCurrentContext];
    [dest setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [src presentViewController:dest animated:YES completion:^(){
        [src.continueButton setTitle:@"Сохранить и продолжить" forState:UIControlStateNormal];
        [src.continueButton setUserInteractionEnabled:YES];
        [src.spinner stopAnimating];
    }];
}

@end
