//
//  OpenCVWrapper.h
//  LSW_ANPR
//
//  Created by Linsw on 16/6/13.
//  Copyright © 2016年 Linsw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface OpenCVWrapper : NSObject
+ (UIImage *)cutOutPlate:(UIImage*)inputImage;
+ (UIImage *)convertBGR2GRAY:(UIImage*)inputImage;

+ (UIImage *)reprocessImageWithOpenCV:(UIImage*)inputImage;

+ (NSMutableArray *)findRectsFromPlate:(UIImage*)plateImage;

+ (UIImage *)cutImageWithOpenCV:(UIImage*)inputImage;

@end
