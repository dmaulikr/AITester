//
//  RoundCornerButton.swift
//  AI Tester
//
//  Created by Andrei Sadovnicov on 14/04/16.
//  Copyright © 2016 Andrei Sadovnicov. All rights reserved.
//

import UIKit


@IBDesignable
class RoundCornersButton: UIButton {
    
    // MARK: - PROPERTIES
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        
        didSet {
            
            layer.cornerRadius = cornerRadius
            
        }
    }
    
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        
        didSet {
            
            layer.borderWidth = borderWidth
            
        }
    }
    
    @IBInspectable var borderColor: UIColor? = UIColor.whiteColor() {
        
        didSet {
            
            layer.borderColor = borderColor?.CGColor
            
        }
    }
    
    
    // MARK: - METHODS
    
    // MARK: - Initializers
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialSetup()
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        initialSetup()
        
    }
    
    
    // MARK: - Initial button setup
    func initialSetup() {
        
        layer.cornerRadius = 5.0
        
        
    }
    
    // MARK: - Interface builder
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        initialSetup()
        
    }
    
    
}

