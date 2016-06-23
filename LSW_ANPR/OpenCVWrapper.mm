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
//    cv::RotatedRect maxRect2 = cv::minAreaRect(maxContour);
    cv::rectangle(cvImage, maxRect, cv::Scalar(255),-1);
    //截取车牌矩形图片
    cv::Mat licencePlate;
    originImage(maxRect).copyTo(licencePlate);
    
    
//    return MatToUIImage(cvImage);
    return MatToUIImage(licencePlate);
}

+ (UIImage *)convertBGR2GRAY:(UIImage*)inputImage {
    cv::Mat cvImage;
    UIImageToMat(inputImage, cvImage);
    // do your processing here ...
    cv::cvtColor(cvImage, cvImage, CV_BGR2GRAY);
    cv::threshold(cvImage, cvImage, 0, 255, CV_THRESH_OTSU+CV_THRESH_BINARY);
    
    return MatToUIImage(cvImage);
}
+ (UIImage *)reprocessImageWithOpenCV:(UIImage*)inputImage {
    cv::Mat cvImage;
    UIImageToMat(inputImage, cvImage);
    cv::Mat image;
    cv::cvtColor(cvImage, image, CV_GRAY2BGR);//为了使画出来的矩形框显出颜色。
    
    vector<vector<cv::Point>> contours;
    NSMutableArray *characterRectValues = [[NSMutableArray alloc] init];
    cv::findContours(cvImage, contours, CV_RETR_EXTERNAL, CV_CHAIN_APPROX_NONE);
    for (size_t index = 0; index < contours.size(); index++) {
        cv::Rect rect = cv::boundingRect(contours[index]);
        if ((rect.height > cvImage.size().height*0.5)&&(rect.width > rect.height*0.4)) {
            cv::rectangle(image, rect, cv::Scalar(0,255,0),1);
            CGRect myRect = CGRectMake(rect.x, rect.y, rect.width, rect.height);
            NSValue *value = [NSValue valueWithCGRect:myRect];
            [characterRectValues addObject:value];
        }
    }
    cout<<contours.size()<<endl;
    printf("最初识别出的矩形框数目%d",[characterRectValues count]);

    return MatToUIImage(image);
}

+ (NSMutableArray *)findRectsInGRAYFromPlate:(UIImage*)plateImage{
    static NSMutableArray *originCharRects = [NSMutableArray array];
    [originCharRects removeAllObjects];
    cv::Mat cvImage;
    UIImageToMat(plateImage, cvImage);
    // do your processing here ...
    
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
    cout<<contours.size();
    printf("%d",[originCharRects count]);
    return originCharRects;
}


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