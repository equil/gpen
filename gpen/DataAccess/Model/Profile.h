//
//  Profile.h
//  gpen
//
//  Created by fredformout on 28.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Penalty;

@interface Profile : NSManagedObject

@property (nonatomic, retain) NSDate * birthday;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * lastname;
@property (nonatomic, retain) NSString * license;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * patronymic;
@property (nonatomic, retain) NSString * profileName;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSDate * lastSign;
@property (nonatomic, retain) NSSet *penalties;
@end

@interface Profile (CoreDataGeneratedAccessors)

- (void)addPenaltiesObject:(Penalty *)value;
- (void)removePenaltiesObject:(Penalty *)value;
- (void)addPenalties:(NSSet *)values;
- (void)removePenalties:(NSSet *)values;

@end
