//
//  ViewController.swift
//  MonkeyPinch
//
//  Created by Harol Higuera on 9/29/16.
//  Copyright © 2016 Harol Higuera. All rights reserved.
//

import UIKit
import AVFoundation



class ViewController: UIViewController,  UIGestureRecognizerDelegate {
    
    @IBOutlet var monkeyPan: UIPanGestureRecognizer!
    @IBOutlet var bananaPan: UIPanGestureRecognizer!
    
    var chompPlayer:AVAudioPlayer?
    var ringPlayer:AVAudioPlayer?
    
    
    
    
    func loadSound(filename:NSString) -> AVAudioPlayer {
        
        let url = Bundle.main.path(forResource: filename as String, ofType: "mp3")
     
        print("URL: \(url)")
        do{
            chompPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: url!))
            chompPlayer?.prepareToPlay()
            
        }catch {
        
        }
        return chompPlayer!
    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        //1 Create a filtered array of just the monkey and banana image views.
        //let filteredSubviews = self.view.subviews.filter({$0.isKind(of: UIImageView.self)})
        let filteredSubviews = self.view.subviews.flatMap({$0 as? UIImageView})
        
        // 2 Cycle through the filtered array
        for view in filteredSubviews  {
            // 3  Create a UITapGestureRecognizer for each image view, specifying the callback. This is an alternative way of adding gesture recognizers. It can be added the recognizers to the storyboard.
            let recognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            // 4 Set the delegate of the recognizer programatically, and add the recognizer to the image view.
            recognizer.delegate = self
            view.addGestureRecognizer(recognizer)
            
            //TODO: Add a custom gesture recognizer too
            
            let recognizer2 = TickleGestureRecognizer(target: self, action: #selector(handleTickle))
            recognizer2.delegate = self
            view.addGestureRecognizer(recognizer2)

            
            // Now the tap gesture recognizer will only get called if no pan is detected.
            
            recognizer.require(toFail: monkeyPan)
            recognizer.require(toFail: bananaPan)
            
            
                   }
        
        self.chompPlayer = self.loadSound(filename: "Mario")
        self.ringPlayer = self.loadSound(filename: "ring")
    }

    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

    
    
    @IBAction func handlePan(recognizer:UIPanGestureRecognizer) {
        
        let translation = recognizer.translation(in: self.view)
        
        if let view = recognizer.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                                  y:view.center.y + translation.y)
        }
        recognizer.setTranslation(CGPoint(x : 0, y : 0), in: self.view)
        
        
        
        
        if recognizer.state == UIGestureRecognizerState.ended {
            // 1
            let velocity = recognizer.velocity(in: self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 200
            
            print("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
            
            // 2
            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
            // 3
            var finalPoint = CGPoint(x:recognizer.view!.center.x + (velocity.x * slideFactor),
                                     y:recognizer.view!.center.y + (velocity.y * slideFactor))
            // 4
            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
            
            // 5
            UIView.animate(withDuration: Double(slideFactor * 2),
                                       delay: 0,
                                       
            // 6
            options: UIViewAnimationOptions.curveEaseOut,
            animations: {recognizer.view!.center = finalPoint },
            completion: nil)
        }
        
    }

    
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    @IBAction func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = view.transform.rotated(by: recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    
    // MARK: UIGestureRecogniserDelegate Functions
    
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: Callbacks
    
    func handleTap(recognizer: UITapGestureRecognizer) {
        self.chompPlayer?.play()
    }
    
    
    func handleTickle(recognizer:TickleGestureRecognizer) {
        self.ringPlayer?.play()
    }
    
    
}

