//
//  OpenCVWrapper.m
//  LSW_ANPR
//
//  Created by Linsw on 16/6/13.
//  Copyright © 2016年 Linsw. All rights reserved.
//

#import "OpenCVWrapper.h"
#import "opencv2/imgcodecs/ios.h"
#include <opencv2/opencv.hpp>

using namespace cv;
using namespace std;
@implementation OpenCVWrapper : NSObject

+ (UIImage *)cutOutPlate:(UIImage*)inputImage {
    //转换到Mat ，保留原始图片副本
    
    cv::Mat originImage;
    cv::Mat cvImage;
    UIImageToMat(inputImage, originImage);
    
//    UIImage *iimage = [self convertBGR2GRAY:inputImage];
//    UIImageToMat(iimage, cvImage);

    originImage.copyTo(cvImage);
    //转换到灰度空间，经膨胀腐蚀，再转化为二值图像，并进行形态学转化。
    cv::cvtColor(cvImage, cvImage, CV_BGR2GRAY);
    cv::blur(cvImage, cvImage, cv::Size(5,5));
    cv::Sobel(cvImage, cvImage, CV_8U, 1, 0);
    cv::dilate(cvImage, cvImage, cv::getStructuringElement(CV_SHAPE_RECT, cv::Size(3,1)),cv::Point(-1,-1),15);
    cv::erode(cvImage, cvImage, cv::getStructuringElement(CV_SHAPE_RECT, cv::Size(1,3)),cv::Point(-1,-1),5);
    cv::threshold(cvImage, cvImage, 0, 255, CV_THRESH_OTSU+CV_THRESH_BINARY);
    cv::morphologyEx(cvImage, cvImage, CV_MOP_CLOSE, cv::getStructuringElement(MORPH_RECT, cv::Size(15,1)));
    
    //通过连通区域检测找到车牌矩形
    vector<vector<cv::Point>> contours;
    cv::findContours(cvImage, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    double maxArea = 0;
    vector<cv::Point> maxContour;
    for (size_t index = 0; index < contours.size(); index++) {
        double area = cv::contourArea(contours[index]);
        if (area > maxArea){
            cv::Rect rect = cv::boundingRect(contours[index]);
            if ((rect.width/rect.height > 3.0)&&(rect.width/rect.height < 7)) {
                maxArea = area;
                maxContour = contours[index];
            } else {
                continue;
            }
        }
    }
    assert(maxArea != 0);
    cv::Rect maxRect = cv::boundingRect(maxContour);
    cv::rectangle(cvImage, maxRect, cv::Scalar(255),-1);
    //截取车牌矩形图片
    cv::Mat licencePlate;
    originImage(maxRect).copyTo(licencePlate);
    
    return MatToUIImage(licencePlate);
}

+ (NSMutableArray *)findRectsInBGRPlate:(UIImage*)plateImage{
    NSMutableArray *originCharRects = [[NSMutableArray alloc] init];
    cv::Mat cvImage;
    UIImageToMat(plateImage, cvImage);
    cv::cvtColor(cvImage, cvImage, CV_BGR2GRAY);
    cv::threshold(cvImage, cvImage, 0, 255, CV_THRESH_OTSU+CV_THRESH_BINARY);
    
    vector<vector<cv::Point>> contours;
    cv::findContours(cvImage, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    for (size_t index = 0; index < contours.size(); index++) {
        cv::Rect bounding = cv::boundingRect(contours[index]);
        if ((bounding.height > cvImage.size().height*0.5)&&(bounding.width > bounding.height*0.4)) {
            CGRect myRect = CGRectMake(bounding.x, bounding.y, bounding.width, bounding.height);
            NSValue *value = [NSValue valueWithCGRect:myRect];
            [originCharRects addObject:value];
        }
    }
    
//    originCharRects = [self getAllRectsFromOriginRects:originCharRects];
    originCharRects = [self sortArray:originCharRects];
    return originCharRects;
}

+ (UIImage *)drawRectangles:(NSMutableArray *)rectArray inBGRImage:(UIImage *)inputImage{
    cv::Mat cvImage;
    UIImageToMat(inputImage, cvImage);
//    cv::cvtColor(cvImage, cvImage, CV_GRAY2BGR);
    
    for (id value in rectArray) {
        CGRect rect = [value CGRectValue];
        cv::Rect cvRect = cv::Rect(rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
        cv::rectangle(cvImage, cvRect, cv::Scalar(255,0,0),1);
    }
    return MatToUIImage(cvImage);
    
}

//MARK: Helper
+ (NSMutableArray *)sortArray:(NSMutableArray *)array{
    for (size_t i = 0; i < [array count] - 1; i++) {
        CGRect rect = [array[i] CGRectValue];
        for (size_t j = 1;i+j < [array count];j++){
            CGRect nextRect = [array[i+j] CGRectValue];
            if (rect.origin.x > nextRect.origin.x) {
                NSValue *swap = array[i];
                array[i] = array[i+j];
                array[i+j] = swap;
            }
            
        }
    }
    return array;
}

+ (UIImage *)convertBGR2GRAY:(UIImage*)inputImage {
    cv::Mat cvImage;
    UIImageToMat(inputImage, cvImage);
    // do your processing here ...
    cv::cvtColor(cvImage, cvImage, CV_BGR2GRAY);
    cv::threshold(cvImage, cvImage, 0, 255, CV_THRESH_OTSU+CV_THRESH_BINARY);
    
    return MatToUIImage(cvImage);
}

//MARK: USELESS

+ (UIImage *)reprocessImageWithOpenCV:(UIImage*)inputImage {
    
    NSMutableArray *characterRectValue = [OpenCVWrapper findRectsInBGRPlate:inputImage];
    printf("识别出的矩形框数目%d",[characterRectValue count]);
    
    return [self drawRectangles:characterRectValue inBGRImage:inputImage];
    
}

+ (NSMutableArray *)addChineseCharRectToArray:(NSMutableArray *)rectArray{
    
    //获取最大的矩形框宽和高
    CGSize rectSize = CGSizeMake(0, 0);
    for (id rectValue in rectArray){
        CGRect rect = [rectValue CGRectValue];
        if (rect.size.width > rectSize.width) {
            rectSize.width = rect.size.width;
        }
        if (rect.size.height > rectSize.height) {
            rectSize.height = rect.size.height;
        }
    }
    
    CGFloat spacing = 0;
    for (size_t index = 1; index < [rectArray count]-1; index++) {
        CGRect rect = [rectArray[index] CGRectValue];
        CGRect nextRect = [rectArray[index+1] CGRectValue];
        spacing += nextRect.origin.x + nextRect.size.width/2 - (rect.origin.x + rect.size.width/2);
    }
    spacing = spacing / ([rectArray count]-2);
    
    CGRect firstEnglishCharRect = [rectArray[0] CGRectValue];
    CGRect chineseCharRect = CGRectMake(firstEnglishCharRect.origin.x+firstEnglishCharRect.size.width/2-spacing-rectSize.width/2, firstEnglishCharRect.origin.y+firstEnglishCharRect.size.height/2-rectSize.height/2, rectSize.width, rectSize.height);
    
    [rectArray insertObject:[NSValue valueWithCGRect:chineseCharRect]atIndex:0];
    
    
    assert([rectArray count] == 7);
    return rectArray;
}
//*
+ (NSMutableArray *)getAllRectsFromOriginRects:(NSMutableArray *)originRects{
    //从得到的若干个矩形框复原出所有的字符矩形框
    originRects = [self sortArray:originRects];
    
    if ([originRects count] < 6) {
        printf("初始识别出的矩形个数太少，个数是：%d",[originRects count]);
        return originRects;
    }else{
        while ([originRects count] > 6) {
            [originRects removeObjectAtIndex:0];
        }
        return [self addChineseCharRectToArray:originRects];
    }
    
}
//*/
//Test
+ (UIImage *)cutImageWithOpenCV:(UIImage*)inputImage{
    cv::Rect rect1 = cv::Rect(0,0,300,200);
    cv::Mat cvImage;
    UIImageToMat(inputImage, cvImage);
    cv::Mat image;
    cvImage(rect1).copyTo(image);

//    return MatToUIImage(cvImage);
    return MatToUIImage(image);

}


@end