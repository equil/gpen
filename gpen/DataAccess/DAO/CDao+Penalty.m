//
//  CDao+Penalty.m
//  gpen
//
//  Created by fredformout on 28.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CDao+Penalty.h"

@implementation CDao (Penalty)

- (NSArray *)allPenalties
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	[request setEntity:[NSEntityDescription entityForName:@"Penalty"
                                   inManagedObjectContext:self.dataContext]];
    
	NSError *error = nil;
	NSArray *result = [self.dataContext executeFetchRequest:request error:&error];
    
	if (result == nil)
	{
		NSLog(@"Method <%@> failed: %@", NSStringFromSelector(_cmd), error);
	}
    
	return result;
}

- (NSArray *)allPenaltiesForProfile:(Profile *)profile
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	[request setEntity:[NSEntityDescription entityForName:@"Penalty"
                                   inManagedObjectContext:self.dataContext]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"profile = %@", profile]];
    
	NSError *error = nil;
	NSArray *result = [self.dataContext executeFetchRequest:request error:&error];
    
	if (result == nil)
	{
		NSLog(@"Method <%@> failed: %@", NSStringFromSelector(_cmd), error);
	}
    
	return result;
}

- (Penalty *)penaltyForUid:(int)uid
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	[request setEntity:[NSEntityDescription entityForName:@"Penalty"
                                   inManagedObjectContext:self.dataContext]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"uid = %d", uid]];
    
	NSError *error = nil;
	NSArray *result = [self.dataContext executeFetchRequest:request error:&error];
    
	if (result == nil)
	{
		NSLog(@"Method <%@> failed: %@", NSStringFromSelector(_cmd), error);
	}
    else if ([result count] > 0)
    {
        return [result objectAtIndex:0];
    }
    
    return nil;
}

@end
