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
#import "CDao+Profile.h"

@implementation CUpdater

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

- (Profile *)createProfile:(NSManagedObjectContext *)context dict:(NSDictionary *)dict
{
    CDao *dao = [CDao daoWithContext:context];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    Profile *profile = [NSEntityDescription insertNewObjectForEntityForName:@"Profile" inManagedObjectContext:context];
    profile.uid = [dao uidForNewProfile];
    profile.name = [dict valueForKey:@"name"];
    profile.patronymic = [dict valueForKey:@"patronymic"];
    profile.lastname = [dict valueForKey:@"surname"];
    profile.license = [dict valueForKey:@"license"];
    profile.birthday = [df dateFromString:[dict valueForKey:@"birthday"]];
    profile.email = [dict valueForKey:@"email"];
    profile.lastSign = [NSDate date];
    profile.lastUpdate = [NSDate date];
    return profile;
}

- (status)insertNewProfileAndUpdate:(NSDictionary *)dict
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingStart" object:nil];
    });
    
    status requestStatus;
    
//    NSArray *objects = [NSArray arrayWithObjects:@"МАНСУР", @"МАРАТОВИЧ", @"АЮХАНОВ", @"63ВК026167", @"1955-01-14", nil];
    
    
    //JSON
    
    
//    NSArray *objects = [NSArray arrayWithObjects:
//                        [[[dict valueForKey:@"name"] uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[[dict valueForKey:@"patronymic"] uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[[dict valueForKey:@"surname"] uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[[dict valueForKey:@"license"] uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[dict valueForKey:@"birthday"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], nil];
//    
//    NSArray *keys = [NSArray arrayWithObjects:@"name", @"patronymic", @"surname", @"license", @"birthday", nil];
//    
//    NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

//    NSDictionary *results = [CUpdateUtility parsedJSONFromUrl:@"http://public.samregion.ru/services/lawBreakerAdapter.php" method:@"getList" params:params];    
    
    
    //POST
    
    
    NSString* params = [NSString stringWithFormat:@"method=getList&content[name]=%@&content[patronymic]=%@&content[surname]=%@&content[license]=%@&content[birthday]=%@",
                        [[[dict valueForKey:@"name"] uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        [[[dict valueForKey:@"patronymic"] uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        [[[dict valueForKey:@"surname"] uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        [[[dict valueForKey:@"license"] uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        [[dict valueForKey:@"birthday"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *results = [CUpdateUtility parsedJSONFromUrl:@"http://public.samregion.ru/services/lawBreakerAdapter.php" params:params];
    
    
    

    
    if (results != nil)
    {
        requestStatus = [self checkStatus:[[results valueForKey:@"status"] intValue]];
        if (requestStatus == GOOD)
        {
            NSArray *penalties = [results valueForKey:@"content"];
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [delegate.dataAccessManager saveDataInForeignContext:^(NSManagedObjectContext *context) {
                
                Profile *profile = [self createProfile:context dict:dict];
                [self processContent:penalties profile:profile context:context];
                
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil];
            });
        }
        else
        {
            [self handleBadStatus:requestStatus message:[results valueForKey:@"message"]];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil];
        });
        
        requestStatus = UNAVAILABLE;
    }
    
    return requestStatus;
}

- (status)updateProfile:(Profile *)profile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingStart" object:nil];
    });
    
    status requestStatus;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    //NSArray *objects = [NSArray arrayWithObjects:@"МАНСУР", @"МАРАТОВИЧ", @"АЮХАНОВ", @"63ВК026167", @"1955-01-14", nil];
    
    
    //JSON
    
    
//    NSArray *objects = [NSArray arrayWithObjects:
//                        [[profile.name uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[profile.patronymic uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[profile.lastname uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[profile.license uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[df stringFromDate:profile.birthday] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], nil];
//
//    NSArray *keys = [NSArray arrayWithObjects:@"name", @"patronymic", @"surname", @"license", @"birthday", nil];
//    
//    NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//    
//    NSDictionary *results = [CUpdateUtility parsedJSONFromUrl:@"http://public.samregion.ru/services/lawBreakerAdapter.php" method:@"getList" params:params];
    
    
    //POST
    
    
    NSString* params = [NSString stringWithFormat:@"method=getList&content[name]=%@&content[patronymic]=%@&content[surname]=%@&content[license]=%@&content[birthday]=%@",
                        [[profile.name uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        [[profile.patronymic uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        [[profile.lastname uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        [[profile.license uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        [[df stringFromDate:profile.birthday] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *results = [CUpdateUtility parsedJSONFromUrl:@"http://public.samregion.ru/services/lawBreakerAdapter.php" params:params];
    
    
    
    
    
    unsigned long uid = [profile.uid unsignedLongValue];
    if (results != nil)
    {
        requestStatus = [self checkStatus:[[results valueForKey:@"status"] intValue]];
        if (requestStatus == GOOD)
        {
            NSArray *penalties = [results valueForKey:@"content"];
            
            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [delegate.dataAccessManager saveDataInBackgroundInForeignContext:^(NSManagedObjectContext *context) {
                
                CDao *dao = [CDao daoWithContext:context];
                Profile *prof = [dao profileForUid:[NSNumber numberWithUnsignedLong:uid]];
                prof.lastUpdate = [NSDate date];
                
                [self processContent:penalties profile:prof context:context];
                
            } completion:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil];
                });
            }];
        }
        else
        {
            [self handleBadStatus:requestStatus message:[results valueForKey:@"message"]];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil];
        });
        
        requestStatus = UNAVAILABLE;
    }
    
    return requestStatus;
}

- (void)updateLastSignForProfile:(Profile *)profile
{
    unsigned long uid = [profile.uid unsignedLongValue];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.dataAccessManager saveDataInBackgroundInForeignContext:^(NSManagedObjectContext *context) {
        
        CDao *dao = [CDao daoWithContext:context];
        Profile *prof = [dao profileForUid:[NSNumber numberWithUnsignedLong:uid]];
        prof.lastSign = [NSDate date];
    }];
}

- (status)sendInfoToProfile:(Profile *)profile penalty:(Penalty *)penalty email:(NSString *)email
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingStart" object:nil];
    });
    
    status requestStatus;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    
    //JSON
    
    
//    NSArray *objects = [NSArray arrayWithObjects:
//                        [[profile.name uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[profile.patronymic uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[profile.lastname uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[profile.license uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [[df stringFromDate:profile.birthday] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
//                        penalty.uid, nil];
//    
//    NSArray *keys = [NSArray arrayWithObjects:@"name", @"patronymic", @"surname", @"license", @"birthday", @"email", @"id", nil];
//    
//    NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//    
//    NSDictionary *results = [CUpdateUtility parsedJSONFromUrl:@"http://public.samregion.ru/services/lawBreakerAdapter.php" method:@"sendInfoByEmail" params:params];
    
    
    //POST
    
    
    NSString* params = [NSString stringWithFormat:@"method=sendInfoByEmail&content[name]=%@&content[patronymic]=%@&content[surname]=%@&content[license]=%@&content[birthday]=%@&content[email]=%@&content[id]=%@",
                        [[profile.name uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        [[profile.patronymic uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        [[profile.lastname uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        [[profile.license uppercaseString] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        [[df stringFromDate:profile.birthday] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                        penalty.uid];
    NSDictionary *results = [CUpdateUtility parsedJSONFromUrl:@"http://public.samregion.ru/services/lawBreakerAdapter.php" params:params];
    
    
    
    
    
    if (results != nil)
    {
        requestStatus = [self checkStatus:[[results valueForKey:@"status"] intValue]];
        if (requestStatus == GOOD)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Выполнено" message:@"Информация о штрафе успешно отправлена на e-mail" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil];
            });
        }
        else
        {
            [self handleBadStatus:requestStatus message:[results valueForKey:@"message"]];
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil];
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

- (void)handleBadStatus:(status)requestStatus message:(NSString *)message
{
    switch (requestStatus)
    {
        case NOTFOUND:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    UIAlertView *alert;

//                    if ([message isEqualToString:@"Incorrect driver’s personal data"])
//                    {
//                        alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Неверные данные водителя" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    }
//                    else if ([message isEqualToString:@"Incorrect penalty id"])
//                    {
//                        alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Неверные данные штрафа" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//                    }
                    
                    alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Неверные данные" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    
                    [alert show];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil];
                });
            }
            break;
            
        case UNAVAILABLE:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"В данный момент сервер доступен" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil];
                });
            }
            break;
            
        default:
            break;
    }
}

- (void)processContent:(NSArray *)penalties profile:(Profile *)profile context:(NSManagedObjectContext *)context
{
    CDao *dao = [CDao daoWithContext:context];
    
    for (NSDictionary *penaltyObj in penalties)
    {
        if ([dao penaltyForUid:[penaltyObj valueForKey:@"id"]] == nil)
        {
            [self insertPenalty:penaltyObj profile:profile context:context];
        }
        else
        {
            continue;
        }
    }
}

- (void)addRecipient:(NSDictionary *)recipientObj context:(NSManagedObjectContext *)context penalty:(Penalty *)penalty
{
    Recipient *recipient = [NSEntityDescription insertNewObjectForEntityForName:@"Recipient" inManagedObjectContext:context];
    recipient.penalty = penalty;
    recipient.uid = penalty.uid;
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

- (NSString *)processStatus:(NSString *)status
{
    if ([status isEqualToString:@"overdue"])
    {
        return [NSString stringWithFormat:@"1_%@", status];
    }
    else if ([status isEqualToString:@"not paid"])
    {
        return [NSString stringWithFormat:@"2_%@", status];
    }
    else if ([status isEqualToString:@"paid"])
    {
        return [NSString stringWithFormat:@"3_%@", status];
    }
    
    return @"";
}

- (void)addPhoto:(NSDictionary *)penaltyObj penalty:(Penalty *)penalty
{
    if (![[penaltyObj valueForKey:@"photo"] isEqualToString:@""])
    {
        penalty.photo = [CUpdateUtility savePhotoToDocsFromUrl:[penaltyObj valueForKey:@"photo"] penaltyUid:penalty.uid];
    }
    else
    {
        penalty.photo = [penaltyObj valueForKey:@"photo"];
    }
}

- (void)insertPenalty:(NSDictionary *)penaltyObj profile:(Profile *)profile context:(NSManagedObjectContext *)context
{
    Penalty *penalty = [NSEntityDescription insertNewObjectForEntityForName:@"Penalty" inManagedObjectContext:context];
    
    penalty.profile = profile;
    penalty.uid = [penaltyObj valueForKey:@"id"];
    penalty.date = [_dateFormatter dateFromString:[NSString stringWithFormat:@"%@ %@", [penaltyObj valueForKey:@"date"], [penaltyObj valueForKey:@"time"]]];
    penalty.overdueDate = [_dateFormatter dateFromString:[penaltyObj valueForKey:@"overdueDateTime"]];
    penalty.price = [penaltyObj valueForKey:@"price"];
    penalty.status = [self processStatus:[penaltyObj valueForKey:@"status"]];
    penalty.carNumber = [penaltyObj valueForKey:@"carNumber"];
    
    [self addPhoto:penaltyObj penalty:penalty];
    
    penalty.roadName = [penaltyObj valueForKey:@"roadName"];
    penalty.roadPosition = [penaltyObj valueForKey:@"roadPosition"];
    penalty.fixedSpeed = [penaltyObj valueForKey:@"fixedSpeed"];
    penalty.reportId = [penaltyObj valueForKey:@"reportId"];
    penalty.issueKOAP = [penaltyObj valueForKey:@"issueKOAP"];
    penalty.fixedLicenseId = [penaltyObj valueForKey:@"fixedLicenseId"];
    penalty.catcher = [penaltyObj valueForKey:@"catcher"];
    
    [self addRecipient:[penaltyObj valueForKey:@"recipient"] context:context penalty:penalty];
}

//- (NSArray *)penaltiesForProfile:(Profile *)profile
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"PenaltiesStart" object:nil];
//    });
//    
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    NSManagedObjectContext *moc = delegate.dataAccessManager.managedObjectContext;
//    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:[NSEntityDescription entityForName:@"Penalty" inManagedObjectContext:moc]];
//    [request setPredicate:[NSPredicate predicateWithFormat:@"profile = %@", profile]];
//    
//    NSSortDescriptor *dateDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
//    [request setSortDescriptors:[NSArray arrayWithObject:dateDescriptor]];
//    
//    NSError *error = nil;
//    NSArray *array = [moc executeFetchRequest:request error:&error];
//    
//    NSMutableArray *result = [[NSMutableArray alloc] init];
//    
//    NSMutableArray *array1 = [[NSMutableArray alloc] init];
//    NSMutableArray *array2 = [[NSMutableArray alloc] init];
//    NSMutableArray *array3 = [[NSMutableArray alloc] init];
//    for (Penalty *penalty in array)
//    {
//        if ([@"overdue" isEqualToString:penalty.status]) {
//            [array1 addObject:penalty];
//        }
//        else if ([@"not paid" isEqualToString:penalty.status]) {
//            [array2 addObject:penalty];
//        }
//        else if ([@"paid" isEqualToString:penalty.status]) {
//            [array3 addObject:penalty];
//        }
//    }
//    [result addObject:array1];
//    [result addObject:array2];
//    [result addObject:array3];
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"penalies count is %i", [array count]);
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"PenaltiesEnd" object:nil];
//    });
//    
//    if (error)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка при запросе списка штрафов" message:nil delegate:nil cancelButtonTitle:@"ОК" otherButtonTitles:nil];
//            [alert show];
//        });
//    }
//
//    return result;
//}

@end
