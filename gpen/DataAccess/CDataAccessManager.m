//
//  CDataAccessManager.m
//  eor
//
//  Created by fredformout on 10.10.12.
//  Copyright (c) 2012 Андрей Иванов. All rights reserved.
//

#import "CDataAccessManager.h"
#import "AppDelegate.h"

@interface CDataAccessManager ()
- (void)updateLastUpdateDateInConformedUpdatedObjects:(NSManagedObjectContext *)localContext;

- (BOOL)hasPropertyNamed:(NSString *)objectKey managedObject:(NSManagedObject *)updatedObject;

@end

@implementation CDataAccessManager {
@private
    NSManagedObjectContext *_managedObjectContext;
    NSManagedObjectModel *_managedObjectModel;
    NSPersistentStoreCoordinator *_persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"gpen" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    NSString *dbName = [NSString stringWithFormat:@"%@.sqlite", @"gpen"];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:dbName];

    NSError *error = nil;

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
            [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        NSLog(@"Error on linking NSPersistentStoreCoordinator: %@", error.userInfo);
        abort();
    }

    return _persistentStoreCoordinator;
}

- (void)writeContent:(NSString *)string toFile:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains
            (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];

    //make a file name to write the data to using the documents directory:
    NSString *name = [NSString stringWithFormat:@"%@/%@",
                                                documentsDirectory, fileName];
    //save content to the documents directory
    [string writeToFile:name
             atomically:NO encoding:NSStringEncodingConversionAllowLossy
                  error:nil];
}

- (void)saveState {
    NSError *error = nil;
    const BOOL success = [self.managedObjectContext save:&error];
    if (!success) {
        NSLog(@"Error while save context. %@", [error userInfo]);
    }
}

- (void)saveDataInForeignContext:(void (^)(NSManagedObjectContext *))saveBlock {
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {

        NSManagedObjectContext *localContext = [[NSManagedObjectContext alloc] init];
        [localContext setPersistentStoreCoordinator:coordinator];

        [localContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        [self.managedObjectContext setMergePolicy:NSMergeByPropertyStoreTrumpMergePolicy];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(backgroundContextDidSave:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:localContext];

        saveBlock(localContext);

        if (localContext.hasChanges) {

            [self updateLastUpdateDateInConformedUpdatedObjects:localContext];

            NSError *error = nil;
            BOOL success = [localContext save:&error];
            if (!success) {
                NSLog(@"Saving in foreign context failed. %@", error.userInfo);
            }
        }
    }
}

- (void)backgroundContextDidSave:(NSNotification *)note {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
    });
}

- (void)updateLastUpdateDateInConformedUpdatedObjects:(NSManagedObjectContext *)localContext {
    for (NSManagedObject *updatedObject in localContext.updatedObjects) {
        if ([self hasPropertyNamed:kAutomaticLastUpdatePropertyName managedObject:updatedObject]) {
            [updatedObject setValue:[NSDate date] forKey:kAutomaticLastUpdatePropertyName];
        }
    }
}

- (BOOL)hasPropertyNamed:(NSString *)objectKey managedObject:(NSManagedObject *)updatedObject {
    return [updatedObject.entity.propertiesByName objectForKey:objectKey] != nil;
}


- (void)saveDataInBackgroundInForeignContext:(void (^)(NSManagedObjectContext *))saveBlock {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    dispatch_async(delegate.dispatcher.dataSavingQueue, ^{
        [self saveDataInForeignContext:saveBlock];
    });
}

- (void)saveDataInBackgroundInForeignContext:(void (^)(NSManagedObjectContext *))saveBlock completion:(void (^)(void))completion {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    dispatch_async(delegate.dispatcher.dataSavingQueue, ^{
        [self saveDataInForeignContext:saveBlock];

        dispatch_sync(dispatch_get_main_queue(), ^{
            completion();
        });
    });
}


- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
