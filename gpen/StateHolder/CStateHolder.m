//
//  CStateHolder.m
//  gpen
//
//  Created by fredformout on 19.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CStateHolder.h"

@interface CStateHolder ()
{
    NSMutableArray *_observers;
}

- (void)initializeBean;

@end

@implementation CStateHolder

@synthesize currentPenalty = _currentPenalty;
@synthesize currentProfile = _currentProfile;

- (void)initializeBean {
    _observers = [[NSMutableArray alloc] init];
    
    self.currentPenalty = nil;
    self.currentProfile = nil;
}

- (id)init {
    self = [super init];
    if (self) {
        [self initializeBean];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initializeBean];
}

- (void)setCurrentPenalty:(Penalty *)currentPenalty
{
    if (_currentPenalty == currentPenalty) {
        return;
    }
    _currentPenalty = currentPenalty;
    [self callObserversWithSelector:@selector(currentPenaltyChanged:) withObject:self.currentPenalty];
}

- (void)setCurrentProfile:(Profile *)currentProfile
{
    if (_currentProfile == currentProfile) {
        return;
    }
    _currentProfile = currentProfile;
    [self callObserversWithSelector:@selector(currentProfileChanged:) withObject:self.currentProfile];
}

- (void)callObserversWithSelector:(SEL)selector withObject:(NSObject *)object {
    @synchronized (_observers) {
        for (NSValue *observerContainer in _observers) {
            id observer = [observerContainer nonretainedObjectValue];
            
            if ([observer respondsToSelector:selector]) {
                [observer performSelectorOnMainThread:selector withObject:object waitUntilDone:NO];
            }
        }
    }
}

- (void)addObserver:(id <IStateHolderObserver>)observer {
    @synchronized (_observers) {
        [self removeObserver:observer];
        [_observers addObject:[NSValue valueWithNonretainedObject:observer]];
    }
}

- (void)removeObserver:(id <IStateHolderObserver>)observerToRemove {
    @synchronized (_observers) {
        NSMutableSet *toRemove = [[NSMutableSet alloc] initWithCapacity:[_observers count]];
        for (NSValue *observerContainer in _observers) {
            id observer = [observerContainer nonretainedObjectValue];
            if (observer == nil || observer == observerToRemove) { // address equality or dead link
                [toRemove addObject:observerContainer];
            }
        }
        for (NSValue *observerContainer in toRemove) {
            [_observers removeObject:observerContainer];
        }
    }
}

@end
