//
//  CLoginViewController.m
//  gpen
//
//  Created by fredformout on 25.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CLoginViewController.h"
#import "CTextFieldCell.h"
#import "CDisclosureCell.h"

@interface CLoginViewController ()
@property (nonatomic, weak) UITextField *activeTextField;
@end

@implementation CLoginViewController
@synthesize spinner = _spinner;
@synthesize loginTableView = _loginTableView;
@synthesize continueButton = _continueButton;
@synthesize activeTextField = _activeTextField;

#pragma mark - Text Field Delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.activeTextField = nil;
}

-(void) keyboardWillShow:(NSNotification *)note
{
    // Get the keyboard size
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    
    // Detect orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.loginTableView.frame;
    
    // Start animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    // Reduce size of the Table view
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        frame.size.height -= keyboardBounds.size.height;
    else
        frame.size.height -= keyboardBounds.size.width;
    
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
    static NSString *disclosureCellId = @"disclosureCell";
    
    
    // Ячейка со стрелкой - единственная в таблице
    if (indexPath.section == 2)
    {
        CDisclosureCell *cell = (CDisclosureCell *) [tableView dequeueReusableCellWithIdentifier:disclosureCellId];
        cell.cellLabel.text = @"Дата рождения";
        return cell;
    }
    
    // Остальные - с текстовыми полями
    CTextFieldCell *cell = (CTextFieldCell *) [tableView dequeueReusableCellWithIdentifier:textFieldCellId];
    cell.cellTextField.delegate = self;
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                    cell.cellTextField.placeholder = @"Фамилия";
                    break;
                case 1:
                    cell.cellTextField.placeholder = @"Имя";
                    break;
                case 2:
                    cell.cellTextField.placeholder = @"Отчество";
                    break;
            }
            break;
        }
        case 1:
        {
            cell.cellTextField.placeholder = @"Название профиля";
            break;
        }
        case 3:
        {
            cell.cellTextField.placeholder = @"Номер водительского удостоверения";
            break;
        }
        case 4:
        {
            cell.cellTextField.placeholder = @"Электронная почта";
            break;
        }
    }
            
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case 1:
            return @"По умолчанию будут использоваться имя и фамилия, указанные в профиле";
        case 3:
            return @"Образец: 63СТ000000";
        case 4:
            return @"Необязательно";
        default:
            return nil;
    }
    
}

@end
