//
//  CProfilesListViewController.m
//  gpen
//
//  Created by fredformout on 02.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CProfilesListViewController.h"
#import "CProfilesDetailViewController.h"
#import "CProfilesAddViewController.h"
#import "AppDelegate.h"
#import "CProfileCell.h"
#import "CDao+Profile.h"

@interface CProfilesListViewController ()
@property(nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@end

@implementation CProfilesListViewController
{
@private
    NSFetchedResultsController *_fetchedResultsController;
}
@synthesize selectionDelegate = _selectionDelegate;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"ProfilesListToDetail"]) {
        CProfilesDetailViewController *destination = segue.destinationViewController;
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        destination.profile = [self.fetchedResultsController objectAtIndexPath:path];
    }
}

- (void)fetchData {
    NSError *error = nil;
    self.fetchedResultsController = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
    [self performSelector:@selector(selectRow) withObject:nil afterDelay:0.0f];
    //[self selectRow];
    if (!success) {
        NSLog(@"Error in fetching: %@", error.userInfo);
    }
}

- (void) selectRow
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        Profile *currentProfile = delegate.stateHolder.currentProfile;
        NSIndexPath *currentProfileIndex = [self.fetchedResultsController indexPathForObject:currentProfile];
        
        NSLog(@"current profile index row = %i", currentProfileIndex.row);
        if (currentProfileIndex)
        {
            [self.tableView selectRowAtIndexPath:currentProfileIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self.selectionDelegate profileSelectionChanged:[self.fetchedResultsController objectAtIndexPath:currentProfileIndex]];
            return;
        }
        if ([self.fetchedResultsController.fetchedObjects count] > 0)
        {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self.selectionDelegate profileSelectionChanged:[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
            return;
        }
        
        [self.selectionDelegate profileSelectionChanged:nil];
    }
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController == nil) {
        AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = delegate.dataAccessManager.managedObjectContext;
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:[NSEntityDescription entityForName:@"Profile"
                                     inManagedObjectContext:context]];
        
        NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"uid" ascending:YES];
        NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"license" ascending:YES];
        
        [fetch setSortDescriptors:[NSArray arrayWithObjects:sd, sd2, nil]];
        
        _fetchedResultsController = [[NSFetchedResultsController alloc]
                                     initWithFetchRequest:fetch
                                     managedObjectContext:context
                                     sectionNameKeyPath:@"uid" cacheName:nil];
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
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    
    [CNavigationBarCustomer customizeNavTitle:@"Профили" navItem:self.navigationItem];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData)
                                                 name:@"updateProfileList"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushNotification) name:@"pushNotification" object:nil];
    
    [self putProfileBadgeToTabBarAndReloadTable];
}

- (void) putProfileBadgeToTabBarAndReloadTable
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    CDao *dao = [CDao daoWithContext:delegate.dataAccessManager.managedObjectContext];
    unsigned long penalties = [dao penaltiesCountForProfilesExceptLastSign];
    if (penalties > 0)
    {
        [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:@"!"];
    }
    else
    {
        [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:nil];
    }
    
    [self fetchData];
}

- (void)handlePushNotification
{
    [self putProfileBadgeToTabBarAndReloadTable];
}

- (void) reloadData
{
    [self fetchData];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"updateProfileList"
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pushNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [self fetchData];
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
    {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
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
    static NSString *profileCellId = @"profileCell";
    
    CProfileCell *cell = (CProfileCell *)[tableView dequeueReusableCellWithIdentifier:profileCellId];
    [cell configureCellWithProfile:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectionDelegate profileSelectionChanged:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

@end
