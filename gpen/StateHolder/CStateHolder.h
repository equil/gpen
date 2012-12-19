//
//  CStateHolder.h
//  gpen
//
//  Created by fredformout on 19.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IStateHolderObserver.h"

@interface CStateHolder : NSObject

@property (nonatomic, strong) Penalty *currentPenalty;
@property (nonatomic, strong) Profile *currentProfile;

- (void)addObserver:(id <IStateHolderObserver>)observer;
- (void)removeObserver:(id <IStateHolderObserver>)observer;

@end
