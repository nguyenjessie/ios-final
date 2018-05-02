//
//  ColorPicker.swift
//  HexDropper
//
//  Created by Kenny Yeung on 5/2/18.
//  Copyright © 2018 Kenny + Jessie. All rights reserved.
//

import UIKit
import AVFoundation

class ColorPickerViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var image: UIImageView!
    var point: CGPoint? = nil
    
    func getLocation(view: UIImageView, touch: UITouch) {
        point = touch.location(in: image)
    }
    
    func getColor(view: UIImageView, point: CGPoint) {
        //from video
    }
    
    func convert(red: Int, green: Int, blue: Int){
        
    }
    
    @IBAction func pixelTap(_ sender: Any) {
        print("image tapped")
    }
    
    
}
