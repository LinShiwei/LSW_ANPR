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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let a = Tensor(shape: [2, 3], elements: [1, 2, 3, 4, 5, 6])
        // Do any additional setup after loading the view, typically from a nib.
        let image = UIImage(named: "sample3")
        let plate = OpenCVWrapper.cutOutPlate(image)
        firstImageView.image = OpenCVWrapper.convertBGR2GRAY(plate)

        var array = OpenCVWrapper.findRectsInBGRPlate(plate)
        print(array.count)
        array = getAllRectsFromOriginRects(array)
        print(array.count)
        secondImageView.image = OpenCVWrapper.drawRectangles(array, inBGRImage: plate)
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
            addChineseCharRectToArray(originRects)
        }
        return originRects
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

