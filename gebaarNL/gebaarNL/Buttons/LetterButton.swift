//
//  LetterButton.swift
//  gebaarNL
//
//  Created by Angelica Dewi on 10/12/2020.
//

import UIKit

class LetterButton: UIButton {
//    let orangeButtons = ["buttonA", "buttonC", "buttonE", "buttonG", "buttonI", "buttonK", "buttonM", "buttonO", "buttonQ", "buttonS", "buttonU", "buttonW", "buttonY"]
//    let greenButtons = ["buttonB", "buttonD", "buttonF", "buttonH", "buttonJ", "buttonL", "buttonN", "buttonP", "buttonR", "buttonT", "buttonV", "buttonX", "buttonZ"]

    override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
          }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
      }

    private func setup() {
        self.layer.cornerRadius = 15
        self.layer.borderWidth = 0.5
        self.layer.borderColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        self.titleLabel?.shadowOffset = CGSize(width: 2, height: 3)
        self.isEnabled = false
      }
    
    override var isEnabled: Bool{
        didSet{
            alpha = isEnabled ? 1.0: 0.3
        }
    }

}
