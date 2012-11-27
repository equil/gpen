//
//  CDao+Recipient.m
//  gpen
//
//  Created by fredformout on 28.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CDao+Recipient.h"

@implementation CDao (Recipient)

- (NSArray *)allRecipients
{
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
	[request setEntity:[NSEntityDescription entityForName:@"Recipient"
                                   inManagedObjectContext:self.dataContext]];
    
	NSError *error = nil;
	NSArray *result = [self.dataContext executeFetchRequest:request error:&error];
    
	if (result == nil)
	{
		NSLog(@"Method <%@> failed: %@", NSStringFromSelector(_cmd), error);
	}
    
	return result;
}

@end
