//
//  CDisclosureCell.h
//  gpen
//
//  Created by Ilya Khokhlov on 26.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CWithCustomDisclosureIndicatorCell.h"

@interface CDisclosureCell : CWithCustomDisclosureIndicatorCell

@property (nonatomic, strong) IBOutlet UITextField *cellTextField;

@end
