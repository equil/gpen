//
//  IStateHolderObserver.h
//  gpen
//
//  Created by fredformout on 19.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "Penalty.h"
#import "Profile.h"

@protocol IStateHolderObserver <NSObject>

@optional
- (void) currentPenaltyChanged: (Penalty *) penalty;
- (void) currentProfileChanged: (Profile *) profile;

@end
