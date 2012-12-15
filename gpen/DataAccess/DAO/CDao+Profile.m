//
//  CDao+Profile.m
//  gpen
//
//  Created by fredformout on 28.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CDao+Profile.h"

@implementation CDao (Profile)

- (NSArray *)allProfiles
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	[request setEntity:[NSEntityDescription entityForName:@"Profile"
                                   inManagedObjectContext:self.dataContext]];
    
	NSError *error = nil;
	NSArray *result = [self.dataContext executeFetchRequest:request error:&error];
    
	if (result == nil)
	{
		NSLog(@"Method <%@> failed: %@", NSStringFromSelector(_cmd), error);
	}
    
	return result;
}

- (Profile *)profileForData:(NSArray *)data
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	[request setEntity:[NSEntityDescription entityForName:@"Profile"
                                   inManagedObjectContext:self.dataContext]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"name =[c] %@ AND patronymic =[c] %@ AND lastname =[c] %@ AND license =[c] %@ AND birthday = %@", [data objectAtIndex:0], [data objectAtIndex:1], [data objectAtIndex:2], [data objectAtIndex:3], [data objectAtIndex:4]]];
    
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

- (Profile *)profileForUid:(NSNumber *)uid
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	[request setEntity:[NSEntityDescription entityForName:@"Profile"
                                   inManagedObjectContext:self.dataContext]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"uid = %@", uid]];
    
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

- (Profile *)lastSignProfile
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	[request setEntity:[NSEntityDescription entityForName:@"Profile"
                                   inManagedObjectContext:self.dataContext]];
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"lastSign" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObjects:sd, nil]];
    
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

- (NSNumber *)uidForNewProfile
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	[request setEntity:[NSEntityDescription entityForName:@"Profile"
                                   inManagedObjectContext:self.dataContext]];
    
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"uid" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObjects:sd, nil]];
    
	NSError *error = nil;
	NSArray *result = [self.dataContext executeFetchRequest:request error:&error];
    
	if (result == nil)
	{
		NSLog(@"Method <%@> failed: %@", NSStringFromSelector(_cmd), error);
	}
    else if ([result count] > 0)
    {
        return [NSNumber numberWithInt:[((Profile *)[result objectAtIndex:0]).uid intValue] + 1];
    }
    
    return [NSNumber numberWithInt:1];
}

- (NSArray *)profilesForLicense:(NSString *)license
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	[request setEntity:[NSEntityDescription entityForName:@"Profile"
                                   inManagedObjectContext:self.dataContext]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"license =[c] %@", license]];
    
	NSError *error = nil;
	NSArray *result = [self.dataContext executeFetchRequest:request error:&error];
    
	if (result == nil)
	{
		NSLog(@"Method <%@> failed: %@", NSStringFromSelector(_cmd), error);
        result = [NSArray array];
	}
    
	return result;
}

@end
