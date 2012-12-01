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
    
    self.tableView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:225.0/255.0 alpha:1.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    Profile *profile = delegate.lastSignProfile;
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ %@", [profile.name capitalizedString], [profile.lastname capitalizedString]]];
    
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

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataSource count];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *result = [self.dataSource objectAtIndex:section];
    return result ? [result count] : 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *penaltyCellId = @"penaltyCell";
    
    NSArray *result = [self.dataSource objectAtIndex:indexPath.section];
    CPenaltyCell *cell = (CPenaltyCell *)[tableView dequeueReusableCellWithIdentifier:penaltyCellId];
    [cell configureCellWithPenalty:[result objectAtIndex:indexPath.row]];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *result = [self.dataSource objectAtIndex:section];
    if (result && result.count > 0)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 28)];
        headerView.backgroundColor = [UIColor clearColor];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 5, headerView.frame.size.width - 32, 20)];
        headerLabel.backgroundColor = [UIColor clearColor];
        switch (section) {
            case 0:
                headerLabel.text = @"Просрочено";
                break;
            case 1:
                headerLabel.text = @"Не оплачено";
                break;
            case 2:
                headerLabel.text = @"Оплачено";
                break;
        }
        headerLabel.textColor = [UIColor darkTextColor];
        headerLabel.font = [UIFont systemFontOfSize:12.0];
        
        [headerView addSubview:headerLabel];
        
        return headerView;
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSArray *result = [self.dataSource objectAtIndex:section];
    return (result && result.count > 0) ? 28.0 : 0;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
