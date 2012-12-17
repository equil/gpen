//
//  CProfilesDetailViewController.h
//  gpen
//
//  Created by fredformout on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CRotateTableViewController.h"
#import "Profile.h"
#import "CLoginClientEntity.h"
#import "CGreenButton.h"
#import "CBlackButton.h"
#import "CProfileSelectionDelegate.h"

@interface CProfilesDetailViewController : CRotateTableViewController <UIAlertViewDelegate, CProfileSelectionDelegate>
{
    BOOL editingMode;
}

@property (nonatomic, strong) Profile *profile;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIButton *editButton;
@property (nonatomic, strong) CLoginClientEntity *backupInfo;

@property (nonatomic, strong) UIDatePicker *pickerView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSDateFormatter *serverFormatter;
@property (nonatomic, strong) IBOutlet CGreenButton *buttonMakeMain;
@property (nonatomic, strong) IBOutlet CBlackButton *buttonDelete;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *spinner;

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
- (IBAction)editAction;
- (IBAction)makeMain;
- (IBAction)deleteProfile;
- (IBAction)goBack;

@end
