//
//  CDao.m
//  eor
//
//  Created by fredformout on 11.10.12.
//  Copyright (c) 2012 Андрей Иванов. All rights reserved.
//

#import "CDao.h"
#import "AppDelegate.h"

@implementation CDao

@synthesize dataContext = dataContext_;

+ (CDao *)daoWithContext:(NSManagedObjectContext *)dataContext
{
	return [[self alloc] initWithContext:dataContext];
}

- (NSManagedObjectModel *)dataModel
{
	return [AppDelegate current].dataAccessManager.managedObjectModel;
}

- (id)initWithContext:(NSManagedObjectContext *)dataContext {
	if (self = [super init]) {
		dataContext_ = [dataContext retain];
	}
	
	return self;
}

@end
