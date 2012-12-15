//
//  CPenaltyListViewController.h
//  gpen
//
//  Created by Ilya Khokhlov on 01.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "CRotateViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface CPenaltyListViewController : CRotateViewController <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, EGORefreshTableHeaderDelegate>
{
    BOOL reloading;
}

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UILabel *informLabel;
@property (nonatomic, strong) EGORefreshTableHeaderView *refreshHeaderView;

@end
