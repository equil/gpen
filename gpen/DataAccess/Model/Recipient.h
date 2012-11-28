//
//  Recipient.h
//  gpen
//
//  Created by fredformout on 28.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Penalty;

@interface Recipient : NSManagedObject

@property (nonatomic, retain) NSString * account;
@property (nonatomic, retain) NSString * administratorCode;
@property (nonatomic, retain) NSString * bank;
@property (nonatomic, retain) NSString * billTitle;
@property (nonatomic, retain) NSString * inn;
@property (nonatomic, retain) NSString * kbk;
@property (nonatomic, retain) NSString * kpp;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * okato;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) Penalty *penalty;

@end
