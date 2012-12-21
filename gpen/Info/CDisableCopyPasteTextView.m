//
//  CDisableCopyPasteTextView.m
//  gpen
//
//  Created by fredformout on 21.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CDisableCopyPasteTextView.h"

@implementation CDisableCopyPasteTextView

- (BOOL)canBecomeFirstResponder {
    return NO;
}

@end
