//
//  MapViewController.swift
//  gebaarNL
//
//  Created by Angelica Dewi on 03/12/2020.
//

import UIKit
import Lottie
import AVFoundation

enum Direction {
    case LR, RL, BT, BL, BR, LT, RT
}

class MapViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var dialogView: UIView!
    
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    @IBOutlet weak var buttonE: UIButton!
    @IBOutlet weak var buttonF: UIButton!
    @IBOutlet weak var buttonG: UIButton!
    @IBOutlet weak var buttonH: UIButton!
    @IBOutlet weak var buttonI: UIButton!
    @IBOutlet weak var buttonJ: UIButton!
    @IBOutlet weak var buttonK: UIButton!
    @IBOutlet weak var buttonL: UIButton!
    @IBOutlet weak var buttonM: UIButton!
    @IBOutlet weak var buttonN: UIButton!
    @IBOutlet weak var buttonO: UIButton!
    @IBOutlet weak var buttonP: UIButton!
    @IBOutlet weak var buttonQ: UIButton!
    @IBOutlet weak var buttonR: UIButton!
    @IBOutlet weak var buttonS: UIButton!
    @IBOutlet weak var buttonT: UIButton!
    @IBOutlet weak var buttonU: UIButton!
    @IBOutlet weak var buttonV: UIButton!
    @IBOutlet weak var buttonW: UIButton!
    @IBOutlet weak var buttonX: UIButton!
    @IBOutlet weak var buttonY: UIButton!
    @IBOutlet weak var buttonZ: UIButton!
    
    @IBOutlet weak var buttonCheckpoint1: UIButton!
    @IBOutlet weak var buttonCheckpoint2: UIButton!
    @IBOutlet weak var buttonCheckpoint3: UIButton!
    @IBOutlet weak var buttonCheckpoint4: UIButton!
    @IBOutlet weak var buttonCheckpoint5: UIButton!
    @IBOutlet weak var buttonCheckpoint6: UIButton!
    @IBOutlet weak var buttonCheckpoint7: UIButton!
    
    @IBOutlet weak var buttonFinalTest1: UIButton!

    @IBOutlet weak var buttonCow: ImageButton!
    @IBOutlet weak var buttonHorse: ImageButton!
    @IBOutlet weak var buttonSheep: ImageButton!
    @IBOutlet weak var buttonChicken: ImageButton!
    @IBOutlet weak var buttonCat: ImageButton!
    @IBOutlet weak var buttonMouse: ImageButton!
    @IBOutlet weak var buttonPig: ImageButton!
    @IBOutlet weak var buttonDog: ImageButton!
    @IBOutlet weak var buttonRabbit: ImageButton!
    @IBOutlet weak var buttonBird: ImageButton!
    
    @IBOutlet weak var beachView: UIView!
    @IBOutlet weak var grassView: UIView!
    @IBOutlet weak var seaAnimationView: AnimationView!
    @IBOutlet weak var grayOverlayView: UIView!
    @IBOutlet weak var explorerAnimationView: AnimationView!
    @IBOutlet weak var crabRedAnimationView: AnimationView!
    @IBOutlet weak var crabBlueAnimationView: AnimationView!
    @IBOutlet weak var crabOrangeAnimationView: AnimationView!
    @IBOutlet weak var wilsonAnimationView: AnimationView!
    
    var currentLevel: Level = .none
    var currentButton = UIButton()
    var completedLevels = Array<Level>()
    var miniGameLetters = [Level]()
    
    var lastContentOffset: CGPoint!
    var audioPlayerBackground = AVAudioPlayer()
    var audioPlayerCrab = AVAudioPlayer()
    let audioUrlBeach = NSURL(fileURLWithPath: Bundle.main.path(forResource: "beach_background_noise", ofType: "mp3")!)
    let audioUrlCrab = NSURL(fileURLWithPath: Bundle.main.path(forResource: "crab_claw", ofType: "mp3")!)
    let audioUrlBall = NSURL(fileURLWithPath: Bundle.main.path(forResource: "squeak", ofType: "mp3")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up animation
        setUpAnimations()
        
        // Set up background sound
        setUpBackgroundSound()
        
        // Set up dialog.
        initDialog()
        dialogView.isHidden = true
        
        scrollView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Initialize UI
        dialogView.isHidden = true
        grayOverlayView.isHidden = true
        // Set scrollview offset
        lastContentOffset = ProgressTracker.shared.GetScrollViewContentOffset()
        scrollView.setContentOffset(lastContentOffset, animated: true)
        // Set up animation
        setUpAnimations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Get progress from Progress.plist.
        ProgressTracker.shared.RetrieveProgress()
        completedLevels = ProgressTracker.shared.GetCompletedLevels()
        
        initMapView()

        // Unlock levels based on the completed levels.
        for level in completedLevels{
            UnlockButton(level: level)
        }
        positionExplorer()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                let orient = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
                switch orient {
                case .portrait:
                    print("Portrait")
                case .landscapeLeft,.landscapeRight :
                    print("Landscape")
                default:
                    print("Anything But Portrait")
                }}, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
                    //refresh view once rotation is completed not in will transition as it returns incorrect frame size.Refresh here
                    self.beachView.removeLayer(layerName: "dashedLine")
                    self.grassView.removeLayer(layerName: "dashedLine")
                    self.initMapView()
            })
            super.viewWillTransition(to: size, with: coordinator)
        }
    
    // MARK: MAP VIEW UI HELPERS.
    
    func initMapView(){
        // Draw the lines from one button to another.
        dashedLine(from: buttonA, to: buttonB, direction: .LR, view: beachView)
        dashedLine(from: buttonB, to: buttonC, direction: .LR, view: beachView)
        dashedLine(from: buttonC, to: buttonD, direction: .LR, view: beachView)
        dashedLine(from: buttonD, to: buttonE, direction: .BR, view: beachView)
        dashedLine(from: buttonE, to: buttonCheckpoint1, direction: .RL, view: beachView)
        dashedLine(from: buttonCheckpoint1, to: buttonF, direction: .RL, view: beachView)
        dashedLine(from: buttonF, to: buttonG, direction: .BT, view: beachView)
        dashedLine(from: buttonG, to: buttonH, direction: .BL, view: beachView)
        dashedLine(from: buttonH, to: buttonI, direction: .LR, view: beachView)
        dashedLine(from: buttonI, to: buttonCheckpoint2, direction: .LR, view: beachView)
        dashedLine(from: buttonCheckpoint2, to: buttonJ, direction: .BT, view: beachView)
        dashedLine(from: buttonJ, to: buttonK, direction: .RL, view: beachView)
        dashedLine(from: buttonK, to: buttonL, direction: .RL, view: beachView)
        dashedLine(from: buttonL, to: buttonM, direction: .LT, view: beachView)
        dashedLine(from: buttonM, to: buttonN, direction: .LR, view: beachView)
        dashedLine(from: buttonN, to: buttonCheckpoint3, direction: .LR, view: beachView)
        dashedLine(from: buttonCheckpoint3, to: buttonO, direction: .BT, view: beachView)
        dashedLine(from: buttonO, to: buttonP, direction: .BR, view: beachView)
        dashedLine(from: buttonP, to: buttonQ, direction: .RL, view: beachView)
        dashedLine(from: buttonQ, to: buttonCheckpoint4, direction: .LT, view: beachView)
        dashedLine(from: buttonCheckpoint4, to: buttonR, direction: .LR, view: beachView)
        dashedLine(from: buttonR, to: buttonS, direction: .LR, view: beachView)
        dashedLine(from: buttonS, to: buttonT, direction: .BT, view: beachView)
        dashedLine(from: buttonT, to: buttonCheckpoint5, direction: .RL, view: beachView)
        dashedLine(from: buttonCheckpoint5, to: buttonU, direction: .RL, view: beachView)
        dashedLine(from: buttonU, to: buttonV, direction: .BT, view: beachView)
        dashedLine(from: buttonV, to: buttonW, direction: .LR, view: beachView)
        dashedLine(from: buttonW, to: buttonCheckpoint6, direction: .LR, view: beachView)
        dashedLine(from: buttonCheckpoint6, to: buttonX, direction: .BT, view: beachView)
        dashedLine(from: buttonX, to: buttonY, direction: .RL, view: beachView)
        dashedLine(from: buttonY, to: buttonZ, direction: .RL, view: beachView)
        dashedLine(from: buttonZ, to: buttonCheckpoint7, direction: .RL, view: beachView)
        dashedLine(from: buttonCheckpoint7, to: buttonFinalTest1, direction: .BL, view: beachView)
        
        // LEVEL 2
        let frame = scrollView.convert(buttonFinalTest1.frame, to: buttonCow.superview)
        let startPoint = CGPoint(x: frame.origin.x + buttonFinalTest1.frame.width * 0.5, y: frame.origin.y + buttonFinalTest1.frame.height)
        let endPoint = CGPoint(x: buttonCow.frame.origin.x + buttonCow.frame.width, y: buttonCow.frame.origin.y + buttonCow.frame.height * 0.5)
        dashedLine(from: startPoint, to: endPoint, view: grassView)
        dashedLine(from: buttonCow, to: buttonHorse, direction: .LR, view: grassView)
        dashedLine(from: buttonHorse, to: buttonSheep, direction: .BR, view: grassView)
        dashedLine(from: buttonSheep, to: buttonChicken, direction: .RL, view: grassView)
        dashedLine(from: buttonChicken, to: buttonCat, direction: .LR, view: grassView)
        dashedLine(from: buttonCat, to: buttonMouse, direction: .RT, view: grassView)
        dashedLine(from: buttonMouse, to: buttonPig, direction: .BR, view: grassView)
        dashedLine(from: buttonPig, to: buttonDog, direction: .RL, view: grassView)
        dashedLine(from: buttonDog, to: buttonRabbit, direction: .LR, view: grassView)
        dashedLine(from: buttonRabbit, to: buttonBird, direction: .BR, view: grassView)
    }
    
    func dashedLine(from b1: UIButton, to b2: UIButton, direction: Direction, view: UIView) {
        // Draw a dotted line from one button to another according to the direction specified.
        var startPoint, endPoint : CGPoint?
        switch (direction){
        case .LR:
            // Left to Right.
            startPoint = CGPoint(x: b1.frame.origin.x + b1.frame.width, y: b1.frame.origin.y + b1.frame.height * 0.5)
            endPoint = CGPoint(x: b2.frame.origin.x, y: b2.frame.origin.y + b2.frame.height * 0.5)
            break
        case .RL:
            // Right to Left.
            startPoint = CGPoint(x: b1.frame.origin.x, y: b1.frame.origin.y + b1.frame.height * 0.5)
            endPoint = CGPoint(x: b2.frame.origin.x + b2.frame.width, y: b2.frame.origin.y + b2.frame.height * 0.5)
            break
        case .BR:
            // Bottom to Right.
            startPoint = CGPoint(x: b1.frame.origin.x + b1.frame.width * 0.5, y: b1.frame.origin.y + b1.frame.height)
            endPoint = CGPoint(x: b2.frame.origin.x + b2.frame.width, y: b2.frame.origin.y + b2.frame.height * 0.5)
            break
        case .BL:
            // Bottom to Left.
            startPoint = CGPoint(x: b1.frame.origin.x + b1.frame.width * 0.5, y: b1.frame.origin.y + b1.frame.height)
            endPoint = CGPoint(x: b2.frame.origin.x, y: b2.frame.origin.y + b2.frame.height * 0.5)
            break
        case .BT:
            // Bottom to Top.
            startPoint = CGPoint(x: b1.frame.origin.x + b1.frame.width * 0.5, y: b1.frame.origin.y + b1.frame.height)
            endPoint = CGPoint(x: b2.frame.origin.x + b2.frame.width * 0.5, y: b2.frame.origin.y)
            break
        case .LT:
            // Left to Top.
            startPoint = CGPoint(x: b1.frame.origin.x, y: b1.frame.origin.y + b1.frame.height * 0.5)
            endPoint = CGPoint(x: b2.frame.origin.x + b2.frame.width * 0.5, y: b2.frame.origin.y)
            break
        case .RT:
            // Right to Top.
            startPoint = CGPoint(x: b1.frame.origin.x + b1.frame.width, y: b1.frame.origin.y + b1.frame.height * 0.5)
            endPoint = CGPoint(x: b2.frame.origin.x + b2.frame.width * 0.5, y: b2.frame.origin.y)
            break
        }
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: startPoint!)
        linePath.addLine(to: endPoint!)
        line.path = linePath.cgPath
        line.strokeColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        line.lineWidth = 3
        line.lineDashPattern = [6, 8]
        line.lineCap = .round
        line.name = "dashedLine"
        view.layer.addSublayer(line)
    }
    
    func dashedLine(from startPoint: CGPoint, to endPoint: CGPoint, view: UIView) {
        // Draw a dotted line from one button to another according to the direction specified.
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        linePath.move(to: startPoint)
        linePath.addLine(to: endPoint)
        line.path = linePath.cgPath
        line.strokeColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        line.lineWidth = 3
        line.lineDashPattern = [6, 8]
        line.lineCap = .round
        line.name = "dashedLine"
        view.layer.addSublayer(line)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            self.lastContentOffset = scrollView.contentOffset
    }
    
    //MARK: BUTTONS.
    
    @IBAction func buttonReleased(sender: UIButton){
        // Handle letter button clicks.
        switch sender {
        case buttonA:
            currentLevel = .letterA
        case buttonB:
            currentLevel = .letterB
        case buttonC:
            currentLevel = .letterC
        case buttonD:
            currentLevel = .letterD
        case buttonE:
            currentLevel = .letterE
        case buttonF:
            currentLevel = .letterF
        case buttonG:
            currentLevel = .letterG
        case buttonH:
            currentLevel = .letterH
        case buttonI:
            currentLevel = .letterI
        case buttonJ:
            currentLevel = .letterJ
        case buttonK:
            currentLevel = .letterK
        case buttonL:
            currentLevel = .letterL
        case buttonM:
            currentLevel = .letterM
        case buttonN:
            currentLevel = .letterN
        case buttonO:
            currentLevel = .letterO
        case buttonP:
            currentLevel = .letterP
        case buttonQ:
            currentLevel = .letterQ
        case buttonR:
            currentLevel = .letterR
        case buttonS:
            currentLevel = .letterS
        case buttonT:
            currentLevel = .letterT
        case buttonU:
            currentLevel = .letterU
        case buttonV:
            currentLevel = .letterV
        case buttonW:
            currentLevel = .letterW
        case buttonX:
            currentLevel = .letterX
        case buttonY:
            currentLevel = .letterY
        case buttonZ:
            currentLevel = .letterZ
        default:
            break
        }
        ProgressTracker.shared.SetCurrentLevel(to: self.currentLevel)
        // Open practice dialog.
        dialogView.fadeIn()
        showPracticeLetterDialog()
    }
    
    @IBAction func imageButtonReleased(sender: ImageButton){
        // Handle checkpoint button click.
        switch sender {
        case buttonCheckpoint1:
            currentLevel = .checkpoint1
        case buttonCheckpoint2:
            currentLevel = .checkpoint2
        case buttonCheckpoint3:
            currentLevel = .checkpoint3
        case buttonCheckpoint4:
            currentLevel = .checkpoint4
        case buttonCheckpoint5:
            currentLevel = .checkpoint5
        case buttonCheckpoint6:
            currentLevel = .checkpoint6
        case buttonCheckpoint7:
            currentLevel = .checkpoint7
        case buttonFinalTest1:
            currentLevel = .final1
        default:
            break
        }
        ProgressTracker.shared.SetCurrentLevel(to: self.currentLevel)
        dialogView.fadeIn()
        showMiniGameDialog()
    }

    func UnlockButton(level: Level){
        switch (level){
        case .letterA:
            buttonB.isEnabled = true
            currentButton = buttonB
        case .letterB:
            buttonC.isEnabled = true
            currentButton = buttonC
        case .letterC:
            buttonD.isEnabled = true
            currentButton = buttonD
        case .letterD:
            buttonE.isEnabled = true
            currentButton = buttonE
        case .letterE:
            buttonCheckpoint1.isEnabled = true
            currentButton = buttonCheckpoint1
        case .checkpoint1:
            buttonF.isEnabled = true
            currentButton = buttonF
        case .letterF:
            buttonG.isEnabled = true
            currentButton = buttonG
        case .letterG:
            buttonH.isEnabled = true
            currentButton = buttonH
        case .letterH:
            buttonI.isEnabled = true
            currentButton = buttonI
        case .letterI:
            buttonCheckpoint2.isEnabled = true
            currentButton = buttonCheckpoint2
        case .checkpoint2:
            buttonJ.isEnabled = true
            currentButton = buttonJ
        case .letterJ:
            buttonK.isEnabled = true
            currentButton = buttonK
        case .letterK:
            buttonL.isEnabled = true
            currentButton = buttonL
        case .letterL:
            buttonM.isEnabled = true
            currentButton = buttonM
        case .letterM:
            buttonN.isEnabled = true
            currentButton = buttonN
        case .letterN:
            buttonCheckpoint3.isEnabled = true
            currentButton = buttonCheckpoint3
        case .checkpoint3:
            buttonO.isEnabled = true
            currentButton = buttonO
        case .letterO:
            buttonP.isEnabled = true
            currentButton = buttonP
        case .letterP:
            buttonQ.isEnabled = true
            currentButton = buttonQ
        case .letterQ:
            buttonCheckpoint4.isEnabled = true
            currentButton = buttonCheckpoint4
        case .checkpoint4:
            buttonR.isEnabled = true
            currentButton = buttonR
        case .letterR:
            buttonS.isEnabled = true
            currentButton = buttonS
        case .letterS:
            buttonT.isEnabled = true
            currentButton = buttonT
        case .letterT:
            buttonCheckpoint5.isEnabled = true
            currentButton = buttonCheckpoint5
        case .checkpoint5:
            buttonU.isEnabled = true
            currentButton = buttonU
        case .letterU:
            buttonV.isEnabled = true
            currentButton = buttonV
        case .letterV:
            buttonW.isEnabled = true
            currentButton = buttonW
        case .letterW:
            buttonCheckpoint6.isEnabled = true
            currentButton = buttonCheckpoint6
        case .checkpoint6:
            buttonX.isEnabled = true
            currentButton = buttonX
        case .letterX:
            buttonY.isEnabled = true
            currentButton = buttonY
        case .letterY:
            buttonZ.isEnabled = true
            currentButton = buttonZ
        case .letterZ:
            buttonCheckpoint7.isEnabled = true
            currentButton = buttonCheckpoint7
        case .checkpoint7:
            buttonFinalTest1.isEnabled = true
            currentButton = buttonFinalTest1
            break
        case .final1:
            currentButton = buttonFinalTest1
            buttonFinalTest1.setImage(UIImage(named: "sand-castle-finished"), for: .normal)
            break
        case .none:
            buttonA.isEnabled = true
            currentButton = buttonA
        }
    }

    // MARK: DIALOG
    
    func initDialog() {
        // Initialize dialogView.
        dialogView.layer.borderColor = #colorLiteral(red: 0.4392156863, green: 0.4392156863, blue: 0.4392156863, alpha: 1)
        dialogView.layer.borderWidth = 0.5
        dialogView.layer.cornerRadius = 15
    }
    
    func showPracticeLetterDialog() {
        // Show dialog for letter practice.
        let letterDialogView : UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            view.layer.cornerRadius = 15
            return view
        }()
        letterDialogView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: letterDialogView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 500).isActive = true
        NSLayoutConstraint(item: letterDialogView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 500).isActive = true
        
        // Add title label.
        let titleLabel : UILabel = {
           let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            label.text = "dit is"
            label.font = UIFont.boldSystemFont(ofSize: 48)
            label.textColor = #colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1)
            return label
        }()
        // Add letter label.
        let letterLabel: UILabel = {
           let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            label.text = ProgressTracker.shared.GetLetter(of: currentLevel)
            label.font = UIFont.boldSystemFont(ofSize: 48)
            label.textColor = #colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1)
            return label
        }()
        
        // Add image.
        let signImage: UIImageView = {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            imageView.contentMode = .scaleAspectFit
            let imageName = ProgressTracker.shared.GetCurrentLevel().rawValue
            imageView.image = UIImage(named: imageName)
            return imageView
        }()
        signImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: signImage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200).isActive = true
        NSLayoutConstraint(item: signImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 200).isActive = true
        
        
        // Add button.
        let practiceButton : UIButton = {
           let button = ActionButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            button.setTitle("Oefenen", for: .normal)
            button.addTarget(self, action: #selector(startPractice), for: .touchUpInside)
            button.addTarget(self, action: #selector(buttonsPressed), for: .touchDown)

            return button
        }()
        practiceButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: practiceButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60).isActive = true
        NSLayoutConstraint(item: practiceButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250).isActive = true
        
        // Make stack view.
        let letterDialogStackView : UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [titleLabel, letterLabel, signImage, practiceButton])
            stackView.axis = .vertical
            stackView.distribution = .fill
            stackView.alignment = .center
            stackView.spacing = 1
            stackView.setCustomSpacing(5, after: titleLabel)
            stackView.setCustomSpacing(25, after: letterLabel)
            stackView.setCustomSpacing(25, after: signImage)
            return stackView
        }()
        
        // Combine everything together.
        addGrayOverlay()
        dialogView.addSubview(letterDialogView)
        letterDialogView.addSubview(letterDialogStackView)
        letterDialogStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: letterDialogStackView, attribute: .topMargin, relatedBy: .equal, toItem: dialogView, attribute: .topMargin, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: letterDialogStackView, attribute: .bottomMargin, relatedBy: .equal, toItem: dialogView, attribute: .bottomMargin, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: letterDialogStackView, attribute: .leadingMargin, relatedBy: .equal, toItem: dialogView, attribute: .leadingMargin, multiplier: 1, constant: 5).isActive = true
        NSLayoutConstraint(item: letterDialogStackView, attribute: .trailingMargin, relatedBy: .equal, toItem: dialogView, attribute: .trailingMargin, multiplier: 1, constant: -5).isActive = true
    }
    
    func showMiniGameDialog() {
        let miniGameDialogView : UIView = {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            view.layer.cornerRadius = 15
            return view
        }()
        miniGameDialogView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: miniGameDialogView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 500).isActive = true
        NSLayoutConstraint(item: miniGameDialogView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 500).isActive = true

        // Title of dialog
        let titleLabel : UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            label.font = UIFont.boldSystemFont(ofSize: 48)
            label.textColor = #colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1)
            label.textAlignment = NSTextAlignment.center
            return label
        }()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if(currentLevel == .final1) {
            titleLabel.text = "level toets!"
        } else {
            titleLabel.text = "mini-game!"
        }
        
        let gameInfoLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            label.text = "Tijd om alle letters van dit level te oefenen. Je hebt 60 seconden om 10 punten te halen."
            label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
            label.textColor = .black
            label.numberOfLines = 0
            label.textAlignment = NSTextAlignment.center
            return label
        }()
        gameInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if(currentLevel == .final1) {
            gameInfoLabel.text = "Tijd om alle letters van dit level te oefenen. Je moet alle letters 1x goed hebben, maar je mag er zolang over doen als je wilt."
        } else {
            gameInfoLabel.text = "Tijd om alle vorige letters te oefenen. Je hebt 60 seconden om 10 punten te halen."
        }
        
        // Letters to be practiced info
        let infoPracticeLettersLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            label.text = "Deze letters worden geoefend:"
            label.font = UIFont.systemFont(ofSize: 30, weight: .semibold)
            label.textColor = .black
            label.numberOfLines = 0
            label.textAlignment = NSTextAlignment.center
            return label
        }()
        infoPracticeLettersLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Letters to be practiced
        let practiceLettersLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            label.text = ProgressTracker.shared.GetLetter(of: currentLevel)
            label.font = UIFont.boldSystemFont(ofSize: 28)
            label.textColor = .black
            label.numberOfLines = 0
            label.textAlignment = NSTextAlignment.center
            return label
        }()
        practiceLettersLabel.translatesAutoresizingMaskIntoConstraints = false

        // Button to start mini-game
        let startGameButton : UIButton = {
            let button = ActionButton(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            button.setTitle("Start", for: .normal)
            button.addTarget(self, action: #selector(startMiniGame), for: .touchUpInside)
            button.addTarget(self, action: #selector(buttonsPressed), for: .touchDown)

            return button
        }()
        startGameButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: startGameButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 60).isActive = true
        NSLayoutConstraint(item: startGameButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 250).isActive = true

        let miniGameDialogStackView : UIStackView = {
            let stackView = UIStackView(arrangedSubviews: [titleLabel, gameInfoLabel, infoPracticeLettersLabel, practiceLettersLabel, startGameButton])
            stackView.axis = .vertical
            stackView.distribution = .equalSpacing
            stackView.alignment = .center
            stackView.spacing = 1
            return stackView
        }()
                
        // Add everything to the dialog view
        addGrayOverlay()
        dialogView.addSubview(miniGameDialogView)
        miniGameDialogView.addSubview(miniGameDialogStackView)
        
        miniGameDialogStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: miniGameDialogStackView, attribute: .topMargin, relatedBy: .equal, toItem: dialogView, attribute: .topMargin, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: miniGameDialogStackView, attribute: .bottomMargin, relatedBy: .equal, toItem: dialogView, attribute: .bottomMargin, multiplier: 1, constant: -30).isActive = true
        NSLayoutConstraint(item: miniGameDialogStackView, attribute: .leadingMargin, relatedBy: .equal, toItem: dialogView, attribute: .leadingMargin, multiplier: 1, constant: 20).isActive = true
        NSLayoutConstraint(item: miniGameDialogStackView, attribute: .trailingMargin, relatedBy: .equal, toItem: dialogView, attribute: .trailingMargin, multiplier: 1, constant: -20).isActive = true
    }
    
    func addGrayOverlay(){
        grayOverlayView.topAnchor.constraint(equalTo: self.view.topAnchor, constant:0).isActive = true
        grayOverlayView.fadeIn()
    }
        
    @objc func startPractice(button: UIButton){
        button.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1)
        button.setTitleColor(#colorLiteral(red: 0.7450980392, green: 0.8745098039, blue: 0.7254901961, alpha: 1), for: .normal)
        ProgressTracker.shared.SetScrollViewContentOffset(to: lastContentOffset)
        audioPlayerBackground.stop()
        performSegue(withIdentifier: "goToPracticeScreen", sender: self)
    }
    
    @objc func startMiniGame(button: UIButton){
        button.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1)
        button.setTitleColor(#colorLiteral(red: 0.7450980392, green: 0.8745098039, blue: 0.7254901961, alpha: 1), for: .normal)
        ProgressTracker.shared.SetScrollViewContentOffset(to: lastContentOffset)
        audioPlayerBackground.stop()
        performSegue(withIdentifier: "goToMiniGame", sender: self)
    }
    
    @objc func buttonsPressed(button: UIButton){
        button.backgroundColor = #colorLiteral(red: 0.7450980392, green: 0.8745098039, blue: 0.7254901961, alpha: 1)
        button.setTitleColor(#colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1), for: .normal)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if touch?.view != self.dialogView{
            dialogView.fadeOut()
            grayOverlayView.fadeOut()
        }
    }
    
    //MARK: SOUNDS.
    func setUpBackgroundSound() {
        do {
            audioPlayerBackground = try AVAudioPlayer(contentsOf: audioUrlBeach as URL)
        }
        catch {
            print("No file found")
        }
        audioPlayerBackground.numberOfLoops = -1
        audioPlayerBackground.play()
    }
    
    @objc func playCrabSound() {
        do {
            audioPlayerCrab = try AVAudioPlayer(contentsOf: audioUrlCrab as URL)
        }
        catch {
            print("No file found")
        }
        audioPlayerCrab.enableRate = true
        audioPlayerCrab.rate = 0.5
        audioPlayerCrab.numberOfLoops = 2
        audioPlayerCrab.play()
    }
    
    @objc func playBallSound() {
        do {
            audioPlayerCrab = try AVAudioPlayer(contentsOf: audioUrlBall as URL)
        }
        catch {
            print("No file found")
        }
        audioPlayerCrab.play()
    }
    
    //MARK: ANIMATIONS.
    
    func positionExplorer() {
        beachView.addSubview(explorerAnimationView)
        explorerAnimationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: explorerAnimationView as Any, attribute: .centerX, relatedBy: .equal, toItem: currentButton, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: explorerAnimationView as Any, attribute: .bottom, relatedBy: .equal, toItem: currentButton, attribute: .top, multiplier: 1, constant: 20).isActive = true
    }
    
    func setUpAnimations() {
        // Set up animation
        seaAnimationView.isUserInteractionEnabled = false
        buttonA.layer.zPosition = 1
        buttonC.layer.zPosition = 1
        explorerAnimationView.layer.zPosition = 2
        
        // Sea Animation
        seaAnimationView.contentMode = .scaleToFill
        seaAnimationView.loopMode = .loop
        seaAnimationView.animationSpeed = 1
        seaAnimationView.transform = CGAffineTransform(rotationAngle: .pi/1)
        seaAnimationView.play()
        seaAnimationView.isUserInteractionEnabled = false
        
        // Explorer Animation
        explorerAnimationView.loopMode = .loop
        explorerAnimationView.animationSpeed = 1
        explorerAnimationView.play()
        explorerAnimationView.isUserInteractionEnabled = false
        
        // Crab Blue Animation
        crabBlueAnimationView.loopMode = .loop
        crabBlueAnimationView.animationSpeed = 1.2
        crabBlueAnimationView.play()
        crabBlueAnimationView.isUserInteractionEnabled = true
        let crabBlueTouchRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.playCrabSound))
        crabBlueAnimationView.addGestureRecognizer(crabBlueTouchRecognizer)
        
        // Crab Red Animation
        crabRedAnimationView.loopMode = .loop
        crabRedAnimationView.animationSpeed = 1
        crabRedAnimationView.play()
        crabRedAnimationView.isUserInteractionEnabled = true
        let crabRedTouchRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.playCrabSound))
        crabRedAnimationView.addGestureRecognizer(crabRedTouchRecognizer)
        
        // Crab Orange Animation
        crabOrangeAnimationView.loopMode = .loop
        crabOrangeAnimationView.animationSpeed = 1.1
        crabOrangeAnimationView.play()
        crabOrangeAnimationView.isUserInteractionEnabled = true
        let crabOrangeTouchRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.playCrabSound))
        crabOrangeAnimationView.addGestureRecognizer(crabOrangeTouchRecognizer)
        
        // Wilson Animation.
        wilsonAnimationView.contentMode = .scaleAspectFit
        wilsonAnimationView.loopMode = .loop
        wilsonAnimationView.animationSpeed = 1.0
        wilsonAnimationView.play()
        wilsonAnimationView.isUserInteractionEnabled = true
        let ballTouchRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.playBallSound))
        wilsonAnimationView.addGestureRecognizer(ballTouchRecognizer)
    }
}

//MARK: EXTENSIONS.

extension UIView {
    func removeLayer(layerName: String) {
            for item in self.layer.sublayers ?? [] where item.name == layerName {
                    item.removeFromSuperlayer()
            }
        }
    
    func fadeIn(_ duration: TimeInterval? = 0.3, onCompletion: (() -> Void)? = nil) {
            self.alpha = 0
            self.isHidden = false
            UIView.animate(withDuration: duration!,
                           animations: { self.alpha = 1 },
                           completion: { (value: Bool) in
                              if let complete = onCompletion { complete() }
                           }
            )
        }

        func fadeOut(_ duration: TimeInterval? = 0.3, onCompletion: (() -> Void)? = nil) {
            UIView.animate(withDuration: duration!,
                           animations: { self.alpha = 0 },
                           completion: { (value: Bool) in
                               self.isHidden = true
                               if let complete = onCompletion { complete() }
                           }
            )
        }
}
