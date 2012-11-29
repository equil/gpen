//
//  CUpdateUtility.h
//  gpen
//
//  Created by fredformout on 28.11.12.
//  Copyright (c) 2012 XP.Guild. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CUpdateUtility : NSObject

+ (NSDictionary *)parsedJSONFromUrl:(NSString *)url method:(NSString *)method params:(NSDictionary *)params;
+ (NSString *)savePhotoToDocsFromUrl:(NSString *)url penaltyUid:(NSNumber *)uid;
+ (void)saveDataInDocumentDirectory:(NSData *)data path:(NSString *)path;

@end
