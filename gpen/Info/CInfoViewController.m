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
@synthesize scroll = _scroll;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _textView.font = [UIFont fontWithName:@"PTSans-Regular" size:16.0];
    _textView.layer.masksToBounds = NO;
    _textView.layer.cornerRadius = 10.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _scroll.contentSize = CGSizeMake(0.0, _textView.frame.size.height + 20.0);
}

@end
