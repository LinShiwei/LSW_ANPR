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

+ (NSMutableArray *)findRectsInBGRPlate:(UIImage*)plateImage;
+ (NSMutableArray *)getAllRectsFromOriginRects:(NSMutableArray*)originRects;
+ (UIImage *)drawRectangles:(NSMutableArray*)rectArray inBGRImage:(UIImage*)inputImage;
+ (NSMutableArray *)addChineseCharRectToArray:(NSMutableArray*)rectArray;
+ (NSMutableArray *)sortArray:(NSMutableArray*)array;
+ (UIImage *)cutOutCharFrom:(UIImage*)inputImage withRectValue:(NSValue*)rectValue;

@end
