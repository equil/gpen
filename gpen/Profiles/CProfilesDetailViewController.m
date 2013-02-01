//
//  CProfilesDetailViewController.m
//  gpen
//
//  Created by fredformout on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CProfilesDetailViewController.h"
#import "AppDelegate.h"
#import "CTextFieldCell.h"
#import "CTextFieldWithLabel.h"
#import "CDisclosureCell.h"
#import "CUpdater.h"
#import "CDao.h"
#import "CDao+Profile.h"
#import "CLoginClientEntity.h"
#import "BSKeyboardControls.h"
#import "CProfilesListViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CProfilesDetailViewController ()<BSKeyboardControlsDelegate>
@property (nonatomic, weak) UITextField *activeTextField;
@property (nonatomic, strong) CLoginClientEntity *clientEntity;
@property (nonatomic, strong) NSDate *realBirthday;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation CProfilesDetailViewController

@synthesize profile = _profile;
@synthesize backButton = _backButton;
@synthesize editButton = _editButton;
@synthesize backupInfo = _backupInfo;
@synthesize clientTFName = _clientTFName;
@synthesize clientTFSurname = _clientTFSurname;
@synthesize clientTFPatronymic = _clientTFPatronymic;
@synthesize clientTFNickname = _clientTFNickname;
@synthesize clientTFLicense = _clientTFLicense;
@synthesize clientTFEmail = _clientTFEmail;
@synthesize clientTFBirthday = _clientTFBirthday;
@synthesize activeTextField = _activeTextField;
@synthesize pickerView = _pickerView;
@synthesize dateFormatter = _dateFormatter;
@synthesize serverFormatter = _serverFormatter;
@synthesize clientEntity = _clientEntity;
@synthesize realBirthday = _realBirthday;
@synthesize keyboardControls = _keyboardControls;
@synthesize labelEmail = _labelEmail;
@synthesize buttonMakeMain = _buttonMakeMain;
@synthesize buttonDelete = _buttonDelete;
@synthesize spinner = _spinner;


- (void)scrollViewToTextField:(id)textField
{
    UITableViewCell *cell = (UITableViewCell *) ((UIView *) textField).superview.superview;
    [self.tableView scrollRectToVisible:cell.frame animated:YES];
}

#pragma mark -
#pragma mark BSKeyboardControls Delegate

/*
 * The "Done" button was pressed
 * We want to close the keyboard
 */
- (void)keyboardControlsDonePressed:(BSKeyboardControls *)controls
{
    [controls.activeTextField resignFirstResponder];
}

/* Either "Previous" or "Next" was pressed
 * Here we usually want to scroll the view to the active text field
 * If we want to know which of the two was pressed, we can use the "direction" which will have one of the following values:
 * KeyboardControlsDirectionPrevious        "Previous" was pressed
 * KeyboardControlsDirectionNext            "Next" was pressed
 */
- (void)keyboardControlsPreviousNextPressed:(BSKeyboardControls *)controls withDirection:(KeyboardControlsDirection)direction andActiveTextField:(id)textField
{
    [self scrollViewToTextField:textField];
    
    [self performSelector:@selector(becomeResponder:) withObject:textField afterDelay:0.1];
    [textField becomeFirstResponder];
}

- (void) becomeResponder: (id) textField
{
    [textField becomeFirstResponder];
}

#pragma mark - Text Field Delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger maxLength = 255;
    /*if ([textField isEqual:self.clientTFLicense])
    {
        maxLength = 10;
    }*/
    if ([textField isEqual:self.clientTFBirthday])
    {
        maxLength = 0;
    }
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= maxLength || returnKey;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([self.keyboardControls.textFields containsObject:textField])
        self.keyboardControls.activeTextField = textField;
    self.activeTextField = textField;
    [self scrollViewToTextField:textField];
    
    /*if ([textField isEqual:self.clientTFLicense])
    {
        NSMutableString *result = [[NSMutableString alloc] initWithString:textField.text];
        [result replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [result length])];
        textField.text = result;
    }
    else */
    if ([textField isEqual:self.clientTFBirthday])
    {
        if (!self.realBirthday)
        {
            self.realBirthday = [NSDate date];
        }
        self.pickerView.date = self.realBirthday;
        self.clientTFBirthday.text = [self.dateFormatter stringFromDate:self.realBirthday];
        self.clientEntity.birthday = [self.serverFormatter stringFromDate:self.realBirthday];
        [self checkInputData];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
    
    if ([textField isEqual:self.clientTFName])
    {
        self.clientEntity.name = textField.text;
    }
    else if ([textField isEqual:self.clientTFSurname])
    {
        self.clientEntity.surname = textField.text;
    }
    else if ([textField isEqual:self.clientTFPatronymic])
    {
        self.clientEntity.patronymic = textField.text;
    }
    else if ([textField isEqual:self.clientTFNickname])
    {
        self.clientEntity.nickname = textField.text;
    }
    else if ([textField isEqual:self.clientTFLicense])
    {
        /*self.clientEntity.license = textField.text;
        textField.text = [self spacedLicenseString:textField.text];*/
        self.clientEntity.license = textField.text;
    }
    else if ([textField isEqual:self.clientTFEmail])
    {
        self.clientEntity.email = textField.text;
    }
    else if ([textField isEqual:self.clientTFBirthday])
    {
        NSDate *date = [self.dateFormatter dateFromString:self.clientTFBirthday.text];
        self.realBirthday = date;
        if (date)
        {
            self.clientEntity.birthday = [self.serverFormatter stringFromDate:date];
        }
        else
        {
            self.clientEntity.birthday = @"";
        }
    }
}
/*
- (NSString *) spacedLicenseString: (NSString *) aString
{
    if (!aString)
    {
        return nil;
    }
    NSMutableString *result = [[NSMutableString alloc] initWithString:aString];
    if (result.length == 10) {
        [result insertString:@" " atIndex:4];
        [result insertString:@" " atIndex:2];
    }
    return result;
}
*/
- (IBAction) checkInputData
{
    self.labelEmail.hidden = ([self.clientTFEmail.text length] > 0);
    
    if (editingMode)
    {
        if (([self.clientTFName.text length] > 0) &&
            ([self.clientTFSurname.text length] > 0) &&
            ([self.clientTFPatronymic.text length] > 0) &&
            ([self.clientTFLicense.text length] > 0) &&
            ([self.clientTFBirthday.text length] > 0))
        {
            _editButton.enabled = YES;
        }
        else
        {
            _editButton.enabled = NO;
        }
    }
}

- (void)checkAndSetProfileName
{
    if (self.profile.profileName && self.profile.profileName.length > 0)
    {
        self.navigationItem.title = self.profile.profileName;
        _editButton.hidden = NO;
    }
    else if ((self.profile.name && self.profile.name.length > 0) && (self.profile.lastname && self.profile.lastname.length > 0))
    {
        self.navigationItem.title = [NSString stringWithFormat:@"%@ %@", [self.profile.name capitalizedString], [self.profile.lastname capitalizedString]];
        _editButton.hidden = NO;
    }
    else
    {
        self.navigationItem.title = @"";
        _editButton.hidden = YES;
    }
}

- (void)profileSelectionChanged:(Profile *)profile
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    [self loadInfoFromProfile:profile];
}

- (void) loadInfoFromProfile: (Profile *) profile
{
    [self cancelEdit];
    
    self.profile = profile;
    
    [self checkAndSetProfileName];
    
    editingMode = NO;
    
    self.clientEntity = [[CLoginClientEntity alloc] initWithProfile:self.profile];
    self.realBirthday = [self.serverFormatter dateFromString:self.clientEntity.birthday];
    
    [self.tableView reloadData];
    
    if (self.realBirthday)
    {
        self.clientTFBirthday.text = [self.dateFormatter stringFromDate:self.realBirthday];
    }
    else
    {
        self.clientTFBirthday.text = @"";
    }
    self.clientTFEmail.text = self.clientEntity.email;
    self.clientTFSurname.text = self.clientEntity.surname;
    self.clientTFName.text = self.clientEntity.name;
    self.clientTFPatronymic.text = self.clientEntity.patronymic;
    self.clientTFNickname.text = self.clientEntity.nickname;
    self.clientTFLicense.text = self.clientEntity.license;//[self spacedLicenseString: self.clientEntity.license];
    
    [self checkInputData];
    [self disableAllFields];
    self.buttonDelete.hidden = YES;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.buttonMakeMain.hidden = [self.profile isEqual:delegate.lastSignProfile];
    delegate.stateHolder.currentProfile = self.profile;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    ((CProfilesListViewController*)[((UINavigationController*)[self.splitViewController.viewControllers objectAtIndex:0]).viewControllers lastObject]).selectionDelegate = self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
	self.dateFormatter = [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateFormat:@"dd.MM.yyyy"];
    self.serverFormatter = [[NSDateFormatter alloc] init];
    [self.serverFormatter setDateFormat:@"yyyy-MM-dd"];
    
    // Initialize the keyboard controls
    self.keyboardControls = [[BSKeyboardControls alloc] init];
    
    // Set the delegate of the keyboard controls
    self.keyboardControls.delegate = self;
    
    self.keyboardControls.previousTitle = @"Назад";
    self.keyboardControls.nextTitle = @"Вперед";
    self.keyboardControls.doneTitle = @"Готово";
    
    // Add all text fields you want to be able to skip between to the keyboard controls
    // The order of thise text fields are important. The order is used when pressing "Previous" or "Next"
    self.keyboardControls.textFields = [[NSArray alloc] initWithObjects:self.clientTFSurname,
                                        self.clientTFName,
                                        self.clientTFPatronymic,
                                        self.clientTFNickname,
                                        self.clientTFBirthday,
                                        self.clientTFLicense,
                                        self.clientTFEmail, nil];
    
    // Add the keyboard control as accessory view for all of the text fields
    // Also set the delegate of all the text fields to self
    [self.keyboardControls reloadTextFields];
    
    
    self.pickerView = [[UIDatePicker alloc] init];
    self.pickerView.datePickerMode = UIDatePickerModeDate;
    self.pickerView.locale = [NSLocale currentLocale];
    self.pickerView.calendar = [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
    //self.pickerView.maximumDate = [NSDate date];
    [self.pickerView addTarget:self
                        action:@selector(dateAction)
              forControlEvents:UIControlEventValueChanged];
    self.clientTFBirthday.inputView = self.pickerView;
    self.clientTFBirthday.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    
    self.clientTFEmail.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    self.labelEmail.text = @"Необязательно";
    self.labelEmail.font = [UIFont fontWithName:@"PTSans-Regular" size:14.0];
    
    self.clientTFSurname.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    self.clientTFName.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    self.clientTFPatronymic.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    self.clientTFNickname.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    self.clientTFLicense.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    
    [self loadInfoFromProfile:self.profile];
}

- (void) disableAllFields
{
    self.clientTFBirthday.userInteractionEnabled = NO;
    self.clientTFSurname.userInteractionEnabled = NO;
    self.clientTFName.userInteractionEnabled = NO;
    self.clientTFPatronymic.userInteractionEnabled = NO;
    self.clientTFNickname.userInteractionEnabled = NO;
    self.clientTFLicense.userInteractionEnabled = NO;
    self.clientTFEmail.userInteractionEnabled = NO;
}

- (void) enableAllFields
{
    self.clientTFBirthday.userInteractionEnabled = YES;
    self.clientTFSurname.userInteractionEnabled = YES;
    self.clientTFName.userInteractionEnabled = YES;
    self.clientTFPatronymic.userInteractionEnabled = YES;
    self.clientTFNickname.userInteractionEnabled = YES;
    self.clientTFLicense.userInteractionEnabled = YES;
    self.clientTFEmail.userInteractionEnabled = YES;
}

#pragma mark - Table View Data Source

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50.0)];
        footerView.backgroundColor = [UIColor clearColor];
        
        CGRect footerLabelFrame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            footerLabelFrame = CGRectMake(35, 0, footerView.frame.size.width - 70, 40);
        }
        else
        {
            footerLabelFrame = CGRectMake(18, 0, footerView.frame.size.width - 36, 40);
        }
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:footerLabelFrame];
        footerLabel.numberOfLines = 2;
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.text = @"По умолчанию будут использоваться имя\nи фамилия, указанные в профиле";
        footerLabel.textColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
        footerLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:14.0];
        footerLabel.shadowColor = [UIColor whiteColor];
        footerLabel.shadowOffset = CGSizeMake(0, 1);
        footerLabel.layer.shadowRadius = 1.0;
        
        [footerView addSubview:footerLabel];
        
        return footerView;
    }
    else if (section == 3)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        footerView.backgroundColor = [UIColor clearColor];
        
        CGRect footerLabelFrame;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            footerLabelFrame = CGRectMake(35, 0, footerView.frame.size.width - 70, 20);
        }
        else
        {
            footerLabelFrame = CGRectMake(18, 0, footerView.frame.size.width - 36, 20);
        }
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:footerLabelFrame];
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.text = @"Образец: 63 СТ 000000";
        footerLabel.textColor = [UIColor colorWithRed:60.0/255.0 green:60.0/255.0 blue:60.0/255.0 alpha:1.0];
        footerLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:14.0];
        footerLabel.shadowColor = [UIColor whiteColor];
        footerLabel.shadowOffset = CGSizeMake(0, 1);
        
        [footerView addSubview:footerLabel];
        
        return footerView;
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 50.0;
    }
    else if (section == 3)
    {
        return 30.0;
    }
    return 0.0;
}

- (void)dateAction
{
    self.realBirthday = self.pickerView.date;
	self.clientTFBirthday.text = [self.dateFormatter stringFromDate:self.realBirthday];
	self.clientEntity.birthday = [self.serverFormatter stringFromDate:self.realBirthday];
    
    [self checkInputData];
}

- (BOOL) validateEmail: (NSString *) candidate
{
    /*
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
     */
    return YES;
}

- (IBAction)cancelAction
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)editAction
{
    if (editingMode == NO)
    {
        [self fillBackUp];//сохранение в бэкап
        
        [self enableAllFields];
        
        self.buttonDelete.hidden = NO;
        self.buttonMakeMain.hidden = YES;
        
        [_backButton setImage:[UIImage imageNamed:@"cancel-for-nav.png"] forState:UIControlStateNormal];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            [_backButton setHidden:NO];
        }
        
        [_editButton setImage:[UIImage imageNamed:@"done-for-nav.png"] forState:UIControlStateNormal];
        
        editingMode = YES;
    }
    else
    {
        [self.activeTextField resignFirstResponder];
        
        if (!(self.clientEntity.email) || (self.clientEntity.email.length < 1) || ([self validateEmail:self.clientEntity.email]))
        {
            [self doRequest];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Некорректный e-mail" message:nil delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void) doRequest
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:self.clientEntity.license];
    [result replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [result length])];
    self.clientEntity.license = result;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishEditProfile) name:@"EditProfileEnd" object:nil];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    dispatch_async(delegate.dispatcher.dataUpdateQueue, ^{
        [delegate.updater editProfile:_profile data:self.clientEntity.dict];
    });
}

- (void) handleFinishEditProfile
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"EditProfileEnd" object:nil];
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [_backButton setHidden:YES];
    }
    
    [_backButton setImage:[UIImage imageNamed:@"back-for-nav.png"] forState:UIControlStateNormal];
    
    [_editButton setImage:[UIImage imageNamed:@"edit-for-nav.png"] forState:UIControlStateNormal];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CDao *dao = [CDao daoWithContext:delegate.dataAccessManager.managedObjectContext];
    _profile = [dao profileForUid:_profile.uid];
    
    delegate.updated = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProfileList"
                                                        object:nil];
    [self checkAndSetProfileName];
    
    [self disableAllFields];
    
    self.backupInfo = nil;
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    
    self.buttonDelete.hidden = YES;
    self.buttonMakeMain.hidden = [self.profile isEqual:delegate.lastSignProfile];
    
    editingMode = NO;
}

- (IBAction)goBack
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self cancelEdit];
    }
    else
    {
        if (editingMode == YES)
        {
            [self cancelEdit];
        }
        else
        {
            [super goBack];
        }
    }
}

- (void) cancelEdit
{
    [self.activeTextField resignFirstResponder];
    [self disableAllFields];
    
    [self fillFields];//восстановление данных из бэкапа
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [_backButton setHidden:YES];
    }
    
    [_backButton setImage:[UIImage imageNamed:@"back-for-nav.png"] forState:UIControlStateNormal];
    
    [_editButton setImage:[UIImage imageNamed:@"edit-for-nav.png"] forState:UIControlStateNormal];
    
    self.backupInfo = nil;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.buttonDelete.hidden = YES;
    self.buttonMakeMain.hidden = [self.profile isEqual:delegate.lastSignProfile];
    
    editingMode = NO;
}

- (void)fillBackUp
{
    self.backupInfo = [[CLoginClientEntity alloc] initWithProfile:self.profile];
}

- (void)fillFields
{
    if (self.backupInfo)
    {
        self.clientTFBirthday.text = [self.dateFormatter stringFromDate:[self.serverFormatter dateFromString:self.backupInfo.birthday]];
        self.clientTFEmail.text = self.backupInfo.email;
        self.clientTFSurname.text = self.backupInfo.surname;
        self.clientTFName.text = self.backupInfo.name;
        self.clientTFPatronymic.text = self.backupInfo.patronymic;
        self.clientTFNickname.text = self.backupInfo.nickname;
        self.clientTFLicense.text = self.clientEntity.license;//[self spacedLicenseString: self.backupInfo.license];
    }
    
    [self checkInputData];
}

// действие для кнопки СДЕЛАТЬ ГЛАВНЫМ
- (IBAction)makeMain
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishMakeMain) name:@"LastSignUpdateEnd" object:nil];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.updater updateLastSignForProfile:_profile];
}

- (void) handleFinishMakeMain
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LastSignUpdateEnd" object:nil];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.stateHolder.currentProfile = self.profile;
    delegate.stateHolder.currentPenalty = nil;
    delegate.updated = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProfileList"
                                                        object:nil];
    [self goBack];
}

// действие для кнопки УДАЛИТЬ ПРОФИЛЬ
- (IBAction)deleteProfile
{
    UIAlertView* dialog = [[UIAlertView alloc] init];
    [dialog setDelegate:self];
    [dialog setTitle:@"Внимание"];
    [dialog setMessage:@"Удалить данный профиль?"];
    [dialog addButtonWithTitle:@"Да"];
    [dialog addButtonWithTitle:@"Нет"];
    [dialog show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeleteProfile) name:@"DeletingEnd" object:nil];
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.updater deleteProfile:_profile];
        delegate.stateHolder.currentPenalty = nil;
        editingMode = NO;
    }
}

- (void) handleDeleteProfile
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"DeletingEnd" object:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateProfileList"
                                                        object:nil];
    [self goBack];
}

@end
