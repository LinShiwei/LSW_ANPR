//
//  TestViewController.swift
//  LSW_ANPR
//
//  Created by Linsw on 16/7/11.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var imageView5: UIImageView!
    @IBOutlet weak var imageView6: UIImageView!
    @IBOutlet weak var imageView7: UIImageView!
    
    @IBOutlet weak var imageView8: UIImageView!
    @IBOutlet weak var imageView9: UIImageView!
    @IBOutlet weak var imageView10: UIImageView!
    @IBOutlet weak var imageView11: UIImageView!
    @IBOutlet weak var imageView12: UIImageView!
    @IBOutlet weak var imageView13: UIImageView!
    @IBOutlet weak var imageView14: UIImageView!
    
    @IBOutlet weak var imageView15: UIImageView!
    @IBOutlet weak var imageView16: UIImageView!
    @IBOutlet weak var imageView17: UIImageView!
    @IBOutlet weak var imageView18: UIImageView!
    @IBOutlet weak var imageView19: UIImageView!
    @IBOutlet weak var imageView20: UIImageView!
    @IBOutlet weak var imageView21: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let imageViews = [imageView1,imageView2,imageView3,imageView4,imageView5,imageView6,imageView7,
                imageView8,imageView9,imageView10,imageView11,imageView12,imageView13,imageView14,
            imageView15,imageView16,imageView17,imageView18,imageView19,imageView20,imageView21
        ]
        for column in 0...2 {
            let name = "sample" + String(column + 27)
            let image = UIImage(named: name)
            let plate = OpenCVWrapper.cutOutPlate(image)
            let array = getAllRectsFromOriginRects(OpenCVWrapper.findRectsInBGRPlate(plate))
            if array.count != 7 {
                continue
            }
            for index in 0...6 {
                let cutImage = OpenCVWrapper.cutOutCharFrom(plate, withRectValue: array[index] as! NSValue)
                imageViews[index + column * 7].image = OpenCVWrapper.convertBGR2GRAY(cutImage)
            }
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prefersStatusBarHidden() -> Bool {
        return true
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
       
        let firstEnglishCharRect = rects[0]
        let originPoint = CGPoint(x: firstEnglishCharRect.origin.x+firstEnglishCharRect.size.width/2-spacing-rectSize.width/2, y:firstEnglishCharRect.origin.y+firstEnglishCharRect.size.height/2-rectSize.height/2)
        let chineseCharRect = CGRect(origin: originPoint, size: rectSize)
        
        rectValueArray.insertObject(NSValue(CGRect:chineseCharRect), atIndex: 0)
        assert(rectValueArray.count == 7)
    }

}
