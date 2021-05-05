//
//  OnboardingViewController.swift
//  gebaarNL
//
//  Created by Angelica Dewi on 04/12/2020.
//

import UIKit
import Lottie

class OnboardingViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var storyLabel: UILabel!
    
    var tapCounter = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // 1. Set animation content mode
        animationView.contentMode = .scaleAspectFill
        // 2. Set animation loop mode
        animationView.loopMode = .loop
        // 3. Adjust animation speed
        animationView.animationSpeed = 1.2
        // 4. Play animation
        animationView.play(fromFrame: 0, toFrame: 67, loopMode: .loop, completion: .none)
        
        storyLabel.text = "Er was eens een Nederlander die zeilde en zeilde en zeilde…"
        

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        backgroundView.addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self
    }
    
    @objc func tapped(gestureRecognizer: UITapGestureRecognizer) {
        // Change text and animation based on tap counter.
        tapCounter += 1
        UIView.transition(with: storyLabel,
                      duration: 0.25,
                       options: .transitionCrossDissolve,
                    animations: {
                        if self.tapCounter == 1{
                            self.storyLabel.text = "totdat zij op een dag een nieuw eiland tegenkwam en het Gebarenland noemde"
                            self.animationView.play(fromFrame: 67, toFrame: 120, loopMode: .playOnce, completion: {(finished) in
                                if finished {
                                    self.animationView.play(fromFrame: 120, toFrame: 186, loopMode: .loop, completion: .none)
                                }
                            })
                        } else if self.tapCounter == 2{
                            self.storyLabel.text = "daar leerde zij een nieuwe taal, gebarentaal"
                            
                        }
                    }, completion: nil)
        if (tapCounter > 2){
            performSegue(withIdentifier: "goToMapView", sender: self)
        }
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
