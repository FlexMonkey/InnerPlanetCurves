//
//  Orrery.swift
//  InnerPlanetCurves
//
//  Created by Simon Gladman on 04/05/2016.
//  Copyright © 2016 Simon Gladman. All rights reserved.
//

import GLKit
import UIKit

class Orrery: GLKView
{
    let eaglContext = EAGLContext(API: .OpenGLES2)
    
    lazy var ciContext: CIContext =
    {
        return CIContext(
            EAGLContext: self.eaglContext,
            options: [kCIContextWorkingColorSpace: NSNull()])
    }()
    
    let imageAccumulator: CIImageAccumulator
    let obritsShapeLayer = CAShapeLayer()
    
    let mercury = Planet(orbitRadius: 58, yearLength: 88, angle: 0)
    let venus = Planet(orbitRadius: 108, yearLength: 225, angle: CGFloat(M_PI_2))
    let earth = Planet(orbitRadius: 149, yearLength: 365, angle: CGFloat(M_PI))
    let mars = Planet(orbitRadius: 227, yearLength: 687, angle: CGFloat(M_PI + M_PI_2))
    
    let planets: [Planet]
    
    let composite = CIFilter(
        name: "CIAdditionCompositing",
        withInputParameters: nil)
    
    lazy var displayLink: CADisplayLink =
    {
        let displayLink = CADisplayLink(
            target: self,
            selector: #selector(Orrery.step))
        
        displayLink.addToRunLoop(
            NSRunLoop.mainRunLoop(),
            forMode: NSDefaultRunLoopMode)
        
        displayLink.paused = true
        
        return displayLink
    }()
    
    var dimmingKernel = CIColorKernel(string:
        "kernel vec4 color(__sample pixel)" +
        "{ return highp pixel - 0.0025 ; }"
    )
    
    override init(frame: CGRect)
    {
        planets = [mercury, venus, earth, mars]
        
        imageAccumulator = CIImageAccumulator(extent: frame, format: kCIFormatARGB8)
        
        super.init(frame: frame)
        
        context = self.eaglContext
        delegate = self
        
        contentScaleFactor = 1
        
        layer.addSublayer(obritsShapeLayer)

        obritsShapeLayer.lineWidth = 2
        obritsShapeLayer.strokeColor = UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 0.75).CGColor
        obritsShapeLayer.fillColor = nil
        obritsShapeLayer.shadowColor = UIColor.yellowColor().CGColor
        obritsShapeLayer.shadowOffset = CGSize(width: 0, height: 0)
        obritsShapeLayer.shadowRadius = 3
        obritsShapeLayer.shadowOpacity = 0.5
        
        displayLink.paused = false
    }
    
    func step()
    {
        let backgroundSize = frame.size
        let orbitsPath = UIBezierPath()

        orbitsPath.moveToPoint(venus.position(backgroundSize))
        orbitsPath.addCurveToPoint(
            earth.position(backgroundSize),
            controlPoint1: mercury.position(backgroundSize),
            controlPoint2: mars.position(backgroundSize))
        
        obritsShapeLayer.path = orbitsPath.CGPath
        
        planets.forEach
        {
            $0.increment()
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: self.frame.width, height: self.frame.height), false, 1)
        
        if let ctx = UIGraphicsGetCurrentContext()
        {
            self.obritsShapeLayer.renderInContext(ctx)
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            
            self.composite?.setValue(self.imageAccumulator.image(), forKey: kCIInputBackgroundImageKey)
            self.composite?.setValue(CIImage(image: image), forKey: kCIInputImageKey)
            
            self.imageAccumulator.setImage(self.composite!.outputImage!)
            
            dispatch_async(dispatch_get_main_queue())
            {
                self.setNeedsDisplay()
            }
        }
        
        UIGraphicsEndImageContext()

    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Orrery: GLKViewDelegate
{
    func glkView(view: GLKView, drawInRect rect: CGRect)
    {
        let dimmed = dimmingKernel?.applyWithExtent(
            imageAccumulator.image().extent,
            arguments: [imageAccumulator.image()])
        
        imageAccumulator.setImage(dimmed!)
        
        ciContext.drawImage(
            imageAccumulator.image(),
            inRect: imageAccumulator.image().extent,
            fromRect: imageAccumulator.image().extent)
    }
}

class Planet
{
    let orbitRadius: CGFloat
    let yearLength: CGFloat
    var angle: CGFloat
    
    init(orbitRadius: CGFloat, yearLength: CGFloat, angle: CGFloat)
    {
        self.orbitRadius = orbitRadius
        self.yearLength = yearLength
        self.angle = angle
    }
    
    func increment()
    {
        angle -= (365 / yearLength) * 0.025
    }
    
    func position(backgroundSize: CGSize) -> CGPoint
    {
        let scale = (max(backgroundSize.width, backgroundSize.height)) / 687 * 2; print(scale)
        
        let centre: CGPoint = CGPoint(
            x: backgroundSize.width / 2,
            y: backgroundSize.height / 2)
        
        return CGPoint(
            x: centre.x + sin(angle) * orbitRadius * scale,
            y: centre.y + cos(angle) * orbitRadius * scale)
    }
    
}
