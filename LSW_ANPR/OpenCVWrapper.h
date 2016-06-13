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
    + (UIImage *)processImageWithOpenCV:(UIImage*)inputImage;
    + (UIImage *)reprocessImageWithOpenCV:(UIImage*)inputImage;
@end
