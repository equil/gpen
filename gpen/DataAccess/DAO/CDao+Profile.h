//
//  CDao+Profile.h
//  gpen
//
//  Created by fredformout on 28.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CDao.h"
#import "Profile.h"

@interface CDao (Profile)

- (NSArray *)allProfiles;
- (Profile *)profileForData:(NSArray *)data;

@end
