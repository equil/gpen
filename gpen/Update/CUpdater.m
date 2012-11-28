//
//  CUpdater.m
//  gpen
//
//  Created by fredformout on 26.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CUpdater.h"
#import "AppDelegate.h"
#import "CUpdateUtility.h"
#import "Penalty.h"
#import "Recipient.h"
#import "CDao.h"
#import "CDao+Penalty.h"

@implementation CUpdater

@synthesize profile = _profile;
@synthesize dateFormatter = _dateFormatter;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
    }
    
    return self;
}

- (status)updatePenaltiesForProfile:(Profile *)profile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PenaltiesUpdateBegin" object:nil];
    });
    
    status requestStatus;
    _profile = profile;
    
    NSArray *objects = [NSArray arrayWithObjects:@"МАНСУР", @"МАРАТОВИЧ", @"АЮХАНОВ", @"63ВК026167", @"1955-01-14", nil];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
//    NSArray *objects = [NSArray arrayWithObjects:
//                        [[profile.name uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[profile.patronymic uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[profile.lastname uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[profile.license uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[df stringFromDate:profile.birthday] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], nil];
    
    NSArray *keys = [NSArray arrayWithObjects:@"name", @"patronymic", @"surname", @"license", @"birthday", nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

    //    NSString* params = [NSString stringWithFormat:@"method=getOffenceVO&content[name]=%@&content[patronymic]=%@&content[surname]=%@&content[license]=%@&content[birthday]=%@",
//                        [[profile.name uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[profile.patronymic uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[profile.lastname uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[profile.license uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[df stringFromDate:profile.birthday] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSDictionary *results = [CUpdateUtility parsedJSONFromUrl:@"http://public.samregion.ru/services/lawBreakerAdapter.php" method:@"getOffenceVO" params:params];
    
    if (results != nil)
    {
        requestStatus = [self checkStatus:[[results valueForKey:@"status"] intValue]];
        switch (requestStatus) {
            case GOOD:
            {
                NSArray *penalties = [results valueForKey:@"content"];
                
                AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                
                [delegate.dataAccessManager saveDataInBackgroundInForeignContext:^(NSManagedObjectContext *context) {
                    [self processContent:penalties context:context];
                } completion:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"PenaltiesUpdateEnd" object:nil];
                    });
                }];
            }
                break;
                
            case NOTFOUND:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Введены неверные данные водителя" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PenaltiesUpdateEnd" object:nil];
                });
            }
                break;
                
            case UNAVAILABLE:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"В данный момент сервер доступен" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"PenaltiesUpdateEnd" object:nil];
                });
            }
                break;
                
            default:
                break;
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PenaltiesUpdateEnd" object:nil];
        });
        
        requestStatus = UNAVAILABLE;
    }
    
    return requestStatus;
}

- (status)checkStatus:(int)status
{
    NSLog(@"status %d", status);
    if (status >= 200 && status < 400)
    {
        return GOOD;
    }
    else if (status >= 400 && status < 500)
    {
        return NOTFOUND;
    }
    
    return UNAVAILABLE;
}

- (void)processContent:(NSArray *)penalties context:(NSManagedObjectContext *)context
{
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CDao *dao = [CDao daoWithContext:delegate.dataAccessManager.managedObjectContext];
    
    for (NSDictionary *penaltyObj in penalties)
    {
        if ([dao penaltyForUid:[penaltyObj valueForKey:@"id"]] == nil)
        {
            [self insertPenalty:penaltyObj context:context];
        }
        else
        {
            continue;
        }
    }
}

- (void)insertPenalty:(NSDictionary *)penaltyObj context:(NSManagedObjectContext *)context
{
    Penalty *penalty = [NSEntityDescription insertNewObjectForEntityForName:@"Penalty" inManagedObjectContext:context];
    
    penalty.profile = _profile;
    penalty.uid = [penaltyObj valueForKey:@"id"];
    penalty.date = [_dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", [penaltyObj valueForKey:@"date"], [penaltyObj valueForKey:@"time"]]];
    penalty.overdueDate = [_dateFormatter dateFromString:[penaltyObj valueForKey:@"overdueDateTime"]];
    penalty.price = [penaltyObj valueForKey:@"price"];
    penalty.status = [penaltyObj valueForKey:@"status"];
    penalty.carNumber = [penaltyObj valueForKey:@"carNumber"];
    
    if (![[penaltyObj valueForKey:@"photo"] isEqualToString:@""])
    {
        penalty.photo = [CUpdateUtility savePhotoToDocsFromUrl:[penaltyObj valueForKey:@"photo"] penaltyUid:penalty.uid];
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
    Recipient *recipient = [NSEntityDescription insertNewObjectForEntityForName:@"Recipient" inManagedObjectContext:context];
    
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

@end
