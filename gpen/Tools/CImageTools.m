//
//  CImageTools.m
//  gpen
//
//  Created by fredformout on 14.02.13.
//  Copyright (c) 2013 XP.Guild. All rights reserved.
//

#import "CImageTools.h"

@implementation CImageTools

+ (UIImage *)imageWithImage:(UIImage *)image convertToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

@end
