//
//  CUpdater.m
//  gpen
//
//  Created by fredformout on 26.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CUpdater.h"
#import "JSONKit.h"
#import "AppDelegate.h"
#import "Penalty.h"
#import "Recipient.h"
#import "CDao.h"
#import "CDao+Penalty.h"

@implementation CUpdater

+ (void)updatePenaltiesForProfile:(Profile *)profile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PenaltiesUpdateBegin" object:nil];
    });
    
    NSString* params = [NSString stringWithFormat:@"method=getOffenceVO&content[name]=%@&content[patronymic]=%@&content[surname]=%@&content[license]=%@&content[birthday]=%@",
                        @"МАНСУР", @"МАРАТОВИЧ", @"АЮХАНОВ", @"63ВК026167", @"1955-01-14"];
    
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    [df setDateFormat:@"yyyy-MM-dd"];
//    NSString* params = [NSString stringWithFormat:@"method=getOffenceVO&content[name]=%@&content[patronymic]=%@&content[surname]=%@&content[license]=%@&content[birthday]=%@",
//                        [profile.name stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [profile.patronymic stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [profile.lastname stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [profile.license  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[df stringFromDate:profile.birthday] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSDictionary *results = [self parsedJSONFromUrl:@"http://public.samregion.ru/services/lawBreakerAdapter.php" params:params];
    
    if (results == nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PenaltiesUpdateEnd" object:nil];
        });
        
        return;
    }
    
    NSArray *penalties = [results valueForKey:@"content"];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [delegate.dataAccessManager saveDataInBackgroundInForeignContext:^(NSManagedObjectContext *context) {
        [self processContent:penalties profile:profile context:context];
    } completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PenaltiesUpdateEnd" object:nil];
        });
    }];
}

+ (void)processContent:(NSArray *)penalties profile:(Profile *)profile context:(NSManagedObjectContext *)context
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CDao *dao = [CDao daoWithContext:delegate.dataAccessManager.managedObjectContext];
    
    NSDateFormatter *dfForDateTime = [[NSDateFormatter alloc] init];
    [dfForDateTime setDateFormat:@"dd.MM.yyyy HH:mm"];
    
    for (NSDictionary *penaltyObj in penalties)
    {
        if ([dao penaltyForUid:[[penaltyObj valueForKey:@"id"] stringValue]] == nil)
        {
            Penalty *penalty = [NSEntityDescription insertNewObjectForEntityForName:@"Penalty" inManagedObjectContext:context];
            
            penalty.profile = profile;
            penalty.uid = [[penaltyObj valueForKey:@"id"] stringValue];
            penalty.date = [dfForDateTime dateFromString:[NSString stringWithFormat:@"%@ %@", [penaltyObj valueForKey:@"date"], [penaltyObj valueForKey:@"time"]]];
            penalty.overdueDate = [dfForDateTime dateFromString:[penaltyObj valueForKey:@"overdueDateTime"]];
            penalty.price = [[penaltyObj valueForKey:@"price"] stringValue];
            penalty.status = [penaltyObj valueForKey:@"status"];
            penalty.carNumber = [penaltyObj valueForKey:@"carNumber"];
            
            if (![[penaltyObj valueForKey:@"photo"] isEqualToString:@""])
            {
                penalty.photo = [self savePhotoToDocsFromUrl:[penaltyObj valueForKey:@"photo"] penaltyUid:penalty.uid];
            }
            else
            {
                penalty.photo = [penaltyObj valueForKey:@"photo"];
            }
            
            penalty.roadName = [penaltyObj valueForKey:@"roadName"];
            penalty.roadPosition = [[penaltyObj valueForKey:@"roadPosition"] stringValue];
            penalty.fixedSpeed = [[penaltyObj valueForKey:@"fixedSpeed"] stringValue];
            penalty.reportId = [penaltyObj valueForKey:@"reportId"];
            penalty.issueKOAP = [penaltyObj valueForKey:@"issueKOAP"];
            penalty.fixedLicenseId = [penaltyObj valueForKey:@"fixedLicenseId"];
            penalty.catcher = [penaltyObj valueForKey:@"catcher"];
            
            NSDictionary *recipientObj = [penaltyObj valueForKey:@"recipient"];
            Recipient *recipient = [NSEntityDescription insertNewObjectForEntityForName:@"Recipient" inManagedObjectContext:context];
            
            recipient.penalty = penalty;
            recipient.uid = [[penaltyObj objectForKey:@"id"] stringValue];
            recipient.administratorCode = [recipientObj objectForKey:@"administratorCode"];
            recipient.name = [recipientObj objectForKey:@"name"];
            recipient.account = [recipientObj objectForKey:@"account"];
            recipient.inn = [recipientObj objectForKey:@"INN"];
            recipient.kpp = [recipientObj objectForKey:@"KPP"];
            recipient.okato = [recipientObj objectForKey:@"OKATO"];
            recipient.kbk = [recipientObj objectForKey:@"KBK"];
            recipient.bank = [recipientObj objectForKey:@"bank"];
            recipient.billTitle = [recipientObj objectForKey:@"billTitle"];
        }
        else
        {
            continue;
        }
    }
}

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
