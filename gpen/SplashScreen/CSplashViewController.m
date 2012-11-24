//
//  CSplashViewController.m
//  citis
//
//  Created by Alexey Rogatkin on 29.10.12.
//  Copyright (c) 2012 Андрей Иванов. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CSplashViewController.h"
#import "CDataAccessManager.h"
#import "AppDelegate.h"

@interface CSplashViewController ()

@end

@implementation CSplashViewController

@synthesize splash = _splash;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadingAnimation];
}

- (void)loadingAnimation {

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate initializeApplication];
}

@end
