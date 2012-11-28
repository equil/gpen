//
//  Penalty.h
//  gpen
//
//  Created by fredformout on 28.11.12.
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
@property (nonatomic, retain) Profile *profile;
@property (nonatomic, retain) Recipient *recipient;

@end
