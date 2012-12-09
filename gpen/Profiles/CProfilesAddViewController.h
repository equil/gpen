//
//  CProfilesAddViewController.h
//  gpen
//
//  Created by fredformout on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CRotateTableViewController.h"

@interface CProfilesAddViewController : CRotateTableViewController <UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITableView *loginTableView;

@property (nonatomic, strong) UIDatePicker *pickerView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *serverFormatter;

@property (nonatomic, strong) IBOutlet UITextField *clientTFName;
@property (nonatomic, strong) IBOutlet UITextField *clientTFSurname;
@property (nonatomic, strong) IBOutlet UITextField *clientTFPatronymic;
@property (nonatomic, strong) IBOutlet UITextField *clientTFNickname;
@property (nonatomic, strong) IBOutlet UITextField *clientTFLicense;
@property (nonatomic, strong) IBOutlet UITextField *clientTFEmail;
@property (nonatomic, strong) IBOutlet UILabel *labelEmail;
@property (nonatomic, strong) IBOutlet UITextField *clientTFBirthday;

- (void)dateAction;
- (IBAction)checkInputData;
- (IBAction)cancelAction;
- (IBAction)saveAction;

@end
