//
//  CProfilesAddViewController.m
//  gpen
//
//  Created by fredformout on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CProfilesAddViewController.h"
#import "AppDelegate.h"

@interface CProfilesAddViewController ()

@end

@implementation CProfilesAddViewController

- (IBAction)cancelAction
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveAction
{
    //TODO оверлэй и крутилочку возможно
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    dispatch_async(delegate.dispatcher.dataUpdateQueue, ^{
        
        //TODO сюда твой словарик
        status requestStatus = [delegate.updater insertNewProfileAndUpdate:[NSDictionary dictionary]];
        
        if (requestStatus == GOOD)
        {
            [self cancelAction];
        }
    });
}

@end
