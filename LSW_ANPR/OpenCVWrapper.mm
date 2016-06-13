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
+ (UIImage *)processImageWithOpenCV:(UIImage*)inputImage {
    cv::Mat cvImage;
    UIImageToMat(inputImage, cvImage);
    // do your processing here ...
    cv::cvtColor(cvImage, cvImage, CV_BGR2GRAY);
//    cv::cvtColor(cvImage, cvImage, CV_BGR2HSV);
    cv::blur(cvImage, cvImage, cv::Size(5,5));
    cv::Sobel(cvImage, cvImage, CV_8U, 1, 0);
    cv::dilate(cvImage, cvImage, cv::getStructuringElement(CV_SHAPE_RECT, cv::Size(3,1)),cv::Point(-1,-1),5);
    cv::erode(cvImage, cvImage, cv::getStructuringElement(CV_SHAPE_RECT, cv::Size(1,3)),cv::Point(-1,-1),5);
    cv::threshold(cvImage, cvImage, 0, 255, CV_THRESH_OTSU+CV_THRESH_BINARY);
    cv::morphologyEx(cvImage, cvImage, CV_MOP_CLOSE, cv::getStructuringElement(MORPH_RECT, cv::Size(15,1)));
    return MatToUIImage(cvImage);
}
+ (UIImage *)reprocessImageWithOpenCV:(UIImage*)inputImage {
    cv::Mat cvImage;
    UIImageToMat(inputImage, cvImage);
    // do your processing here ...
    
    
    return MatToUIImage(cvImage);
}
@end