//
//  NSTextView.swift
//  Nea
//
//  Created by PEXAVC on 5/3/23.
//

import Foundation
import AppKit

extension NSTextView {
  open override var frame: CGRect {
    didSet {
      backgroundColor = .clear
      drawsBackground = true
    }
  }
}
