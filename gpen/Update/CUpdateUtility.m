//
//  CUpdateUtility.m
//  gpen
//
//  Created by fredformout on 28.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CUpdateUtility.h"
#import "JSONKit.h"

@implementation CUpdateUtility

+ (NSDictionary *)parsedJSONFromUrl:(NSString *)url params:(NSString *)params
{
	NSError* error = nil;
	NSURLResponse* response = nil;
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
	
	NSURL* URL = [NSURL URLWithString:url];
	[request setURL:URL];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if (error)
	{
		NSLog(@"Error performing request %@, error: %@", url, error);
        if (error.code == -1009)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Проверьте подключение к интернету" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            });
        }
        
		return nil;
	}
    
	NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary *results = [jsonString objectFromJSONString];
    
    return results;
}

+ (NSString *)savePhotoToDocsFromUrl:(NSString *)url penaltyUid:(NSString *)uid
{
    NSError* error = nil;
	NSURLResponse* response = nil;
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
	
	NSURL* URL = [NSURL URLWithString:url];
	[request setURL:URL];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:30];
	
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSString *path = [NSString stringWithFormat:@"photo-%@.jpg", uid];
    [self saveDataInDocumentDirectory:data path:path];
    return path;
}

+ (void)saveDataInDocumentDirectory:(NSData *)data path:(NSString *)path
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, path];
    [data writeToFile:fullPath atomically:NO];
}

@end
