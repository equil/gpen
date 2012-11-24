//
//  Penalty.h
//  gpen
//
//  Created by fredformout on 24.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Penalty : NSManagedObject

@property (nonatomic, retain) NSString * uid;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * price;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * carNumber;
@property (nonatomic, retain) NSDate * overdueDate;
@property (nonatomic, retain) id photo;
@property (nonatomic, retain) NSString * roadName;
@property (nonatomic, retain) NSString * roadPosition;
@property (nonatomic, retain) NSString * fixedSpeed;
@property (nonatomic, retain) NSString * reportId;
@property (nonatomic, retain) NSString * issueKOAP;
@property (nonatomic, retain) NSString * fixedLicenseId;
@property (nonatomic, retain) NSString * catcher;
@property (nonatomic, retain) NSManagedObject *profile;
@property (nonatomic, retain) NSManagedObject *recipient;

@end
