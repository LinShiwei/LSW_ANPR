//
//  ViewController.swift
//  LSW_ANPR
//
//  Created by Linsw on 16/6/13.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var firstImageView: UIImageView!
    @IBOutlet weak var secondImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let image = UIImage(named: "sample3")
        let plate = OpenCVWrapper.cutOutPlate(image)
        firstImageView.image = OpenCVWrapper.checkPlate(plate)
//        comparedImageView.image = OpenCVWrapper.reprocessImageWithOpenCV(resultImageView.image)
        
        secondImageView.image = OpenCVWrapper.reprocessImageWithOpenCV(firstImageView.image)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

