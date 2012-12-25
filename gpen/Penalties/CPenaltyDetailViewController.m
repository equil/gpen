//
//  CPenaltyDetailViewController.m
//  gpen
//
//  Created by fredformout on 02.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CPenaltyDetailViewController.h"
#import "CPenaltyTicketViewController.h"
#import "AppDelegate.h"
#import "CPenaltyDetailCell.h"
#import "Penalty.h"
#import "CPenaltyDetailBoldWithImageCell.h"
#import "CPenaltyDetailMainCell.h"
#import "CPenaltyListViewController.h"

@interface CPenaltyDetailViewController ()
@property (nonatomic, copy) NSString *email;
@property (nonatomic, strong) NSArray *dataSource;
@end

@implementation CPenaltyDetailViewController

@synthesize penalty = _penalty;
@synthesize buttonShowTicket = _buttonShowTicket;
@synthesize buttonSendTicket = _buttonSendTicket;
@synthesize infoLabel = _infoLabel;
@synthesize emailTextField = _emailTextField;
@synthesize indicator = _indicator;
@synthesize email = _email;
@synthesize dataSource = _dataSource;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"PenaltyDetailToTicket"]) {
        CPenaltyTicketViewController *destination = segue.destinationViewController;
        destination.penalty = _penalty;
    }
}

- (void)penaltySelectionChanged:(Penalty *)penalty
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    [self loadInfoFromPenalty:penalty];
}

- (void) loadInfoFromPenalty: (Penalty *) penalty
{
    self.penalty = penalty;
    
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    delegate.stateHolder.currentPenalty = self.penalty;
    self.email = delegate.lastSignProfile.email;
    if (self.email)
    {
        self.emailTextField.text = self.email;
    }
    
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"hh:mm"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy"];
    
    if (self.penalty)
    {
        self.dataSource = [NSArray arrayWithObjects:
                           [NSArray arrayWithObjects:@"Штраф:", [NSString stringWithFormat:@"%@ р.", [self spacedMoneyString:[NSString stringWithFormat:@"%@", self.penalty.price]]], nil],
                           [NSArray arrayWithObjects:@"Протокол:", [self spacedProtocolString:self.penalty.reportId], nil],
                           [NSArray arrayWithObjects:@"Статья КоАП:", self.penalty.issueKOAP, nil],
                           [NSArray arrayWithObjects:@"Время:", [timeFormatter stringFromDate:self.penalty.date], nil],
                           [NSArray arrayWithObjects:@"Дата:", [dateFormatter stringFromDate:self.penalty.date], nil],
                           [NSArray arrayWithObjects:@"Место:", [NSString stringWithFormat:@"%@, %@ км", self.penalty.roadName, self.penalty.roadPosition], nil],
                           [NSArray arrayWithObjects:@"Водительское удостоверение:", [NSString stringWithFormat:@"№ %@", [self spacedLicenseString:self.penalty.fixedLicenseId]], nil],
                           [NSArray arrayWithObjects:@"Подразделение ГИБДД, выявившее нарушение:", self.penalty.catcher, nil],
                           [NSString stringWithFormat:@"%@, %@ км/ч", self.penalty.roadName, self.penalty.fixedSpeed],
                           nil];
    }
    
    [self.tableView reloadData];
    
    [self checkInputData];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
	((CPenaltyListViewController*)[((UINavigationController*)[self.splitViewController.viewControllers objectAtIndex:0]).viewControllers lastObject]).selectionDelegate = self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.infoLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.emailTextField.text = delegate.lastSignProfile.email;
    
    [self loadInfoFromPenalty:self.penalty];
}

- (void)handleGoToRoot
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (![_penalty.profiles containsObject:delegate.lastSignProfile])
    {
        [self handleGoToRoot];
    }
}

- (NSString *) spacedMoneyString: (NSString *) moneyString
{
    NSMutableString *temp = [NSMutableString stringWithString:moneyString];
    
    int strLen = [temp length];
    while (strLen >= 4)
    {
        [temp insertString:@" " atIndex:strLen - 3];
        strLen -= 3;
    }
    
    return temp;
}

- (NSString *) spacedProtocolString: (NSString *) protocolString
{
    NSMutableString *temp = [NSMutableString stringWithString:protocolString];
    
    [temp insertString:@" " atIndex:7];
    [temp insertString:@" " atIndex:4];
    [temp insertString:@" " atIndex:2];
    
    return temp;
}

- (NSString *) spacedLicenseString: (NSString *) licenseString
{
    NSMutableString *temp = [NSMutableString stringWithString:licenseString];
    
    [temp insertString:@" " atIndex:4];
    [temp insertString:@" " atIndex:2];
    
    return temp;
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
    CGRect frame = self.tableView.frame;
    
    // Reduce size of the Table view
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        frame.size.height -= keyboardBounds.size.height - self.tabBarController.tabBar.frame.size.height;
    else
        frame.size.height -= keyboardBounds.size.width - self.tabBarController.tabBar.frame.size.height;
    
    // Start animation
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    // Apply new size of table view
    self.tableView.frame = frame;
    
    // Scroll the table view to see the TextField just above the keyboard
    CGRect textFieldRect = [self.tableView convertRect:self.emailTextField.bounds fromView:self.emailTextField];
    [self.tableView scrollRectToVisible:textFieldRect animated:NO];
    
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note
{
    // Get the keyboard size
    CGRect keyboardBounds;
    [[note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey] getValue: &keyboardBounds];
    
    // Detect orientation
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect frame = self.tableView.frame;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3f];
    
    // Reduce size of the Table view
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
        frame.size.height += keyboardBounds.size.height - self.tabBarController.tabBar.frame.size.height;
    else
        frame.size.height += keyboardBounds.size.width - self.tabBarController.tabBar.frame.size.height;
    
    // Apply new size of table view
    self.tableView.frame = frame;
    
    [UIView commitAnimations];
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

- (IBAction)sendInfoToEmail
{
    [self.emailTextField resignFirstResponder];
    
    if (!(self.email) || (self.email.length < 1) || ([self validateEmail:[self.email lowercaseString]]))
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
    self.buttonSendTicket.enabled = NO;
    [self.buttonSendTicket setTitle:@"" forState:UIControlStateDisabled];
    [self.indicator startAnimating];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    dispatch_async(delegate.dispatcher.dataUpdateQueue, ^{
        
        status requestStatus = [delegate.updater sendInfoToProfile:delegate.lastSignProfile penalty:_penalty email:self.email];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.indicator stopAnimating];
            [self.buttonSendTicket setTitle:@"Отправить" forState:UIControlStateDisabled];
            self.buttonSendTicket.enabled = YES;
        });
        
        if (requestStatus == GOOD)
        {
            NSLog(@"ticket was sent");
        }
    });
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
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= maxLength || returnKey;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.email = textField.text;
}

- (IBAction) checkInputData
{
    self.email = self.emailTextField.text;
    self.buttonSendTicket.enabled = (self.email.length > 0);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
        case 1:
            return 1;
        case 2:
            return 5;
        case 3:
            return 2;
    }
    return 0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGFloat result = 0.0;
    switch (indexPath.section)
    {
        case 0:
            result = [self heightForMainCell];
            break;
        case 1:
            result = [self heightForText:[[self.dataSource objectAtIndex:0] objectAtIndex:1] bold:YES];
            break;
        case 2:
            result = [self heightForText:[[self.dataSource objectAtIndex:indexPath.row+1] objectAtIndex:1] bold:NO];
            break;
        case 3:
            result = [self heightForVerticalText:[[self.dataSource objectAtIndex:indexPath.row+6] objectAtIndex:1] title:[[self.dataSource objectAtIndex:indexPath.row+6] objectAtIndex:0]];
            break;
    }
    return (result < 44.0) ? 44.0 : result;
}

- (CGFloat) heightForText: (NSString *) aText bold: (BOOL) aBold
{
    CGFloat outerWidth = 170.0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        outerWidth = 220.0;
    }
    // use large value to avoid scrolling
    CGFloat maxHeight = 50000.0f;
    CGSize constraint = CGSizeMake(outerWidth, maxHeight);
    NSMutableString *fontName = [NSMutableString stringWithString:@"PTSans-"];
    if (aBold)
    {
        [fontName appendString:@"Bold"];
    }
    else
    {
        [fontName appendString:@"Regular"];
    }
    CGSize size = [aText
                   sizeWithFont:[UIFont fontWithName:fontName size:16.0]
                   constrainedToSize:constraint
                   lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = size.height + 11.0 * 2;
    return height;
}

- (CGFloat) heightForMainCell
{
    CGFloat outerWidth = 161.0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        outerWidth = 346.0;
    }
    // use large value to avoid scrolling
    CGFloat maxHeight = 50000.0f;
    CGSize constraint = CGSizeMake(outerWidth, maxHeight);
    CGSize size = [[self.dataSource objectAtIndex:8]
                   sizeWithFont:[UIFont fontWithName:@"PTSans-Regular" size:13.0]
                   constrainedToSize:constraint
                   lineBreakMode:UILineBreakModeWordWrap];
    CGFloat height = size.height + 56.0 + 15.0;
    
    return (height < 120.0) ? 120.0 : height;
}

- (CGFloat) heightForVerticalText: (NSString *) aText title: (NSString *) aTitle
{
    CGFloat textHeight = [self heightForVerticalText:aText];
    CGFloat titleHeight = [self heightForVerticalText:aTitle];
    CGFloat height = textHeight + titleHeight + 11.0 * 2 + 8.0;
    return height;
}

- (CGFloat) heightForVerticalText: (NSString *) aText
{
    CGFloat outerWidth = 276.0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        outerWidth = 361.0;
    }
    // use large value to avoid scrolling
    CGFloat maxHeight = 50000.0f;
    CGSize constraint = CGSizeMake(outerWidth, maxHeight);
    CGSize size = [aText
                   sizeWithFont:[UIFont fontWithName:@"PTSans-Regular" size:16.0]
                   constrainedToSize:constraint
                   lineBreakMode:UILineBreakModeWordWrap];
    return size.height;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *penaltyCellId = @"penaltyDetail";
    static NSString *penaltyBoldCellId = @"penaltyBoldDetail";
    static NSString *penaltyMainCellId = @"penaltyDetailMain";
    static NSString *penaltyVerticalCellId = @"penaltyDetailVertical";
    
    switch (indexPath.section)
    {
        case 0:
        {
            CPenaltyDetailMainCell *cell = (CPenaltyDetailMainCell *)[tableView dequeueReusableCellWithIdentifier:penaltyMainCellId];
            NSString *photo = self.penalty.photo;
            
            if ([photo length] > 0)
            {
                NSArray *arr = [photo componentsSeparatedByString:@"."];
                NSString *ext = [arr objectAtIndex:[arr count] - 1];
                
                if ([ext isEqualToString:@"png"])
                {
                    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, photo];
                    cell.carPhoto.image = [UIImage imageWithContentsOfFile:fullPath];
                }
                else
                {
                    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, photo];
                    NSURL *url = [NSURL fileURLWithPath:fullPath];
                    cell.carPhoto.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                }
            }
            else
            {
                cell.containerView.frame = CGRectMake(cell.carPhoto.frame.origin.x, cell.containerView.frame.origin.y, cell.containerView.frame.size.width + (cell.containerView.frame.origin.x - cell.carPhoto.frame.origin.x), cell.containerView.frame.size.height);
            }
            if (self.penalty.carNumber.length > 5)
            {
                cell.nomerLabel.text = [self.penalty.carNumber substringToIndex:6];
                cell.regionLabel.text = [self.penalty.carNumber substringFromIndex:6];
            }
            else
            {
                cell.nomerLabel.text = @"";
                cell.regionLabel.text = @"";
                cell.flag.hidden = YES;
            }
            cell.placeLabel.text = [self.dataSource objectAtIndex:8];
            return cell;
        }
        case 1:
        {
            CPenaltyDetailBoldWithImageCell *cell = (CPenaltyDetailBoldWithImageCell *)[tableView dequeueReusableCellWithIdentifier:penaltyBoldCellId];
            [cell.labelTitle setText:[[self.dataSource objectAtIndex:indexPath.row] objectAtIndex:0]];
            [cell.labelSubtitle setText:[[self.dataSource objectAtIndex:indexPath.row] objectAtIndex:1]];
            cell.statusImageView.image = [UIImage imageNamed:[self imageNameForStatus:self.penalty.status]];
            return cell;
        }
        case 2:
        {
            CPenaltyDetailCell *cell = (CPenaltyDetailCell *)[tableView dequeueReusableCellWithIdentifier:penaltyCellId];
            [cell.labelTitle setText:[[self.dataSource objectAtIndex:indexPath.row+1] objectAtIndex:0]];
            [cell.labelSubtitle setText:[[self.dataSource objectAtIndex:indexPath.row+1] objectAtIndex:1]];
            return cell;
        }
        case 3:
        {
            CPenaltyDetailCell *cell = (CPenaltyDetailCell *)[tableView dequeueReusableCellWithIdentifier:penaltyVerticalCellId];
            [cell.labelTitle setText:[[self.dataSource objectAtIndex:indexPath.row+6] objectAtIndex:0]];
            [cell.labelSubtitle setText:[[self.dataSource objectAtIndex:indexPath.row+6] objectAtIndex:1]];
            
            cell.labelTitle.frame = CGRectMake(cell.labelTitle.frame.origin.x, cell.labelTitle.frame.origin.y, cell.labelTitle.frame.size.width, [self heightForVerticalText:cell.labelTitle.text]);
            cell.labelSubtitle.frame = CGRectMake(cell.labelSubtitle.frame.origin.x, cell.labelTitle.frame.origin.y + cell.labelTitle.frame.size.height + 8.0, cell.labelSubtitle.frame.size.width, [self heightForVerticalText:cell.labelSubtitle.text]);
            
            return cell;
        }
    }
    return [[UITableViewCell alloc] init];
}

- (NSString *) imageNameForStatus: (NSString *) status
{
    if ([@"3_paid" isEqualToString:status])
    {
        return @"penalty_paid";
    }
    else if ([@"2_not paid" isEqualToString:status])
    {
        return @"penalty_not_paid";
    }
    else if ([@"1_overdue" isEqualToString:status])
    {
        return @"penalty_overdue";
    }
    
    return nil;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}

@end
