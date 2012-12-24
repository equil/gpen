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
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"%@ in profiles", profile]];
    
	NSError *error = nil;
	NSArray *result = [self.dataContext executeFetchRequest:request error:&error];
    
	if (result == nil)
	{
		NSLog(@"Method <%@> failed: %@", NSStringFromSelector(_cmd), error);
	}
    
	return result;
}

- (Penalty *)penaltyForUid:(NSNumber *)uid
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	[request setEntity:[NSEntityDescription entityForName:@"Penalty"
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

- (NSArray *)allPenaltiesOverdueAfterDate:(NSDate *)date
{
    int interval = 3 * 24 * 60 * 60;
    
    NSDateComponents *dc = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    NSDateComponents *timerDcBefore = [[NSDateComponents alloc] init];
    [timerDcBefore setYear:[dc year]];
    [timerDcBefore setMonth:[dc month]];
    [timerDcBefore setDay:[dc day] + interval];
    [timerDcBefore setHour:0];
    [timerDcBefore setMinute:0];
    
    NSDateComponents *timerDcAfter = [[NSDateComponents alloc] init];
    [timerDcAfter setYear:[dc year]];
    [timerDcAfter setMonth:[dc month]];
    [timerDcAfter setDay:[dc day] + interval + 1];
    [timerDcAfter setHour:0];
    [timerDcAfter setMinute:0];
    
    NSDate *before = [[NSCalendar currentCalendar] dateFromComponents:timerDcBefore];
    NSDate *after = [[NSCalendar currentCalendar] dateFromComponents:timerDcAfter];
    
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	[request setEntity:[NSEntityDescription entityForName:@"Penalty"
                                   inManagedObjectContext:self.dataContext]];
    
    [request setPredicate:[NSPredicate predicateWithFormat:@"overdueDate >= %@ AND overdueDate <= %@ AND notified == %@", before, after, [NSNumber numberWithBool:NO]]];
    
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
