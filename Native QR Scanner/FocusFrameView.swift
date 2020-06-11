//
//  FocusFrameView.swift
//  Native QR Scanner
//
//  Created by Yuhao Zhong on 11.06.20.
//  Copyright © 2020 Yuhao Zhong. All rights reserved.
//

import UIKit

class FocusFrameView: UIView {
  override init(frame: CGRect) {
    super.init(frame: frame)
    configureView()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureView()
  }
  
  private func configureView() {
    backgroundColor = UIColor.clear
    isUserInteractionEnabled = false
    isHidden = true
  }
  
  func show() {
    guard let finalFrame = superview?.bounds else { return }
    
    frame = CGRect(origin: CGPoint(x: finalFrame.width / 2, y: finalFrame.height / 2), size: CGSize.zero)
    isHidden = false
    UIView.animate(withDuration: 1.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseOut, animations: {
      self.frame = finalFrame
    })
  }
  
  func hide() {
    let finalFrame = CGRect(origin: CGPoint(x: bounds.width / 2, y: bounds.height / 2), size: CGSize.zero)
    UIView.animate(withDuration: 1.4, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.2, options: .curveEaseIn, animations: {
      self.frame = finalFrame
    }, completion: { _ in
      self.isHidden = true
    })
  }
  
  override func draw(_ rect: CGRect) {
    let focusFrameLength: CGFloat = 30
    
    let size = min(self.bounds.width, self.bounds.height) - 100
    let frame = CGRect(
      origin: CGPoint(x: center.x - size / 2, y: center.y - size / 2),
      size: CGSize(width: size, height: size)
    )
    let topLeft = frame.origin
    let topRight = CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y)
    let bottomLeft = CGPoint(x: frame.origin.x, y: frame.origin.y + frame.height)
    let bottomRight = CGPoint(x: frame.origin.x + frame.width, y: frame.origin.y + frame.height)
    
    let context = UIGraphicsGetCurrentContext()
    context?.setLineWidth(1.0)
    context?.setStrokeColor(UIColor.lightGray.cgColor)
    
    context?.move(to: CGPoint(x: topLeft.x, y: topLeft.y + focusFrameLength))
    context?.addLine(to: topLeft)
    context?.addLine(to: CGPoint(x: topLeft.x + focusFrameLength, y: topLeft.y))
    
    context?.move(to: CGPoint(x: topRight.x, y: topRight.y + focusFrameLength))
    context?.addLine(to: topRight)
    context?.addLine(to: CGPoint(x: topRight.x - focusFrameLength, y: topRight.y))
    
    context?.move(to: CGPoint(x: bottomLeft.x, y: bottomLeft.y - focusFrameLength))
    context?.addLine(to: bottomLeft)
    context?.addLine(to: CGPoint(x: bottomLeft.x + focusFrameLength, y: bottomLeft.y))
    
    context?.move(to: CGPoint(x: bottomRight.x, y: bottomRight.y - focusFrameLength))
    context?.addLine(to: bottomRight)
    context?.addLine(to: CGPoint(x: bottomRight.x - focusFrameLength, y: bottomRight.y))
    context?.strokePath()
  }
}

