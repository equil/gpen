//
//  CPenaltyTicketViewController.h
//  gpen
//
//  Created by fredformout on 02.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Penalty.h"

@interface CPenaltyTicketViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) Penalty *penalty;

@end
