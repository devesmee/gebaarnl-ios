//
//  PracticeResultViewController.swift
//  gebaarNL
//
//  Created by Esmee Kluijtmans on 10/12/2020.
//

import UIKit
import Lottie
import SAConfettiView
import AVFoundation

class PracticeResultViewController: UIViewController {
    
    @IBOutlet weak var practiceAgainButton: UIButton!
    @IBOutlet weak var toMapButton: UIButton!
    @IBOutlet weak var animationView: AnimationView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelPractice: UILabel!
    
    var previousViewController = ""
    var completedLevel = Level.none
    var score = 10;
    var timer = Timer()
    var timeLeft = 2
    var confettiView = SAConfettiView()
    let audioUrlSuccess = NSURL(fileURLWithPath: Bundle.main.path(forResource: "achievement", ofType: "mp3")!)
    let audioUrlFailure = NSURL(fileURLWithPath: Bundle.main.path(forResource: "not_achieved", ofType: "mp3")!)
    var audioPlayer = AVAudioPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        completedLevel = ProgressTracker.shared.GetCurrentLevel()
        
        // Set up UI
        setUpLabels()
        
        // Randomize encouragement animation
        animationView.animation = Animation.named(EncouragementAnimation.randomAnimation().rawValue)
        
        // Set up confetti & timer
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 1
        if(score >= 10 && previousViewController == "MiniGame" || score >= 10 && previousViewController == "PracticeLetter") {
            confettiView = SAConfettiView(frame: self.view.bounds)
            confettiView.type = .Confetti
            confettiView.isUserInteractionEnabled = true
            self.view.addSubview(confettiView)
            self.view.bringSubviewToFront(toMapButton)
            self.view.bringSubviewToFront(practiceAgainButton)
            confettiView.startConfetti()
            animationView.animation = Animation.named("explorer-happy")
            animationView.loopMode = .loop
            animationView.play()
        } else if (previousViewController == "LevelTest") {
            confettiView = SAConfettiView(frame: self.view.bounds)
            confettiView.type = .Confetti
            confettiView.isUserInteractionEnabled = true
            self.view.addSubview(confettiView)
            self.view.bringSubviewToFront(toMapButton)
            self.view.bringSubviewToFront(practiceAgainButton)
            confettiView.startConfetti()
            animationView.animation = Animation.named("sand-castle-finished")
            animationView.play(fromFrame: 5, toFrame: 200, loopMode: .playOnce, completion: {(finished) in
                if finished {
                    self.animationView.play(fromFrame: 100, toFrame: 200, loopMode: .loop, completion: .none)
                }
            })
        } else {
            animationView.loopMode = .loop
            animationView.play()
        }
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { timer in
            if self.timeLeft == 0 {
                timer.invalidate()
                self.confettiView.stopConfetti()
            } else {
                self.timeLeft -= 1
            }
        })
        
        // Set up audio player & play sound
        if(score >= 10 && previousViewController == "MiniGame" || score >= 10 && previousViewController == "PracticeLetter" || previousViewController == "LevelTest") {
            do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrlSuccess as URL)
            }
            catch {
                print("No file found")
            }
        } else {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: audioUrlFailure as URL)
            }
            catch {
                print("No file found")
            }
        }
        
        audioPlayer.play()
    }
    
    @IBAction func buttonsPressed(sender: UIButton){
        sender.backgroundColor = #colorLiteral(red: 0.7450980392, green: 0.8745098039, blue: 0.7254901961, alpha: 1)
        sender.setTitleColor(#colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1), for: .normal)
    }
    
    @IBAction func buttonsReleased(sender: UIButton){
        sender.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1)
        sender.setTitleColor(#colorLiteral(red: 0.7450980392, green: 0.8745098039, blue: 0.7254901961, alpha: 1), for: .normal)
    }
    
    func setUpLabels() {
        switch previousViewController {
        case "PracticeLetter":
            labelTitle.text = "Goed gedaan!"
            labelPractice.text = "Je hebt de letter " + ProgressTracker.shared.GetLetter(of: completedLevel) + " geleerd."
            break
        case "MiniGame":
            if(score < 10)
            {
                labelTitle.text = "Helaas! Volgende keer beter!"
                labelPractice.text = "Je had " + String(score) + " letters goed, maar \n je moet er 10 goed hebben."
            } else {
                labelTitle.text = "Goed gedaan!"
                labelPractice.text = "Je hebt de letters " + ProgressTracker.shared.GetLetter(of: completedLevel) + " geoefend."
            }
            break
        case "LevelTest":
            if(score < 26) {
                labelTitle.text = "Helaas! Volgende keer beter!"
                labelPractice.text = "Je had " + String(score) + " letters goed, maar \n je moet ze alle 26 goed hebben"
            } else {
                labelTitle.text = "Gefeliciteerd!"
                labelPractice.text = "Je hebt het level gehaald!"
                toMapButton.setTitle("Naar level 2!", for: .normal)
            }
            break
        default:
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if (segue.destination is MapViewController){
            if (score >= 10){
                ProgressTracker.shared.AddToCompletedLevels(level: completedLevel)
            }
            ProgressTracker.shared.SetCurrentLevel(to: .none)
        } else {
            switch previousViewController {
            case "MiniGame":
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let miniGameViewController = storyBoard.instantiateViewController(withIdentifier: "MiniGameViewController") as! MiniGameViewController
                miniGameViewController.modalPresentationStyle = .fullScreen
                miniGameViewController.currentLevel = self.completedLevel
                self.present(miniGameViewController, animated: true, completion: nil)
                break
            case "LevelTest":
                let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let miniGameViewController = storyboard.instantiateViewController(withIdentifier: "MiniGameViewController") as! MiniGameViewController
                miniGameViewController.modalPresentationStyle = .fullScreen
                miniGameViewController.currentLevel = self.completedLevel
                self.present(miniGameViewController, animated: true, completion: nil)
                break
            default:
            break
            }
        }
    }
    
}

