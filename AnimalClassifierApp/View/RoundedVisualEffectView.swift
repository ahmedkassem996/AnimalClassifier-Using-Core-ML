//
//  RoundedVisualEffectView.swift
//  AnimalClassifierApp
//
//  Created by AHMED on 3/14/1398 AP.
//  Copyright © 1398 AHMED. All rights reserved.
//

import UIKit

class RoundedVisualEffectView: UIVisualEffectView {
  
  override func awakeFromNib() {
    self.layer.cornerRadius = 10
    self.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMinYCorner]
    self.clipsToBounds = true
  }
}
