//
//  PinCodeField.swift
//  PinCodeField
//
//  Created by nestorpopko on 11/25/2017.
//  Copyright (c) 2017 nestorpopko. All rights reserved.
//

import UIKit

@IBDesignable
open class PinCodeField: UIControl, UITextInputTraits {
    
    /** The text entered by user. */
    @IBInspectable open var text: String = "" {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** Length of the pin code */
    @IBInspectable open var length: Int = 4 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    /** Color of the dots. */
    @IBInspectable open var color: UIColor = .white {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /** Diameter of the dots. */
    @IBInspectable open var diameter: CGFloat = 20.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    /** Spacing between the dots. */
    @IBInspectable open var spacing: CGFloat = 16.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }
    
    /** Line thickness. */
    @IBInspectable open var thickness: CGFloat = 2.0 {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    /** Display numbers inside circles */
    @IBInspectable open var displayLetters: Bool = false {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    /** Font of numbers inside circles */
    @IBInspectable open var lettersFont: UIFont = UIFont.init(name: "AvenirNext-Regular", size: 17)! {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    /** Color of numbers inside circles */
    @IBInspectable open var lettersColor: UIColor = .white {
        didSet {
            invalidateIntrinsicContentSize()
            setNeedsDisplay()
        }
    }

    /** Tells whether the pin code is empty. */
    open var isEmpty: Bool {
        return text.isEmpty
    }
    
    /** Tells whether all characters were entered. */
    open var isFilled: Bool {
        return text.count == length
    }
    
    
    // MARK: UITextInputTraits protocol properties
    open var autocapitalizationType = UITextAutocapitalizationType.none
    open var autocorrectionType = UITextAutocorrectionType.no
    open var spellCheckingType = UITextSpellCheckingType.no
    open var keyboardType = UIKeyboardType.numberPad
    open var keyboardAppearance = UIKeyboardAppearance.default
    open var returnKeyType = UIReturnKeyType.done
    open var enablesReturnKeyAutomatically = true
    
    
    // MARK: initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialSetup()
    }
    
    private func initialSetup() {
        self.isOpaque = false
        addTarget(self, action: #selector(becomeFirstResponder), for: .touchUpInside)
    }
    
    
    // MARK: UIResponder
    open override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private var accessoryView: UIView?
    
    override open var inputAccessoryView: UIView? {
        get {
            accessoryView?.backgroundColor = .primary
            return accessoryView
        }
        set(value) {
            accessoryView = value
            accessoryView?.backgroundColor = .primary
        }
    }
    
    
    //MARK: UIView
    open override var intrinsicContentSize: CGSize {
        let width = CGFloat(length) * (diameter + spacing) - spacing + thickness
        let height = diameter + thickness
        return CGSize(width: width, height: height)
    }
    
    open override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        context.clear(rect)
        
        context.setFillColor(color.cgColor)
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(thickness)

        let chars = text.map { String($0) }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attrs: [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font: self.lettersFont,
            NSAttributedStringKey.paragraphStyle: paragraphStyle,
            NSAttributedStringKey.foregroundColor: self.lettersColor
        ]


        // Draw circles
        var origin = CGPoint.zero
        for i in 0..<length {
            
            let isDotFilled = i < text.count
            if isDotFilled {
                let dotRect = CGRect(origin: origin, size: CGSize(width: diameter + thickness, height: diameter + thickness))
                context.fillEllipse(in: dotRect)
                context.saveGState()
                if displayLetters {
                    let letter: NSString = String(chars[i]) as NSString
                    let size = letter.size(withAttributes: attrs)
                    let centeredRect = CGRect(x: dotRect.origin.x, y: dotRect.origin.y + (dotRect.height-size.height)/2.0, width: dotRect.width, height: size.height)

                    letter.draw(with: centeredRect, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
                }
                context.restoreGState()
            } else {
                let position = CGPoint(x: origin.x + thickness/2, y: origin.y + thickness/2)
                let dotRect = CGRect(origin: position, size: CGSize(width: diameter, height: diameter))
                context.strokeEllipse(in: dotRect)
            }
            
            origin.x += diameter + spacing
        }
    }
    
}

// MARK: UIKeyInput
extension PinCodeField : UIKeyInput {
    
    open var hasText: Bool {
        return !text.isEmpty
    }
    
    open func insertText(_ textToInsert: String) {
        if isEnabled && text.count + textToInsert.count <= length {
            text.append(textToInsert)
            sendActions(for: .editingChanged)
        }
    }
    
    open func deleteBackward() {
        if isEnabled && !text.isEmpty {
            text.removeLast()
            sendActions(for: .editingChanged)
        }
    }
    
}
