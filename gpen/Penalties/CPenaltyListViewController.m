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
#import "CDao+Profile.h"

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
@synthesize refreshHeaderView = _refreshHeaderView;
@synthesize selectionDelegate = _selectionDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"PenaltyListToDetail"]) {
        CPenaltyDetailViewController *destination = segue.destinationViewController;
        
        NSIndexPath *path = [self.tableView indexPathForSelectedRow];
        destination.penalty = [self.fetchedResultsController objectAtIndexPath:path];
    }
}

- (void)fetchData
{
    NSError *error = nil;
    self.fetchedResultsController = nil;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    [self.tableView reloadData];
    [self reloadNewPenaltyCount];
    [self selectRow];
    if (!success) {
        NSLog(@"Error in fetching: %@", error.userInfo);
    }
}

- (void)reloadNewPenaltyCount
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [delegate.updater setNewPenaltiesCountForLicense:delegate.lastSignProfile.license count:0];
    
    [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:nil];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController == nil) {
        AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = delegate.dataAccessManager.managedObjectContext;
        
        NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:[NSEntityDescription entityForName:@"Penalty"
                                     inManagedObjectContext:context]];
        
        [fetch setPredicate:[NSPredicate predicateWithFormat:@"%@ in profiles", delegate.lastSignProfile]];
        
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
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundView:[[UIView alloc] init]];
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:228.0/255.0 alpha:1.0f]];
    
    self.informLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:14.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePushNotification) name:@"pushNotification" object:nil];
    
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
	}
	
	[_refreshHeaderView refreshLastUpdatedDate];
    
    [self putPenaltiesCountToTabBar];
}

- (void) putPenaltiesCountToTabBar
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    unsigned long penalties = [delegate.lastSignProfile.newPenaltiesCount unsignedLongValue];
    if (penalties > 0)
    {
        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:[NSString stringWithFormat:@"%lu", penalties]];
    }
    else
    {
        [[self.tabBarController.tabBar.items objectAtIndex:0] setBadgeValue:nil];
    }
    
    CDao *dao = [CDao daoWithContext:delegate.dataAccessManager.managedObjectContext];
    unsigned long penaltiesExceptMain = [dao penaltiesCountForProfilesExceptLastSign];
    if (penaltiesExceptMain > 0)
    {
        [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:@"!"];
    }
    else
    {
        [[self.tabBarController.tabBar.items objectAtIndex:1] setBadgeValue:nil];
    }
}

- (void)handlePushNotification
{
    [self putPenaltiesCountToTabBar];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pushNotification" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.informLabel.hidden = YES;
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    Profile *profile = delegate.lastSignProfile;
    if (profile != nil)
    {
        [self fetchData];
        
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad)
        {
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        }
    
        if (profile.profileName && profile.profileName.length > 0)
        {
            self.navigationItem.title = profile.profileName;
        }
        else
        {
            self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", [profile.name capitalizedString], [profile.lastname capitalizedString]];
        }
    }
    else
    {
        self.navigationItem.title = @"Профилей нет";
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    AppDelegate *delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    Profile *profile = delegate.lastSignProfile;
    if (profile != nil)
    {
        if (delegate.updated == NO)
        {
            [self.spinner startAnimating];
            self.tableView.userInteractionEnabled = NO;
            self.informLabel.hidden = YES;
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(handleFinishLoading:) name:@"LoadingEnd"
                                                       object:nil];
            
            dispatch_async(delegate.dispatcher.dataUpdateQueue, ^{
                [delegate.updater syncProfile:delegate.lastSignProfile];
            });
        }
    }
    else
    {
        self.tableView.userInteractionEnabled = NO;
    }
}

- (void) handleFinishLoading: (NSNotification *) aNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"LoadingEnd"
                                                  object:nil];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (delegate.lastSignProfile.penalties.count > 0)
    {
        delegate.updated = YES;
        self.informLabel.hidden = YES;
        self.tableView.hidden = NO;
        [self fetchData];
        [delegate timerAction];
    }
    else
    {
        self.tableView.hidden = YES;
        self.informLabel.hidden = NO;
        
        NSString *status = [aNotification.userInfo objectForKey:@"status"];
        
        if ([@"INVALIDJSON" isEqualToString:status])
        {
            self.informLabel.text = @"Информация о штрафах этого профиля в данный момент недоступна.";
        }
        else if ([delegate.lastSignProfile.checked boolValue])
        {
            self.informLabel.text = @"Вы еще не получили ни единого штрафа от ГИБДД. Так держать! Если это когда-нибудь случится, приложение покажет всю информацию о нарушении и поможет оплатить штраф.";
        }
        else
        {
            if ([@"UNAVAILABLE" isEqualToString:status])
            {
                self.informLabel.text = @"Чтобы посмотреть свои штрафы, нужно подключиться к Интернету";
            }
            else
            {
                self.informLabel.text = @"Похоже, вы указали в профиле неточную информацию, ГИБДД не известен водитель с таким именем и номером водительского удостоверения. Вернитесь в \"Профили\" и проверьте указанную информацию.";
            }
        }
    }
    
    [self.spinner stopAnimating];
    self.tableView.userInteractionEnabled = YES;
    
    [self selectRow];
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
        
        Penalty *penalty = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
        if ([@"3_paid" isEqualToString:penalty.status])
        {
            headerLabel.text = @"Оплачено";
        }
        else if ([@"2_not paid" isEqualToString:penalty.status])
        {
            headerLabel.text = @"Не оплачено";
        }
        else if ([@"1_overdue" isEqualToString:penalty.status])
        {
            headerLabel.text = @"Просрочено";
        }
        headerLabel.textColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
        headerLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:12.0];
        headerLabel.shadowColor = [UIColor whiteColor];
        headerLabel.shadowOffset = CGSizeMake(0, 1);
        headerLabel.layer.shadowRadius = 1.0;
        
        [headerView addSubview:headerLabel];
        
        return headerView;
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ([[self.fetchedResultsController sections] count] > 0) ? 28.0 : 0;
}

-(void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
    [self.selectionDelegate penaltySelectionChanged:[self.fetchedResultsController objectAtIndexPath:indexPath]];
}

- (void)doneLoadingTableViewData
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:@"RefreshEnd"
                                                  object:nil];
    
    reloading = NO;
    
    [self fetchData];
    
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

- (void) selectRow
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        Penalty *currentPenalty = delegate.stateHolder.currentPenalty;
        NSIndexPath *currentPenaltyIndex = [self.fetchedResultsController indexPathForObject:currentPenalty];
        if (currentPenaltyIndex)
        {
            [self.tableView selectRowAtIndexPath:currentPenaltyIndex animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self.selectionDelegate penaltySelectionChanged:[self.fetchedResultsController objectAtIndexPath:currentPenaltyIndex]];
            return;
        }
        if ([self.fetchedResultsController.fetchedObjects count] > 0)
        {
            [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self.selectionDelegate penaltySelectionChanged:[self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]];
            return;
        }
        [self.selectionDelegate penaltySelectionChanged:nil];
    }
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(doneLoadingTableViewData) name:@"RefreshEnd"
                                               object:nil];
    reloading = YES;
    
    AppDelegate *delegate = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    dispatch_async(delegate.dispatcher.dataUpdateQueue, ^{
        [delegate.updater syncProfile:delegate.lastSignProfile];
    });
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([delegate.lastSignProfile.lastUpdate isEqualToDate:[NSDate distantPast]])
    {
        return nil;
    }
    else
    {
        return delegate.lastSignProfile.lastUpdate;
    }
}

@end
