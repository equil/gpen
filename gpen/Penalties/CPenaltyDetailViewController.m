//
//  CPenaltyDetailViewController.m
//  gpen
//
//  Created by fredformout on 02.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CPenaltyDetailViewController.h"
#import "CPenaltyTicketViewController.h"
#import "AppDelegate.h"

@interface CPenaltyDetailViewController ()

@end

@implementation CPenaltyDetailViewController

@synthesize penalty = _penalty;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"PenaltyDetailToTicket"]) {
        CPenaltyTicketViewController *destination = segue.destinationViewController;
        destination.penalty = _penalty;
    }
}

- (IBAction)sendInfoToEmail
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    dispatch_async(delegate.dispatcher.dataUpdateQueue, ^{
        
        status requestStatus = [delegate.updater sendInfoToProfile:delegate.lastSignProfile penalty:_penalty email:@"ЗДЕСЬ ДОЛЖЕН БЫТЬ ВАШ ИМЭЙЛ"];
        
        if (requestStatus == GOOD)
        {
            //чо то хитрое с юайей, но учти что алерт об успехе вылезет сам
        }
    });
}

@end
