//
//  ActionButton.swift
//  gebaarNL
//
//  Created by Angelica Dewi on 17/12/2020.
//

import UIKit

class ActionButton: UIButton {

    override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
          }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
      }

    private func setup() {
        self.layer.cornerRadius = 20
        self.setTitleColor( #colorLiteral(red: 0.7450980392, green: 0.8745098039, blue: 0.7254901961, alpha: 1), for: .normal)
        self.backgroundColor = #colorLiteral(red: 0.9882352941, green: 0.4784313725, blue: 0.3411764706, alpha: 1)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28)
    }
}
