//
//  CLoginViewController.h
//  gpen
//
//  Created by fredformout on 25.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"

@interface CLoginViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UITableView *loginTableView;
@property (nonatomic, strong) IBOutlet UIButton *continueButton;
@property (nonatomic, strong) IBOutlet Profile *profile;

- (IBAction)updateProfile;

@end
