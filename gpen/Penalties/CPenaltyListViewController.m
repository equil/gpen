//
//  CPenaltyListViewController.m
//  gpen
//
//  Created by Ilya Khokhlov on 01.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CPenaltyListViewController.h"
#import "AppDelegate.h"
#import "Penalty.h"
#import "CPenaltyCell.h"

@interface CPenaltyListViewController ()

@end

@implementation CPenaltyListViewController
@synthesize dataSource = _dataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self doRequest];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) doRequest
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    dispatch_async(delegate.dispatcher.dataUpdateQueue, ^{
        
        self.dataSource = [delegate.updater penaltiesForProfile:delegate.lastSignProfile];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource ? [self.dataSource count] : 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *penaltyCellId = @"penaltyCell";
    
    CPenaltyCell *cell = (CPenaltyCell *)[tableView dequeueReusableCellWithIdentifier:penaltyCellId];
    [cell configureCellWithPenalty:[self.dataSource objectAtIndex:indexPath.row]];
    return cell;
}

@end
