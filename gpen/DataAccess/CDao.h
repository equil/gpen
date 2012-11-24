//
//  CDao.h
//  eor
//
//  Created by fredformout on 11.10.12.
//  Copyright (c) 2012 Андрей Иванов. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDao : NSObject
{
    NSManagedObjectContext *dataContext_;
}

@property (readonly) NSManagedObjectContext *dataContext;
@property (readonly) NSManagedObjectModel *dataModel;

+ (CDao *)daoWithContext:(NSManagedObjectContext *)dataContext;
- (id)initWithContext:(NSManagedObjectContext *)dataContext;

@end
