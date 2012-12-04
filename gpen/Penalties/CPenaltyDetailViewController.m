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

@interface CPenaltyDetailViewController ()
@property (nonatomic, copy) NSString *email;
@end

@implementation CPenaltyDetailViewController

@synthesize penalty = _penalty;
@synthesize buttonShowTicket = _buttonShowTicket;
@synthesize buttonSendTicket = _buttonSendTicket;
@synthesize infoLabel = _infoLabel;
@synthesize emailTextField = _emailTextField;
@synthesize indicator = _indicator;
@synthesize email = _email;

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ([segue.identifier isEqualToString:@"PenaltyDetailToTicket"]) {
        CPenaltyTicketViewController *destination = segue.destinationViewController;
        destination.penalty = _penalty;
    }
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.emailTextField.leftView = paddingView;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.rightView = paddingView;
    self.emailTextField.rightViewMode = UITextFieldViewModeAlways;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.emailTextField.text = delegate.lastSignProfile.email;
    
    [self checkInputData];
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
        frame.size.height += keyboardBounds.size.height;
    else
        frame.size.height += keyboardBounds.size.width;
    
    // Apply new size of table view
    self.tableView.frame = frame;
    
    [UIView commitAnimations];
}


- (IBAction)sendInfoToEmail
{
    [self.emailTextField resignFirstResponder];
    
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


@end
