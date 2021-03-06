//
//  CUpdateUtility.m
//  gpen
//
//  Created by fredformout on 28.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CUpdateUtility.h"
#import "JSONKit.h"

static NSString *kEmailMethodName = @"sendInfoByEmail";
static NSString *kSyncMethodName = @"getList";

@implementation CUpdateUtility

+ (NSDictionary *)parsedJSONFromUrl:(NSString *)url method:(NSString *)method params:(NSDictionary *)params
{
    NSString *userAgent = [NSString stringWithFormat:@"iOS GibddPenalty/%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]];
    
    NSArray *requestObjects = [NSArray arrayWithObjects:method, userAgent, params, nil];
    NSArray *requestKeys = [NSArray arrayWithObjects:@"method", @"userAgent", @"content", nil];
    NSDictionary *requestDict = [NSDictionary dictionaryWithObjects:requestObjects forKeys:requestKeys];
    
	NSError* error = nil;
	NSURLResponse* response = nil;

    NSString *jsonRequest = [requestDict JSONString];
    
//    NSLog(@"request to url: %@", url);
//    NSLog(@"JSON string: %@", jsonRequest);
    
    NSData *requestData = [jsonRequest dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
	NSURL* URL = [NSURL URLWithString:url];
	[request setURL:URL];
	[request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if (error)
	{
		NSLog(@"Error performing request %@, error: %@", url, error);
        if (error.code == -1009)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil userInfo:[NSDictionary dictionaryWithObject:@"UNAVAILABLE" forKey:@"status"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshEnd" object:nil];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Проверьте подключение к интернету" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            });
        }
        
		return nil;
	}
    else
    {
        NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *results = [jsonString objectFromJSONString];
        
//        NSLog(@"json string: %@", jsonString);
//        NSLog(@"results: %@", results);
        
        if (results == nil)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil userInfo:[NSDictionary dictionaryWithObject:@"INVALIDJSON" forKey:@"status"]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshEnd" object:nil];
                
                NSString *msg;
                
                if ([method isEqualToString:kEmailMethodName])
                {
                    msg = @"Не удалось отправить квитанцию на e-mail";
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    
                    [alert show];
                }
                else if ([method isEqualToString:kSyncMethodName])
                {
                    msg = @"Информация о штрафах этого профиля в данный момент недоступна";
                    //TODO - убрал alert
                }
            });
            
            return nil;
        }
        else
        {
            return results;
        }
    }
}

+ (NSDictionary *)parsedJSONFromUrl:(NSString *)url params:(NSString *)params
{   
	NSError* error = nil;
	NSURLResponse* response = nil;
    
//    NSLog(@"params: %@", params);
    
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
    
    NSArray *arr = [url componentsSeparatedByString:@"."];
    NSString *ext = [arr objectAtIndex:[arr count] - 1];
    
    NSString *path = [NSString stringWithFormat:@"photo-%@.%@", uid, ext];
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
