//
//  ViewController.swift
//  LSW_ANPR
//
//  Created by Linsw on 16/6/13.
//  Copyright © 2016年 Linsw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var comparedImageView: UIImageView!
    @IBOutlet weak var resultImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let image = UIImage(named: "sample3")
        resultImageView.image = OpenCVWrapper.processImageWithOpenCV(image)
        comparedImageView.image = OpenCVWrapper.reprocessImageWithOpenCV(resultImageView.image)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

