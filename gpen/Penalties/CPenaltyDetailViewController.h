//
//  CPenaltyDetailViewController.h
//  gpen
//
//  Created by fredformout on 02.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Penalty.h"
#import "CRotateTableViewController.h"
#import "CGreenButton.h"

@interface CPenaltyDetailViewController : CRotateTableViewController <UITextFieldDelegate>

@property (nonatomic, strong) Penalty *penalty;

@property (nonatomic, strong) IBOutlet CGreenButton *buttonShowTicket;
@property (nonatomic, strong) IBOutlet UILabel *infoLabel;
@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet CGreenButton *buttonSendTicket;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *indicator;

- (IBAction) checkInputData;
- (IBAction)sendInfoToEmail;

@end
