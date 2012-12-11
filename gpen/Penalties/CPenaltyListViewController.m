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
#import "CPenaltyDetailViewController.h"

@interface CPenaltyListViewController ()
@property(nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end

@implementation CPenaltyListViewController
{
    @private
    NSFetchedResultsController *_fetchedResultsController;
}

@synthesize tableView = _tableView;
@synthesize spinner = _spinner;
@synthesize informLabel = _informLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"PenaltyListToDetail"]) {
        CPenaltyDetailViewController *destination = segue.destinationViewController;
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        destination.penalty = [self.fetchedResultsController objectAtIndexPath:path];
    }
}

- (void)fetchData {
    NSError *error = nil;
    self.fetchedResultsController = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    if (!success) {
        NSLog(@"Error in fetching: %@", error.userInfo);
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController == nil) {
        AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = delegate.dataAccessManager.managedObjectContext;
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:[NSEntityDescription entityForName:@"Penalty"
                                     inManagedObjectContext:context]];
        
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"profile = %@", delegate.lastSignProfile]];
        
        NSSortDescriptor *statusSort = [[NSSortDescriptor alloc] initWithKey:@"status" ascending:YES];
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        [fetch setSortDescriptors:[NSArray arrayWithObjects:statusSort, sortDescriptor, nil]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetch
                                     managedObjectContext:context
                                     sectionNameKeyPath:@"status" cacheName:nil];
        _fetchedResultsController.delegate = self;
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self.tableView endUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	switch (type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
            
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	UITableView *tableView = self.tableView;
    
	switch (type) {
		case NSFetchedResultsChangeInsert:
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
            
		case NSFetchedResultsChangeDelete:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
            
		case NSFetchedResultsChangeUpdate:
            
            break;
            
		case NSFetchedResultsChangeMove:
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
			[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
			break;
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [self fetchData];
    [super viewWillAppear:animated];
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    AppDelegate *delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    Profile *profile = delegate.lastSignProfile;
    if (profile.profileName && profile.profileName.length > 0)
    {
        [self.navigationItem setTitle:profile.profileName];
    }
    else
    {
        [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ %@", [profile.name capitalizedString], [profile.lastname capitalizedString]]];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.spinner startAnimating];
    self.informLabel.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleFinishLoading) name:@"LoadingEnd"
                                               object:nil];
    
    AppDelegate *delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    [delegate.updater syncProfile:delegate.lastSignProfile];
}

- (void) handleFinishLoading
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"LoadingEnd"
                                                  object:nil];
    
    [self.spinner stopAnimating];
    self.informLabel.hidden = NO;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:(NSUInteger) section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *penaltyCellId = @"penaltyCell";

    CPenaltyCell *cell = (CPenaltyCell *)[tableView dequeueReusableCellWithIdentifier:penaltyCellId];
    [cell configureCellWithPenalty:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ([[self.fetchedResultsController sections] count] > 0)
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
        headerLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:12.0];
        
        [headerView addSubview:headerLabel];
        
        return headerView;
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ([[self.fetchedResultsController sections] count] > 0) ? 28.0 : 0;
}
/*
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
*/

@end
