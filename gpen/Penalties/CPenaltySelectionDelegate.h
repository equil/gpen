//
//  CPenaltySelectionDelegate.h
//  gpen
//
//  Created by Ilya Khokhlov on 16.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CPenaltySelectionDelegate <NSObject>
- (void) penaltySelectionChanged: (Penalty *) penalty;
@end
