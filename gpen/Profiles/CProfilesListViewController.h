//
//  CProfilesListViewController.h
//  gpen
//
//  Created by fredformout on 02.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CRotateTableViewController.h"
#import <CoreData/CoreData.h>
#import "CProfileSelectionDelegate.h"

@interface CProfilesListViewController : CRotateTableViewController <NSFetchedResultsControllerDelegate>

@property (nonatomic, weak) id<CProfileSelectionDelegate> selectionDelegate;

@end
