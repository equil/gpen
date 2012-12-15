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
    profile.profileName = [dict valueForKey:@"profileName"];
    profile.lastSign = [NSDate distantPast];
    profile.lastUpdate = [NSDate distantPast];
    profile.checked = [NSNumber numberWithBool:NO];
    
    return profile;
}

- (Profile *)updateProfile:(Profile *)profile dict:(NSDictionary *)dict context:(NSManagedObjectContext *)context
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    if (![profile.name isEqualToString:[dict valueForKey:@"name"]] ||
        ![profile.patronymic isEqualToString:[dict valueForKey:@"patronymic"]] ||
        ![profile.lastname isEqualToString:[dict valueForKey:@"surname"]] ||
        ![profile.license isEqualToString:[dict valueForKey:@"license"]] ||
        ![[df stringFromDate:profile.birthday] isEqualToString:[dict valueForKey:@"birthday"]])
    {
        [self deleteAllForProfile:profile context:context];
        
        profile.checked = [NSNumber numberWithBool:NO];
        
        profile.name = [dict valueForKey:@"name"];
        profile.patronymic = [dict valueForKey:@"patronymic"];
        profile.lastname = [dict valueForKey:@"surname"];
        profile.license = [dict valueForKey:@"license"];
        profile.birthday = [df dateFromString:[dict valueForKey:@"birthday"]];
    }
    
    profile.email = [dict valueForKey:@"email"];
    profile.profileName = [dict valueForKey:@"profileName"];
    
    return profile;
}

- (void)insertProfile:(NSDictionary *)dict
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InsertProfileStart" object:nil];
    });
            
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [delegate.dataAccessManager saveDataInForeignContext:^(NSManagedObjectContext *context) {
        [self createProfile:context dict:dict];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"InsertProfileEnd" object:nil];
    });
}

- (void)editProfile:(Profile *)profile data:(NSDictionary *)dict
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditProfileStart" object:nil];
    });
    
    unsigned long uid = [profile.uid unsignedLongValue];
            
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [delegate.dataAccessManager saveDataInForeignContext:^(NSManagedObjectContext *context) {
        CDao *dao = [CDao daoWithContext:context];
        Profile *prof = [dao profileForUid:[NSNumber numberWithUnsignedLong:uid]];
        [self updateProfile:prof dict:dict context:context];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"EditProfileEnd" object:nil];
    });
}

- (status)syncProfile:(Profile *)profile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingStart" object:nil];
    });
    
    status requestStatus;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NSArray *objects = [NSArray arrayWithObjects:
                        [profile.name uppercaseString],
                        [profile.patronymic uppercaseString],
                        [profile.lastname uppercaseString],
                        [profile.license uppercaseString],
                        [df stringFromDate:profile.birthday], nil];

    NSArray *keys = [NSArray arrayWithObjects:@"name", @"patronymic", @"surname", @"license", @"birthday", nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    NSDictionary *results = [CUpdateUtility parsedJSONFromUrl:@"http://public.samregion.ru/services/lawBreakerAdapter.php" method:@"getList" params:params];
    
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
                prof.checked = [NSNumber numberWithBool:YES];
                
                [self processContent:penalties profile:prof context:context];
                prof.lastUpdate = [NSDate date];
                
            } completion:^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil userInfo:[NSDictionary dictionaryWithObject:@"GOOD" forKey:@"status"]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshEnd" object:nil];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil userInfo:[NSDictionary dictionaryWithObject:@"UNAVAILABLE" forKey:@"status"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshEnd" object:nil];
        });
        
        requestStatus = UNAVAILABLE;
    }
    
    return requestStatus;
}

- (void)updateLastSignForProfile:(Profile *)profile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LastSignUpdateStart" object:nil];
    });
    
    unsigned long uid = [profile.uid unsignedLongValue];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.dataAccessManager saveDataInBackgroundInForeignContext:^(NSManagedObjectContext *context) {
        CDao *dao = [CDao daoWithContext:context];
        Profile *prof = [dao profileForUid:[NSNumber numberWithUnsignedLong:uid]];
        prof.lastSign = [NSDate date];
    } completion:^{
        [delegate actualizeMainProfile];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LastSignUpdateEnd" object:nil];
        });
    }];
}

- (void)setNewPenaltiesCountForLicense:(NSString *)license count:(unsigned long)count
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NewPenaltiesUpdateStart" object:nil];
    });
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.dataAccessManager saveDataInBackgroundInForeignContext:^(NSManagedObjectContext *context) {
        CDao *dao = [CDao daoWithContext:context];
        NSArray *profiles = [dao profilesForLicense:license];
        
        for (Profile *p in profiles) {
            p.newPenaltiesCount = [NSNumber numberWithUnsignedLong:count];
        }
    } completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NewPenaltiesUpdateEnd" object:nil];
        });
    }];
}

- (void)setNewPenaltiesCountForProfile:(Profile *)profile count:(unsigned long)count
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetPenaltiesUpdateStart" object:nil];
    });
    
    unsigned long uid = [profile.uid unsignedLongValue];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.dataAccessManager saveDataInBackgroundInForeignContext:^(NSManagedObjectContext *context) {
        CDao *dao = [CDao daoWithContext:context];
        Profile *prof = [dao profileForUid:[NSNumber numberWithUnsignedLong:uid]];
        prof.newPenaltiesCount = [NSNumber numberWithUnsignedLong:count];
    } completion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetPenaltiesUpdateEnd" object:nil];
        });
    }];
}

- (void)deleteProfile:(Profile *)profile
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"DeletingStart" object:nil];
    });
    
    unsigned long uid = [profile.uid unsignedLongValue];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate.dataAccessManager saveDataInBackgroundInForeignContext:^(NSManagedObjectContext *context) {
        CDao *dao = [CDao daoWithContext:context];
        Profile *prof = [dao profileForUid:[NSNumber numberWithUnsignedLong:uid]];
        [self deleteAllForProfile:prof context:context];
        [context deleteObject:prof];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DeletingEnd" object:nil];
        });
    }];
}

- (void)deleteAllForProfile:(Profile *)profile context:(NSManagedObjectContext *)context
{
    for (Penalty *p in profile.penalties)
    {
        [context deleteObject:p.recipient];
        [context deleteObject:p];
    }
}

- (status)sendInfoToProfile:(Profile *)profile penalty:(Penalty *)penalty email:(NSString *)email
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingStart" object:nil];
    });
    
    status requestStatus;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd"];
    
    NSArray *objects = [NSArray arrayWithObjects:
                        [profile.name uppercaseString],
                        [profile.patronymic uppercaseString],
                        [profile.lastname uppercaseString],
                        [profile.license uppercaseString],
                        [df stringFromDate:profile.birthday],
                        penalty.uid,
                        email, nil];
    
    NSArray *keys = [NSArray arrayWithObjects:@"name", @"patronymic", @"surname", @"license", @"birthday", @"id", @"email", nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    NSDictionary *results = [CUpdateUtility parsedJSONFromUrl:@"http://public.samregion.ru/services/lawBreakerAdapter.php" method:@"sendInfoByEmail" params:params];
    
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
                    
                    alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Похоже, вы указали в профиле неточную информацию, ГИБДД не известен водитель с таким именем и номером водительского удостоверения. Вернитесь в \"Профили\" и проверьте указанную информацию." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    
                    [alert show];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil userInfo:[NSDictionary dictionaryWithObject:@"NOTFOUND" forKey:@"status"]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshEnd" object:nil];
                });
            }
            break;
            
        case UNAVAILABLE:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"В данный момент сервер не доступен" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadingEnd" object:nil userInfo:[NSDictionary dictionaryWithObject:@"UNAVAILABLE" forKey:@"status"]];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshEnd" object:nil];
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

@end
