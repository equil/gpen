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

@implementation CUpdater

+ (void)updatePenaltiesForProfile:(Profile *)profile
{
//    NSString* params = [NSString stringWithFormat:@"method=getOffenceVO&content[name]=%@&content[patronymic]=%@&content[surname]=%@&content[license]=%@&content[birthday]=%@",
//                        @"МАНСУР", @"МАРАТОВИЧ", @"АЮХАНОВ", @"63ВК026167", @"1955-01-14"];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    NSString* params = [NSString stringWithFormat:@"method=getOffenceVO&content[name]=%@&content[patronymic]=%@&content[surname]=%@&content[license]=%@&content[birthday]=%@",
                        profile.name, profile.patronymic, profile.lastname, profile.license, [df stringFromDate:profile.birthday]];
    
    NSDictionary *results = [self parsedJSONFromUrl:@"http://public.samregion.ru/services/lawBreakerAdapter.php" withParams:params];
    
    NSArray *penalties = [results valueForKey:@"content"];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDateFormatter *dfForDateTime = [[NSDateFormatter alloc] init];
    [dfForDateTime setDateFormat:@"dd.MM.yyyy HH:mm"];
    
    for (NSDictionary *penaltyObj in penalties)
    {
        //нужна еще проверка на существование
        Penalty *penalty = [NSEntityDescription insertNewObjectForEntityForName:@"Penalty" inManagedObjectContext:delegate.dataAccessManager.managedObjectContext];
        
        penalty.profile = profile;
        penalty.uid = [penaltyObj valueForKey:@"id"];
        penalty.date = [dfForDateTime dateFromString:[NSString stringWithFormat:@"%@ %@", [penaltyObj valueForKey:@"date"], [penaltyObj valueForKey:@"time"]]];
        penalty.overdueDate = [dfForDateTime dateFromString:[penaltyObj valueForKey:@"overdueDateTime"]];
        penalty.price = [penaltyObj valueForKey:@"price"];
        penalty.status = [penaltyObj valueForKey:@"status"];
        penalty.carNumber = [penaltyObj valueForKey:@"carNumber"];
        
        if (![[penaltyObj valueForKey:@"photo"] isEqualToString:@""])
        {
            penalty.photo = [self savePhotoToDocsFromUrl:[penaltyObj valueForKey:@"photo"] forPenaltyUid:penalty.uid];
        }
        else
        {
            penalty.photo = [penaltyObj valueForKey:@"photo"];
        }
        
        penalty.roadName = [penaltyObj valueForKey:@"roadName"];
        penalty.roadPosition = [penaltyObj valueForKey:@"roadPosition"];
        penalty.fixedSpeed = [penaltyObj valueForKey:@"fixedSpeed"];
        penalty.reportId = [penaltyObj valueForKey:@"reportId"];
        penalty.issueKOAP = [penaltyObj valueForKey:@"issueKOAP"];
        penalty.fixedLicenseId = [penaltyObj valueForKey:@"fixedLicenseId"];
        penalty.catcher = [penaltyObj valueForKey:@"catcher"];
        
        NSDictionary *recipientObj = [penaltyObj valueForKey:@"recipient"];
        Recipient *recipient = [NSEntityDescription insertNewObjectForEntityForName:@"Recipient" inManagedObjectContext:delegate.dataAccessManager.managedObjectContext];
        
        recipient.penalty = penalty;
        recipient.uid = [penaltyObj objectForKey:@"id"];
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
    
    [delegate.dataAccessManager saveState];
}

+ (NSDictionary *)parsedJSONFromUrl:(NSString *)url withParams:(NSString *)params
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
		NSLog(@"Error performing request %@", url);
		return nil;
	}
    
	NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSDictionary *results = [jsonString objectFromJSONString];
    
    return results;
}

+ (NSString *)savePhotoToDocsFromUrl:(NSString *)url forPenaltyUid:(NSString *)uid
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
    [self saveDataInDocumentDirectory:data toPath:path];
    return path;
}

+ (void)saveDataInDocumentDirectory:(NSData *)data toPath:(NSString *)path
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, path];
    [data writeToFile:fullPath atomically:NO];
}

@end
