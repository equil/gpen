//
//  CInfoViewController.h
//  gpen
//
//  Created by fredformout on 02.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CRotateViewController.h"
#import "CDisableCopyPasteTextView.h"

@interface CInfoViewController : CRotateViewController

@property (nonatomic, retain) IBOutlet CDisableCopyPasteTextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) IBOutlet UIScrollView *scroll;

@end
