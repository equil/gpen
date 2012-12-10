//
//  CProfilesAddViewController.m
//  gpen
//
//  Created by fredformout on 04.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CProfilesAddViewController.h"
#import "AppDelegate.h"
#import "CTextFieldCell.h"
#import "CTextFieldWithLabel.h"
#import "CDisclosureCell.h"
#import "AppDelegate.h"
#import "CUpdater.h"
#import "CDao.h"
#import "CDao+Profile.h"
#import "CLoginClientEntity.h"
#import "BSKeyboardControls.h"

@interface CProfilesAddViewController () <BSKeyboardControlsDelegate>
@property (nonatomic, weak) UITextField *activeTextField;
@property (nonatomic, strong) CLoginClientEntity *clientEntity;
@property (nonatomic, strong) NSDate *realBirthday;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@end

@implementation CProfilesAddViewController
@synthesize loginTableView = _loginTableView;
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
    if ([textField isEqual:self.clientTFLicense])
    {
        maxLength = 10;
    }
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
    
    if ([textField isEqual:self.clientTFLicense])
    {
        NSMutableString *result = [[NSMutableString alloc] initWithString:textField.text];
        [result replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [result length])];
        textField.text = result;
    }
    else if ([textField isEqual:self.clientTFBirthday])
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
        self.clientEntity.license = textField.text;
        textField.text = [self spacedLicenseString:textField.text];
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

- (IBAction) checkInputData
{
    if (([self.clientTFName.text length] > 0) &&
        ([self.clientTFSurname.text length] > 0) &&
        ([self.clientTFPatronymic.text length] > 0) &&
        ([self.clientTFLicense.text length] > 0) &&
        ([self.clientTFBirthday.text length] > 0))
    {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    else
    {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.clientEntity = [[CLoginClientEntity alloc] init];
    
    self.navigationItem.title = @"Заполните анкету";
    
    self.loginTableView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:225.0/255.0 alpha:1.0];
    
	self.dateFormatter = [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateFormat:@"dd.MM.yyyy"];
    self.serverFormatter = [[NSDateFormatter alloc] init];
    [self.serverFormatter setDateFormat:@"yyyy-MM-dd"];
    
    [self.loginTableView reloadData];
    
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
    
    if (self.realBirthday)
    {
        self.clientTFBirthday.text = [self.dateFormatter stringFromDate:self.realBirthday];
    }
    self.pickerView = [[UIDatePicker alloc] init];
    self.pickerView.datePickerMode = UIDatePickerModeDate;
    self.pickerView.locale = [NSLocale currentLocale];
    self.pickerView.calendar = [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
    self.pickerView.maximumDate = [NSDate date];
    [self.pickerView addTarget:self
                        action:@selector(dateAction)
              forControlEvents:UIControlEventValueChanged];
    self.clientTFBirthday.inputView = self.pickerView;
    self.clientTFBirthday.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    
    self.clientTFEmail.text = self.clientEntity.email;
    self.clientTFEmail.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    self.labelEmail.text = @"Необязательно";
    self.labelEmail.font = [UIFont fontWithName:@"PTSans-Regular" size:14.0];
    
    self.clientTFSurname.text = self.clientEntity.surname;
    self.clientTFSurname.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    
    self.clientTFName.text = self.clientEntity.name;
    self.clientTFName.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    
    self.clientTFPatronymic.text = self.clientEntity.patronymic;
    self.clientTFPatronymic.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    
    self.clientTFNickname.text = self.clientEntity.nickname;
    self.clientTFNickname.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    
    self.clientTFLicense.text = self.clientEntity.license;
    self.clientTFLicense.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    
    [self checkInputData];
}

#pragma mark - Table View Data Source

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 1)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
        footerView.backgroundColor = [UIColor clearColor];
        
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, footerView.frame.size.width - 36, 40)];
        footerLabel.numberOfLines = 2;
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.text = @"По умолчанию будут использоваться имя и фамилия, указанные в профиле";
        footerLabel.textColor = [UIColor darkGrayColor];
        footerLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:14.0];
        footerLabel.shadowColor = [UIColor whiteColor];
        footerLabel.shadowOffset = CGSizeMake(0, 1);
        
        [footerView addSubview:footerLabel];
        
        return footerView;
    }
    else if (section == 3)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        footerView.backgroundColor = [UIColor clearColor];
        
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, footerView.frame.size.width - 36, 20)];
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.text = @"Образец: 63 СТ 000000";
        footerLabel.textColor = [UIColor darkGrayColor];
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
}

- (IBAction)cancelAction
{
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveAction
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

- (void) doRequest
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:self.clientEntity.license];
    [result replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [result length])];
    self.clientEntity.license = result;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    dispatch_async(delegate.dispatcher.dataUpdateQueue, ^{
        [delegate.updater insertProfile:self.clientEntity.dict];
        [self cancelAction];
    });
}

@end

