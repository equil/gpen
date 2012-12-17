//
//  CProfileSelectionDelegate.h
//  gpen
//
//  Created by Ilya Khokhlov on 17.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Profile.h"

@protocol CProfileSelectionDelegate <NSObject>
- (void) profileSelectionChanged: (Profile *) profile;
@end
