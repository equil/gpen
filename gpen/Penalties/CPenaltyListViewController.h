//
//  CPenaltyListViewController.h
//  gpen
//
//  Created by Ilya Khokhlov on 01.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface CPenaltyListViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property(nonatomic, retain, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSArray *dataSource;

@end
