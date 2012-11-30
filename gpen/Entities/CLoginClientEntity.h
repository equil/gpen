//
//  CLoginClientEntity.h
//  gpen
//
//  Created by Ilya Khokhlov on 30.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLoginClientEntity : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *surname;
@property (nonatomic, strong) NSString *patronymic;
@property (nonatomic, strong) NSString *license;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSString *email;

@property (nonatomic, readonly) NSDictionary *dict;

- (id) initWithDictionary: (NSDictionary *) aDictionary;

@end
