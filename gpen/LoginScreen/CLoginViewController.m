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

@interface CLoginViewController ()
@property (nonatomic, weak) UITextField *activeTextField;
@end

@implementation CLoginViewController
@synthesize navItem = _navItem;
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

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.continueButton.enabled = YES;
    
    self.navItem.title = @"Заполните анкету";
    
    self.loginTableView.backgroundColor = [UIColor colorWithRed:230.0/255.0 green:227.0/255.0 blue:225.0/255.0 alpha:1.0];
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
    static NSString *textFieldWithLabelCellId = @"textFieldWithLabelCell";
    static NSString *disclosureCellId = @"disclosureCell";
    
    
    // Ячейка со стрелкой - единственная в таблице
    if (indexPath.section == 1)
    {
        CDisclosureCell *cell = (CDisclosureCell *) [tableView dequeueReusableCellWithIdentifier:disclosureCellId];
        cell.cellLabel.text = @"Дата рождения";
        return cell;
    }
    else if (indexPath.section == 3)
    {
        CTextFieldWithLabel *cell = (CTextFieldWithLabel *) [tableView dequeueReusableCellWithIdentifier:textFieldWithLabelCellId];
        cell.cellTextField.delegate = self;
        cell.cellTextField.placeholder = @"Электронная почта";
        cell.cellLabel.text = @"Необязательно";
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
        case 2:
        {
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

/*
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section)
    {
        case 2:
            return @"Образец: 63СТ000000";
        default:
            return nil;
    }
}
 */

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 2)
    {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
        footerView.backgroundColor = [UIColor clearColor];
        
        UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, footerView.frame.size.width - 36, 20)];
        footerLabel.backgroundColor = [UIColor clearColor];
        footerLabel.text = @"Образец: 63СТ000000";
        footerLabel.textColor = [UIColor darkGrayColor];
        footerLabel.font = [UIFont systemFontOfSize:12.0];
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

- (IBAction)insertNewProfile
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CDao *dao = [CDao daoWithContext:delegate.dataAccessManager.managedObjectContext];
    
    dispatch_async(delegate.dispatcher.dataUpdateQueue, ^{
         NSDictionary *dictOfProfile = [NSDictionary dictionaryWithObjectsAndKeys:
                                        @"",@"name",
                                        @"",@"patronymic",
                                        @"",@"surname",
                                        @"",@"license",
                                        @"",@"birthday",
                                        @"",@"email",
                                        nil];
         
         status requestStatus = [delegate.updater insertNewProfileAndUpdate:dictOfProfile];
         
         if (requestStatus == GOOD)
         {
             delegate.lastSignProfile = [dao lastSignProfile];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self performSegueWithIdentifier:@"LoginToTabBar" sender:self];
             });
         }
    });
}

@end
