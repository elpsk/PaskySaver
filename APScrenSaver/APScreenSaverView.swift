//
//  APScreenSaverView.swift
//  PaskySaver
//
//  Created by Alberto Pasca on 31/03/16.
//  Copyright © 2016 albertopasca.it. All rights reserved.
//

import Cocoa
import ScreenSaver


// MARK: - NSView extension to set background color.
extension NSView {
    func backgroundColor(_ color: NSColor) {
        wantsLayer = true
        layer?.backgroundColor = color.cgColor
    }
}


class APScreenSaverView: ScreenSaverView {
    
    // config
    var screenW : UInt32 = 0
    
    // constants
    let kFilePath = "/Users/pasky/Dropbox/Work/Personal/PaskySaver/APScrenSaver/APScreenSaverView.swift"
    let kRefreshInterval = 0.000005
    let kMaxCharsOnScreen = 5000
    
    // counters
    var drawed = 0
    var idx    = 1
    
    // characters
    var words : [String]?
    
    /**
     Return a random number (4):
     
     - parameter pMax: Max value
     - parameter pMin: Min Value
     
     - returns: A random number
     */
    func randomNumber(_ pMax:UInt32, pMin:UInt32) -> Int {
        return Int(arc4random_uniform(pMax) + pMin)
    }
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        
        screenW = UInt32(NSScreen.main()!.frame.width)
        self.backgroundColor(NSColor.black)
        
        // load a text file from system
        let location = NSString(string: kFilePath)
        
        // read as string
        var fileContent : String = try! String(contentsOfFile: location as String, encoding: String.Encoding.utf8)
        
        // put all characters in array
        words = fileContent.characters.map { String($0) } // powa of Swift 3!
        
        fileContent = ""
        
        // screen saver animation interval
        self.animationTimeInterval = kRefreshInterval
        
        // uncomment the line below if you want to debug/simulate in app:
        //Timer.scheduledTimer(timeInterval: kRefreshInterval, target: self, selector: #selector(APScreenSaverView.drawCharacters), userInfo: nil, repeats: true)
    }
    
    /**
     Draw a character on screen randomly
     */
    func drawCharacters() {
        DispatchQueue.global(qos: .background).async {
            
            let character = self.gimmeAChar()
            let letter    = self.makeTextField( character )
            
            DispatchQueue.main.async {
                
                // i want on screen maximum 5000 letters. If > delete the oldest one.
                if self.drawed >= self.kMaxCharsOnScreen {
                    self.subviews.remove(at: 0)
                }

                self.addSubview(letter)
                self.drawed += 1

                // refresh only the letter rect
                self.setNeedsDisplay(letter.frame)
            }
        }
    }
    
    /**
     Random value from array
     
     - returns: A Character
     */
    func gimmeAChar() -> NSString {
        let tot = self.words!.count
        return self.words![self.randomNumber(UInt32(tot-1), pMin: 0)] as NSString
    }
    
    /**
     Create an NSTextField
     
     - parameter character: The char to draw
     
     - returns: NSTextfield
     */
    func makeTextField(_ character : NSString) -> NSTextField {
        
        let letter : NSTextField = NSTextField(
            frame: NSMakeRect(
                CGFloat(self.randomNumber(self.screenW, pMin: 0)),
                CGFloat(self.randomNumber(self.screenW, pMin: 0)),
                30,
                35))
        
        // config
        letter.isEditable         = false
        letter.isBordered         = false
        letter.alignment          = .center
        letter.usesSingleLineMode = false
        letter.backgroundColor    = NSColor.clear
        letter.font               = NSFont(name: "Raleway-Medium", size: 18)
        letter.stringValue        = character as String
        
        // colors
        switch character {
        case "}", "{", "[", "]", "(", ")":
            letter.textColor = NSColor.green
            break
        case ".", ":", ";":
            letter.textColor = NSColor.yellow
            break
        case "#", "|", "!", "=":
            letter.textColor = NSColor.orange
            break
        case "/", "+", "-", "*":
            letter.textColor = NSColor.red
            break
        default:
            letter.textColor = NSColor.darkGray
        }
        
        return letter
    }
    
    
    // +------------------------------------------------------------------------+
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func startAnimation() {
        super.startAnimation()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    override func draw(_ rect: NSRect) {
        super.draw(rect)
    }
    
    override func animateOneFrame() {
        drawCharacters()
    }
    
    override func hasConfigureSheet() -> Bool {
        return false
    }
    
    override func configureSheet() -> NSWindow? {
        return nil
    }
    
    override var wantsDefaultClipping: Bool {
        return false
    }
    
}

extension DispatchQueue {
    
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
    
}

