//
//  Penalty.h
//  gpen
//
//  Created by fredformout on 24.12.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Profile, Recipient;

@interface Penalty : NSManagedObject

@property (nonatomic, retain) NSString * carNumber;
@property (nonatomic, retain) NSString * catcher;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * fixedLicenseId;
@property (nonatomic, retain) NSNumber * fixedSpeed;
@property (nonatomic, retain) NSString * issueKOAP;
@property (nonatomic, retain) NSDate * overdueDate;
@property (nonatomic, retain) id photo;
@property (nonatomic, retain) NSNumber * price;
@property (nonatomic, retain) NSString * reportId;
@property (nonatomic, retain) NSString * roadName;
@property (nonatomic, retain) NSNumber * roadPosition;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSNumber * notified;
@property (nonatomic, retain) NSSet *profiles;
@property (nonatomic, retain) Recipient *recipient;
@end

@interface Penalty (CoreDataGeneratedAccessors)

- (void)addProfilesObject:(Profile *)value;
- (void)removeProfilesObject:(Profile *)value;
- (void)addProfiles:(NSSet *)values;
- (void)removeProfiles:(NSSet *)values;

@end
