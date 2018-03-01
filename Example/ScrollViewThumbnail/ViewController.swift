//
//  ViewController.swift
//  ScrollViewThumbnail
//
//  Created by TBXark on 03/01/2018.
//  Copyright (c) 2018 TBXark. All rights reserved.
//

import UIKit
import ScrollViewThumbnail


class ViewController: UIViewController, UIScrollViewDelegate {

    let scrollview: UIScrollView = {
        let sv = UIScrollView()
        sv.minimumZoomScale = 0.5
        sv.maximumZoomScale = 20
        sv.contentSize = CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2)
        sv.frame = UIScreen.main.bounds
        return sv
    }()

    let control: UIImageView = {
       let v = UIImageView(image: UIImage(named: "avatar"))
        v.frame = CGRect(x: 0,
                         y: (UIScreen.main.bounds.height - UIScreen.main.bounds.width)/2,
                         width: UIScreen.main.bounds.width,
                         height: UIScreen.main.bounds.width)
        return v
    }()
    let svt = ScrollViewThumbnailView(frame: CGRect(x: 20, y: UIScreen.main.bounds.height - 200, width: 180, height: 180))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        scrollview.delegate = self
        
        view.addSubview(scrollview)
        view.addSubview(svt)
        scrollview.addSubview(control)

        
        svt.bindScrollView(scrollview)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return control
    }
}

