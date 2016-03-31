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
    func backgroundColor(color: NSColor) {
        wantsLayer = true
        layer?.backgroundColor = color.CGColor
    }
}


class APScreenSaverView: ScreenSaverView {

    // config
    var screenW : UInt32 = 0

    // constants
    let kFilePath = "/Volumes/DATA/Dropbox/Work/Personal/PaskySaver/APScrenSaver/APScreenSaverView.swift"
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
    func randomNumber(pMax:UInt32, pMin:UInt32) -> Int {
        return Int(arc4random_uniform(pMax) + pMin)
    }

    /**
     Dispatcher

     - parameter block: Asyncronous block
     */
    func dispatch_to_main_queue(block: dispatch_block_t?) {
        dispatch_async(dispatch_get_main_queue(), block!)
    }

    /**
     Dispatcher

     - parameter block: Main queue block
     */
    func dispatch_to_background_queue(block: dispatch_block_t?) {
        let q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(q, block!)
    }

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)

        screenW = UInt32(NSScreen.mainScreen()!.frame.width)
        self.backgroundColor(NSColor.blackColor())

        // load a text file from system
        let location = NSString(string: kFilePath)

        // read as string
        var fileContent : String = try! String(contentsOfFile: location as String, encoding: NSUTF8StringEncoding)

        // put all characters in array
        words = fileContent.characters.map { String($0) } // powa of Swift 3!

        fileContent = ""

        // screen saver animation interval
        self.animationTimeInterval = kRefreshInterval

        // uncomment the line below if you want to debug/simulate in app:
        //NSTimer.scheduledTimerWithTimeInterval(kRefreshInterval, target: self, selector: #selector(APScreenSaverView.drawCharacters), userInfo: nil, repeats: true)
    }

    /**
     Draw a character on screen randomly
     */
    func drawCharacters() {

        dispatch_to_background_queue {

            let character = self.gimmeAChar()

            // i want on screen maximum 5000 letters. If > delete the oldest one.
            if self.drawed >= self.kMaxCharsOnScreen {
                self.dispatch_to_main_queue({
                    if self.subviews.count > 0 {
                        self.subviews.removeAtIndex(0)

                        let letter = self.makeTextField( character )
                        self.addSubview(letter)
                        self.drawed += 1

                        // refresh only the letter rect
                        self.setNeedsDisplayInRect(letter.frame)
                    }
                })
            }
            else // start loop
            {
                let letter = self.makeTextField( character )
                self.dispatch_to_main_queue({
                    self.addSubview(letter)
                    self.drawed += 1

                    // refresh only the letter rect
                    self.setNeedsDisplayInRect(letter.frame)
                })
            }
        }
    }

    /**
     Random value from array

     - returns: A Character
     */
    func gimmeAChar() -> NSString {
        let tot = self.words!.count
        return self.words![self.randomNumber(UInt32(tot-1), pMin: 0)]
    }

    /**
     Create an NSTextField

     - parameter character: The char to draw

     - returns: NSTextfield
     */
    func makeTextField(character : NSString) -> NSTextField {

        let letter : NSTextField = NSTextField(
            frame: NSMakeRect(
                CGFloat(self.randomNumber(self.screenW, pMin: 0)),
                CGFloat(self.randomNumber(self.screenW, pMin: 0)),
                30,
                35))

        // config
        letter.editable           = false
        letter.bordered           = false
        letter.alignment          = .Center
        letter.usesSingleLineMode = false
        letter.backgroundColor    = NSColor.clearColor()
        letter.font               = NSFont(name: "Raleway-Medium", size: 18)
        letter.stringValue        = character as String

        // colors
        switch character {
        case "}", "{", "[", "]", "(", ")":
            letter.textColor = NSColor.greenColor()
            break
        case ".", ":", ";":
            letter.textColor = NSColor.yellowColor()
            break
        case "#", "|", "!", "=":
            letter.textColor = NSColor.orangeColor()
            break
        case "/", "+", "-", "*":
            letter.textColor = NSColor.redColor()
            break
        default:
            letter.textColor = NSColor.darkGrayColor()
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
    
    override func drawRect(rect: NSRect) {
        super.drawRect(rect)
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
