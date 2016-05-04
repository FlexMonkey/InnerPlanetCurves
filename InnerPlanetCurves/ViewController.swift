//
//  ViewController.swift
//  InnerPlanetCurves
//
//  Created by Simon Gladman on 03/05/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import UIKit
import GLKit

class ViewController: UIViewController
{
    lazy var orrery: Orrery =
    {
        let side = min(self.view.frame.width, self.view.frame.height)
        
        return Orrery(frame: CGRect(x: 0, y: 0, width: side, height: side))
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor()
        
        view.addSubview(orrery)
    }
    
    override func prefersStatusBarHidden() -> Bool
    {
        return true
    }
    
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        orrery.frame.origin.x = view.bounds.midX - orrery.frame.width / 2
        orrery.frame.origin.y = view.bounds.midY - orrery.frame.height / 2
    }
}

