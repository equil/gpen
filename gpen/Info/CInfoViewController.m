//
//  CInfoViewController.m
//  gpen
//
//  Created by fredformout on 02.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CInfoViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface CInfoViewController ()

@end

@implementation CInfoViewController

@synthesize textView = _textView;
@synthesize label = _label;
@synthesize scroll = _scroll;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Информация";
    
    _textView.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    _label.font = [UIFont fontWithName:@"PTSans-Bold" size:16.0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _scroll.contentSize = CGSizeMake(0.0, _textView.frame.size.height);
}

@end
