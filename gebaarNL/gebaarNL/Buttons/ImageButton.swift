//
//  ImageButton.swift
//  gebaarNL
//
//  Created by Angelica Dewi on 10/12/2020.
//

import UIKit

class ImageButton: UIButton {

    override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
          }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
      }

    private func setup() {
        self.adjustsImageWhenDisabled = true
        
        self.isEnabled = false
      }
}
