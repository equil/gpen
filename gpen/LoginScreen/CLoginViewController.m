//
//  CLoginViewController.m
//  gpen
//
//  Created by fredformout on 25.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CLoginViewController.h"
#import "CTextFieldCell.h"
#import "CTextFieldWithLabel.h"
#import "CDisclosureCell.h"
#import "AppDelegate.h"
#import "CUpdater.h"
#import "CDao.h"
#import "CDao+Profile.h"
#import "CLoginClientEntity.h"

@interface CLoginViewController ()
@property (nonatomic, strong) UITextField *clientTFName;
@property (nonatomic, strong) UITextField *clientTFSurname;
@property (nonatomic, strong) UITextField *clientTFPatronymic;
@property (nonatomic, strong) UITextField *clientTFLicense;
@property (nonatomic, strong) UITextField *clientTFEmail;
@property (nonatomic, strong) UILabel *clientLBBirthday;
@property (nonatomic, weak) UITextField *activeTextField;
@property (nonatomic, retain) CLoginClientEntity *clientEntity;
@end

@implementation CLoginViewController
@synthesize navItem = _navItem;
@synthesize spinner = _spinner;
@synthesize loginTableView = _loginTableView;
@synthesize continueButton = _continueButton;
@synthesize clientTFName = _clientTFName;
@synthesize clientTFSurname = _clientTFSurname;
@synthesize clientTFPatronymic = _clientTFPatronymic;
@synthesize clientTFLicense = _clientTFLicense;
@synthesize clientTFEmail = _clientTFEmail;
@synthesize clientLBBirthday = _clientLBBirthday;
@synthesize activeTextField = _activeTextField;
@synthesize pickerView = _pickerView;
@synthesize doneButton = _doneButton;
@synthesize dateFormatter = _dateFormatter;
@synthesize clientEntity = _clientEntity;

#pragma mark - Text Field Delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField.returnKeyType == UIReturnKeyNext)
    {
        if ([textField isEqual:self.clientTFSurname])
        {
            [self.clientTFName becomeFirstResponder];
        }
        else if ([textField isEqual:self.clientTFName])
        {
            [self.clientTFPatronymic becomeFirstResponder];
        }
        else if ([textField isEqual:self.clientTFPatronymic])
        {
            [self showPickerFromCell:(CDisclosureCell *)[self.loginTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]]];
            return YES;
        }
        else if ([textField isEqual:self.clientTFLicense])
        {
            [self.clientTFEmail becomeFirstResponder];
        }
        return NO;
    }
    /*else
    {
        if ([textField isEqual:self.clientTFEmail]) {
            [self insertNewProfile];
        }
    }*/
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSInteger maxLength = 255;
    if ([textField isEqual:self.clientTFLicense])
    {
        maxLength = 10;
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
    [self doneAction];
    self.activeTextField = textField;
    
    if ([textField isEqual:self.clientTFLicense])
    {
        NSMutableString *result = [[NSMutableString alloc] initWithString:textField.text];
        [result replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [result length])];
        textField.text = result;
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
    else if ([textField isEqual:self.clientTFLicense])
    {
        self.clientEntity.license = textField.text;
        NSMutableString *result = [[NSMutableString alloc] initWithString:textField.text];
        if (result.length == 10) {
            [result insertString:@" " atIndex:4];
            [result insertString:@" " atIndex:2];
        }
        textField.text = result;
        self.clientEntity.license = textField.text;
    }
    else if ([textField isEqual:self.clientTFEmail])
    {
        self.clientEntity.email = textField.text;
    }
}

- (void) checkInputData
{
    NSDate *birthDate = [self.dateFormatter dateFromString:self.clientLBBirthday.text];
    if (([self.clientTFName.text length] > 0) &&
        ([self.clientTFSurname.text length] > 0) &&
        ([self.clientTFPatronymic.text length] > 0) &&
        ([self.clientTFLicense.text length] > 0) &&
        (birthDate))
    {
        self.continueButton.enabled = YES;
    }
    else
    {
        self.continueButton.enabled = NO;
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.clientEntity = [[CLoginClientEntity alloc] init];
    
    self.continueButton.enabled = NO;
    
    self.navItem.title = @"Заполните анкету";
    
    self.loginTableView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:225.0/255.0 alpha:1.0];
    
	self.dateFormatter = [[NSDateFormatter alloc] init];
	[self.dateFormatter setDateFormat:@"dd.MM.yyyy"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Register notification when the keyboard will be show
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    // Register notification when the keyboard will be hide
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(void) keyboardWillShow:(NSNotification *)note
{
    // Get the keyboard size
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    
    // Detect orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.loginTableView.frame;
    
    // Reduce size of the Table view
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        frame.size.height -= keyboardBounds.size.height;
    else
        frame.size.height -= keyboardBounds.size.width;
    
    // Start animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    // Apply new size of table view
    self.loginTableView.frame = frame;
    
    // Scroll the table view to see the TextField just above the keyboard
    if (self.activeTextField)
    {
        CGRect textFieldRect = [self.loginTableView convertRect:self.activeTextField.bounds fromView:self.activeTextField];
        [self.loginTableView scrollRectToVisible:textFieldRect animated:NO];
    }
    
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    // Get the keyboard size
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    
    // Detect orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.loginTableView.frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    // Reduce size of the Table view
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        frame.size.height += keyboardBounds.size.height;
    else
        frame.size.height += keyboardBounds.size.width;
    
    // Apply new size of table view
    self.loginTableView.frame = frame;
    
    [UIView commitAnimations];
}

#pragma mark - Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 3;
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *textFieldCellId = @"textFieldCell";
    static NSString *textFieldWithLabelCellId = @"textFieldWithLabelCell";
    static NSString *disclosureCellId = @"disclosureCell";
    
    // Ячейка со стрелкой - единственная в таблице
    if (indexPath.section == 1)
    {
        CDisclosureCell *cell = (CDisclosureCell *) [tableView dequeueReusableCellWithIdentifier:disclosureCellId];
        self.clientLBBirthday = cell.cellLabel;
        cell.cellLabel.text = @"Дата рождения";
        cell.cellLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
        return cell;
    }
    else if (indexPath.section == 3)
    {
        CTextFieldWithLabel *cell = (CTextFieldWithLabel *) [tableView dequeueReusableCellWithIdentifier:textFieldWithLabelCellId];
        cell.cellTextField.delegate = self;
        self.clientTFEmail = cell.cellTextField;
        cell.cellTextField.placeholder = @"Электронная почта";
        cell.cellTextField.returnKeyType = UIReturnKeyDefault;
        cell.cellTextField.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
        cell.cellLabel.text = @"Необязательно";
        cell.cellLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:14.0];
        
        [cell.cellTextField addTarget:self action:@selector(checkInputData) forControlEvents:UIControlEventEditingChanged];
        
        return cell;
    }
    
    // Остальные - с текстовыми полями
    CTextFieldCell *cell = (CTextFieldCell *) [tableView dequeueReusableCellWithIdentifier:textFieldCellId];
    cell.cellTextField.delegate = self;
    cell.cellTextField.returnKeyType = UIReturnKeyNext;
    [cell.cellTextField addTarget:self action:@selector(checkInputData) forControlEvents:UIControlEventEditingChanged];
    cell.cellTextField.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                    self.clientTFSurname = cell.cellTextField;
                    cell.cellTextField.placeholder = @"Фамилия";
                    break;
                case 1:
                    self.clientTFName = cell.cellTextField;
                    cell.cellTextField.placeholder = @"Имя";
                    break;
                case 2:
                    self.clientTFPatronymic = cell.cellTextField;
                    cell.cellTextField.placeholder = @"Отчество";
                    break;
            }
            break;
        }
        case 2:
        {
            self.clientTFLicense = cell.cellTextField;
            cell.cellTextField.placeholder = @"Номер водительского удостоверения";
            break;
        }
    }
            
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 2)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        footerView.backgroundColor = [UIColor clearColor];
        
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, footerView.frame.size.width - 36, 20)];
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.text = @"Образец: 63 СТ 000000";
        footerLabel.textColor = [UIColor darkGrayColor];
        footerLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:12.0];
        footerLabel.shadowColor = [UIColor whiteColor];
        footerLabel.shadowOffset = CGSizeMake(0, 1);
        
        [footerView addSubview:footerLabel];
        
        return footerView;
    }
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2)
    {
        return 30.0;
    }
    return 0.0;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1)
    {
        [self.activeTextField resignFirstResponder];
        
        CDisclosureCell *targetCell = (CDisclosureCell *) [tableView cellForRowAtIndexPath:indexPath];
        
        [self showPickerFromCell: targetCell];
    }
}

- (void) showPickerFromCell: (CDisclosureCell *) aTargetCell
{
    [self createDatePickerIfNeeded];
    
    NSDate *currentDate = [self.dateFormatter dateFromString:aTargetCell.cellLabel.text];
    if (currentDate)
    {
        self.pickerView.date = currentDate;
    }
    else
    {
        self.clientLBBirthday.text = [self.dateFormatter stringFromDate:[NSDate date]];
    }
    
    // check if our date picker is already on screen
    if (self.pickerView.superview == nil)
    {
        [self.view.window addSubview: self.pickerView];
        
        // size up the picker view to our screen and compute the start/end frame origin for our slide up animation
        //
        // compute the start frame
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGSize pickerSize = [self.pickerView sizeThatFits:CGSizeZero];
        CGRect startRect = CGRectMake(0.0,
                                      screenRect.origin.y + screenRect.size.height,
                                      pickerSize.width, pickerSize.height);
        self.pickerView.frame = startRect;
        
        // compute the end frame
        CGRect pickerRect = CGRectMake(0.0,
                                       screenRect.origin.y + screenRect.size.height - pickerSize.height,
                                       pickerSize.width,
                                       pickerSize.height);
        
        CGRect frame = self.loginTableView.frame;
        
        // start the slide up animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        
        self.pickerView.frame = pickerRect;
        
        frame.size.height -= pickerRect.size.height;
        // Apply new size of table view
        self.loginTableView.frame = frame;
        
        // Scroll the table view to see the TextField just above the keyboard
        if (self.clientLBBirthday)
        {
            CGRect textFieldRect = [self.loginTableView convertRect:self.clientLBBirthday.bounds fromView:self.clientLBBirthday];
            [self.loginTableView scrollRectToVisible:textFieldRect animated:NO];
        }
        [UIView commitAnimations];
        // add the "Done" button to the nav bar
        [self createDoneButtonIfNeeded];
        self.navItem.rightBarButtonItem = self.doneButton;
    }
}

- (void) createDatePickerIfNeeded
{
    if (!self.pickerView)
    {
        self.pickerView = [[UIDatePicker alloc] init];
        self.pickerView.datePickerMode = UIDatePickerModeDate;
        self.pickerView.locale = [NSLocale currentLocale];
        self.pickerView.calendar = [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
        self.pickerView.maximumDate = [NSDate date];
        
        [self.pickerView addTarget:self
                            action:@selector(dateAction)
                  forControlEvents:UIControlEventValueChanged];
    }
}

- (void) createDoneButtonIfNeeded
{
    if (!self.doneButton)
    {
        self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneAction)];
    }
}

- (void)slideDownDidStop
{
	// the date picker has finished sliding downwards, so remove it
	[self.pickerView removeFromSuperview];
}

- (void)dateAction
{
	self.clientLBBirthday.text = [self.dateFormatter stringFromDate:self.pickerView.date];
    self.clientEntity.birthday = self.clientLBBirthday.text;
    
    [self checkInputData];
}

- (void)doneAction
{
    if (self.pickerView.superview)
    {
        [self dateAction];
        
        CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
        CGRect endFrame = self.pickerView.frame;
        endFrame.origin.y = screenRect.origin.y + screenRect.size.height;
        
        // start the slide down animation
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationBeginsFromCurrentState:YES];
        
        // we need to perform some post operations after the animation is complete
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(slideDownDidStop)];
        
        self.pickerView.frame = endFrame;
        
        // grow the table back again in vertical size to make room for the date picker
        CGRect newFrame = self.loginTableView.frame;
        newFrame.size.height += endFrame.size.height;
        self.loginTableView.frame = newFrame;
        
        [UIView commitAnimations];
        
        // remove the "Done" button in the nav bar
        self.navItem.rightBarButtonItem = nil;
        
        // deselect the current table row
        NSIndexPath *indexPath = [self.loginTableView indexPathForSelectedRow];
        [self.loginTableView deselectRowAtIndexPath:indexPath animated:YES];
    }
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

- (IBAction)insertNewProfile
{
    [self.activeTextField resignFirstResponder];
    [self doneAction];
    
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
    [self.spinner startAnimating];
    [self.continueButton setTitle:@"" forState:UIControlStateDisabled];
    self.continueButton.enabled = NO;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    self.clientEntity.birthday = [formatter stringFromDate:[self.dateFormatter dateFromString:self.clientEntity.birthday]];
    
    NSMutableString *result = [[NSMutableString alloc] initWithString:self.clientEntity.license];
    [result replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [result length])];
    self.clientEntity.license = result;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CDao *dao = [CDao daoWithContext:delegate.dataAccessManager.managedObjectContext];
    
    dispatch_async(delegate.dispatcher.dataUpdateQueue, ^{
        
        status requestStatus = [delegate.updater insertNewProfileAndUpdate:self.clientEntity.dict];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            [self.continueButton setTitle:@"Сохранить и продолжить" forState:UIControlStateDisabled];
            self.continueButton.enabled = YES;
        });
        
        if (requestStatus == GOOD)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                delegate.lastSignProfile = [dao lastSignProfile];
                [self performSegueWithIdentifier:@"LoginToTabBar" sender:self];
            });
        }
    });
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.activeTextField resignFirstResponder];
    [self doneAction];
}

@end
