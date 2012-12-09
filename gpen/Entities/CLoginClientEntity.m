//
//  CLoginClientEntity.m
//  gpen
//
//  Created by Ilya Khokhlov on 30.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import "CLoginClientEntity.h"

@interface CLoginClientEntity()
@property (nonatomic, strong) NSMutableDictionary *internalDict;
@end

@implementation CLoginClientEntity
@synthesize internalDict = _internalDict;

- (id) init
{
    self = [super init];
    if (self)
    {
        self.internalDict = [NSMutableDictionary dictionary];
        self.name = @"";
        self.surname = @"";
        self.patronymic = @"";
        self.nickname = @"";
        self.birthday = @"";
        self.license = @"";
        self.email = @"";
    }
    return self;
}

- (id) initWithDictionary: (NSDictionary *) aDictionary;
{
    self = [super init];
    if (self)
    {
        self.internalDict = [NSMutableDictionary dictionaryWithDictionary:aDictionary];
    }
    return self;
}

- (NSDictionary *) dict
{
    return [NSDictionary dictionaryWithDictionary:self.internalDict];
}

- (NSString *) name
{
    return [self.internalDict objectForKey:@"name"];
}

- (void) setName:(NSString *)name
{
    if (name)
    {
        [self.internalDict setObject:name forKey:@"name"];
    }
    else
    {
        [self.internalDict removeObjectForKey:@"name"];
    }
}

- (NSString *) surname
{
    return [self.internalDict objectForKey:@"surname"];
}

- (void) setSurname:(NSString *)surname
{
    if (surname)
    {
        [self.internalDict setObject:surname forKey:@"surname"];
    }
    else
    {
        [self.internalDict removeObjectForKey:@"surname"];
    }
}

- (NSString *) patronymic
{
    return [self.internalDict objectForKey:@"patronymic"];
}

- (void) setPatronymic:(NSString *)patronymic
{
    if (patronymic)
    {
        [self.internalDict setObject:patronymic forKey:@"patronymic"];
    }
    else
    {
        [self.internalDict removeObjectForKey:@"patronymic"];
    }
}

- (NSString *) license
{
    return [self.internalDict objectForKey:@"license"];
}

- (void) setLicense:(NSString *)license
{
    if (license)
    {
        [self.internalDict setObject:license forKey:@"license"];
    }
    else
    {
        [self.internalDict removeObjectForKey:@"license"];
    }
}

- (NSString *) email
{
    return [self.internalDict objectForKey:@"email"];
}

- (void) setEmail:(NSString *)email
{
    if (email)
    {
        [self.internalDict setObject:email forKey:@"email"];
    }
    else
    {
        [self.internalDict removeObjectForKey:@"email"];
    }
}

- (NSString *) birthday
{
    return [self.internalDict objectForKey:@"birthday"];
}

- (void) setBirthday:(NSString *)birthday
{
    if (birthday)
    {
        [self.internalDict setObject:birthday forKey:@"birthday"];
    }
    else
    {
        [self.internalDict removeObjectForKey:@"birthday"];
    }
}

- (NSString *) nickname
{
    return [self.internalDict objectForKey:@"nickname"];
}

- (void) setNickname:(NSString *)nickname
{
    if (nickname)
    {
        [self.internalDict setObject:nickname forKey:@"nickname"];
    }
    else
    {
        [self.internalDict removeObjectForKey:@"nickname"];
    }
}

@end
