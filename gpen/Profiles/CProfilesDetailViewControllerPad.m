//
//  CProfilesDetailViewControllerPad.m
//  gpen
//
//  Created by Ilya Khokhlov on 17.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CProfilesDetailViewControllerPad.h"

@interface CProfilesDetailViewControllerPad ()

@end

@implementation CProfilesDetailViewControllerPad
@synthesize splashView = _splashView;
@synthesize informLabel = _informLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.informLabel.font = [UIFont fontWithName:@"PTSans-Regular" size:13.0];
    
    [self.tableView addSubview:self.splashView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) profileSelectionChanged:(Profile *)profile
{
    [super profileSelectionChanged:profile];
    
    if (profile)
    {
        [self.splashView removeFromSuperview];
    }
    else
    {
        if (![self.splashView superview])
        {
            [self.tableView addSubview:self.splashView];
        }
    }
}

@end
