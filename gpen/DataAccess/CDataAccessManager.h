//
//  CDataAccessManager.h
//  eor
//
//  Created by fredformout on 10.10.12.
//  Copyright (c) 2012 Андрей Иванов. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

static NSString *const kAutomaticLastUpdatePropertyName = @"entityLastUpdateDate";

@interface CDataAccessManager : NSObject

@property(readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property(readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveState;

- (void)saveDataInForeignContext:(void(^)(NSManagedObjectContext *context))saveBlock;

- (void)saveDataInBackgroundInForeignContext:(void(^)(NSManagedObjectContext *context))saveBlock;

- (void)saveDataInBackgroundInForeignContext:(void(^)(NSManagedObjectContext *context))saveBlock completion:(void(^)(void))completion;

@end