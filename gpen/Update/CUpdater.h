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
    GOOD = 2,
    INVALIDJSON = 3
} status;

@interface CUpdater : NSObject

- (void)insertProfile:(NSDictionary *)dict;
- (void)editProfile:(Profile *)profile data:(NSDictionary *)dict;
- (status)syncProfile:(Profile *)profile;
- (void)deleteProfile:(Profile *)profile;
- (void)updateLastSignForProfile:(Profile *)profile;
- (void)setNewPenaltiesCountForLicense:(NSString *)license count:(unsigned long)count;
- (void)setNewPenaltiesCountForProfile:(Profile *)profile count:(unsigned long)count;
- (status)sendInfoToProfile:(Profile *)profile penalty:(Penalty *)penalty email:(NSString *)email;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@end
