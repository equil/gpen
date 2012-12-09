//
//  CLoginViewController.h
//  gpen
//
//  Created by fredformout on 25.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRotateTableViewController.h"
#import "CGreenButton.h"

@interface CLoginViewController : CRotateTableViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, strong) IBOutlet UITableView *loginTableView;
@property (nonatomic, strong) IBOutlet CGreenButton *continueButton;

@property (nonatomic, strong) UIDatePicker *pickerView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *serverFormatter;

@property (nonatomic, strong) IBOutlet UITextField *clientTFName;
@property (nonatomic, strong) IBOutlet UITextField *clientTFSurname;
@property (nonatomic, strong) IBOutlet UITextField *clientTFPatronymic;
@property (nonatomic, strong) IBOutlet UITextField *clientTFLicense;
@property (nonatomic, strong) IBOutlet UITextField *clientTFEmail;
@property (nonatomic, strong) IBOutlet UILabel *labelEmail;
@property (nonatomic, strong) IBOutlet UITextField *clientTFBirthday;

- (void)dateAction;
- (IBAction)checkInputData;
- (IBAction)insertNewProfile;

@end
