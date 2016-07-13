//
//  ViewController.swift
//  LSW_ANPR
//
//  Created by Linsw on 16/6/13.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit
import TensorSwift
class ViewController: UIViewController {

    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!

    private let inputSize = 28
    private let classifier = Classifier(path: NSBundle.mainBundle().resourcePath!)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let image = UIImage(named: "sample3")
        let plate = OpenCVWrapper.cutOutPlate(image)
        firstImageView.image = OpenCVWrapper.convertBGR2GRAY(plate)

        let array = getAllRectsFromOriginRects(OpenCVWrapper.findRectsInBGRPlate(plate))
        classify(plate: plate, withNSValueArray: array)
        let rectValue = array[4]
        let cutImage = OpenCVWrapper.cutOutCharFrom(plate, withRectValue: rectValue as! NSValue)
        
//        secondImageView.image = OpenCVWrapper.drawRectangles(array, inBGRImage: plate)
        secondImageView.image = OpenCVWrapper.convertBGR2GRAY(cutImage)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func getAllRectsFromOriginRects(originRects:NSMutableArray)->NSMutableArray{
        if originRects.count < 6 {
            print("初始识别出的矩形数目太少，只有\(originRects.count)个")
        }else{
            while originRects.count > 6 {
                originRects.removeObjectAtIndex(0)
            }
//            addChineseCharRectToArray(originRects)
        }
        return originRects
    }
    
    private func classify(plate plate:UIImage,withNSValueArray array:NSMutableArray)->String{
        var result = ""
        for rectValue in array.reverse(){
            if rectValue is NSValue {
                let image = OpenCVWrapper.cutOutCharFrom(plate, withRectValue: rectValue as! NSValue)
                let grayImage = OpenCVWrapper.convertBGR2GRAY(image)
                let cgImage = grayImage.CGImage
                var pixels = [UInt8](count: inputSize * inputSize, repeatedValue: 0)
                
                let context  = CGBitmapContextCreate(&pixels, inputSize, inputSize, 8, inputSize, CGColorSpaceCreateDeviceGray()!, CGBitmapInfo.ByteOrderDefault.rawValue)!
                CGContextClearRect(context, CGRect(x: 0.0, y: 0.0, width: CGFloat(inputSize), height: CGFloat(inputSize)))
                
                let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(inputSize), height: CGFloat(inputSize))
                CGContextDrawImage(context, rect, cgImage)
                let input : Tensor
                
                input = Tensor(shape: [Dimension(inputSize), Dimension(inputSize), 1], elements: pixels.map { (Float($0) / 255.0 )})
                //-(Float($0) / 255.0 - 0.5) + 0.5
                //(Float($0) / 255.0 )
                let resultInt = classifier.classify(input)
                result += String(resultInt)
            }
            
        }
        print("result is\(result)")
        return result
    }
    
    private func addChineseCharRectToArray(rectValueArray:NSMutableArray){
        var rects = [CGRect]()
        for value in rectValueArray {
            rects.append(value.CGRectValue)
        }
   
        var rectSize = CGSize(width: 0, height: 0)
        var spacing : CGFloat = 0
        for (index,rect) in rects.enumerate() {
            if rect.size.width > rectSize.width {
                rectSize.width = rect.size.width
            }
            if (rect.size.height > rectSize.height) {
                rectSize.height = rect.size.height;
            }
            if (index > 0)&&(index < rects.count-1) {
                spacing += rects[index+1].origin.x + rects[index+1].size.width/2 - (rect.origin.x + rect.size.width/2)
            }
        }
        spacing /= CGFloat(rects.count-2)
        print(spacing)
        print(rectSize)
        let firstEnglishCharRect = rects[0]
        let originPoint = CGPoint(x: firstEnglishCharRect.origin.x+firstEnglishCharRect.size.width/2-spacing-rectSize.width/2, y:firstEnglishCharRect.origin.y+firstEnglishCharRect.size.height/2-rectSize.height/2)
        let chineseCharRect = CGRect(origin: originPoint, size: rectSize)
        
        rectValueArray.insertObject(NSValue(CGRect:chineseCharRect), atIndex: 0)
        assert(rectValueArray.count == 7)
    }
}

