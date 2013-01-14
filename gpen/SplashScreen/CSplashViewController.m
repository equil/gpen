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
@synthesize spinner = _spinner;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self heightOfScreen] == 1136.0)
    {
        [_splash setImage:[UIImage imageNamed:@"Default-568h.png"]];
        [_spinner setFrame:CGRectMake(_spinner.frame.origin.x, _spinner.frame.origin.y + 40.0, _spinner.frame.size.width, _spinner.frame.size.height)];
    }
    
    [self loadingAnimation];
}

- (void)loadingAnimation {

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    sleep(2);
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate initializeApplication];
}

- (CGFloat)heightOfScreen
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            return result.height;
        }
        else{
            return 0.0;
        }
    }
    else
    {
        return 0.0;
    }
}

@end
