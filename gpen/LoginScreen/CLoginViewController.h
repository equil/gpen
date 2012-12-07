//
//  CLoginViewController.h
//  gpen
//
//  Created by fredformout on 25.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRotateViewController.h"
#import "CGreenButton.h"
#import "TPKeyboardAvoidingTableView.h"

@interface CLoginViewController : CRotateViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet TPKeyboardAvoidingTableView *loginTableView;
@property (nonatomic, strong) IBOutlet CGreenButton *continueButton;

@property (nonatomic, strong) UIDatePicker *pickerView;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *serverFormatter;

- (void)dateAction;

- (IBAction)insertNewProfile;

@end
