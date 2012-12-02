//
//  CUpdater.h
//  gpen
//
//  Created by fredformout on 26.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Profile.h"

typedef enum{
    UNAVAILABLE = 0,
    NOTFOUND = 1,
    GOOD = 2
} status;

@interface CUpdater : NSObject

- (status)insertNewProfileAndUpdate:(NSDictionary *)dict;
- (status)updateProfile:(Profile *)profile;
- (void)updateLastSignForProfile:(Profile *)profile;
- (status)sendInfoToProfile:(Profile *)profile penalty:(Penalty *)penalty email:(NSString *)email;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end
