//
//  WelcomeBackViewController.swift
//  gebaarNL
//
//  Created by Angelica Dewi on 04/01/2021.
//

import UIKit
import Lottie

class WelcomeBackViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet var backgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var animationView: AnimationView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // Set up title label.
        titleLabel.text = "welkom terug!"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 48)
        titleLabel.textColor = #colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1)
        
        // Set up description.
        descriptionLabel.text = "Ga verder waar we gebleven zijn, het eiland wacht op ons."
        descriptionLabel.font = UIFont.systemFont(ofSize: 30)
        descriptionLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        // Set up animation.
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        animationView.play()
        
        // Initialize tap gesture.
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapped(gestureRecognizer:)))
        backgroundView.addGestureRecognizer(tapRecognizer)
        tapRecognizer.delegate = self
    }
    
    @objc func tapped(gestureRecognizer: UITapGestureRecognizer) {
        // Go to Map View Controller.
        performSegue(withIdentifier: "goToMapView", sender: self)
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
