//
//  CDao+Penalty.h
//  gpen
//
//  Created by fredformout on 28.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CDao.h"
#import "Penalty.h"
#import "Profile.h"

@interface CDao (Penalty)

- (NSArray *)allPenalties;
- (NSArray *)allPenaltiesForProfile:(Profile *)profile;
- (Penalty *)penaltyForUid:(NSNumber *)uid;

@end
