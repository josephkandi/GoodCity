//
//  EditItemViewController.swift
//  GoodCity
//
//  Created by Nick Aiwazian on 10/5/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//
import Foundation

@objc class EditItemViewController: UIViewController {

    @IBOutlet weak var imageBackground: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        println("view did load")
    }
    
    func setImageBackground(image: UIImageView) {
        imageBackground.image = UIImage(CGImage: image.image?.CGImage)
    }
    
    //override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    //    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil?)
    //}
    
    /*override init() {
        super.init()
        self.view.backgroundColor = UIColor.clearColor()
        let backView = UIView(frame: self.view.frame)
        backView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        self.view.addSubview(backView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/
}
